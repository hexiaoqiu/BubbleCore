function showUphiAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, uPhiLim, frameRate, maxNumStepsPerBatch)
%SHOWUPHIANIMATION4VIEWS Show a four-view azimuthal-velocity animation.
%
% Usage:
%   showUphiAnimation4Views(dns, timeWindow, outputResolution)
%   showUphiAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showUphiAnimation4Views(dns, timeWindow, outputResolution, ...
%       storePath, uPhiLim, frameRate, maxNumStepsPerBatch)
%
% Inputs:
%   dns              DNS structure created by setDnsCase/setAsmCase.
%   timeWindow       Two-element vector: [animationStartTime, animationEndTime].
%   outputResolution Two-element vector: [figureWidth, figureHeight].
%   storePath        Optional. If non-empty, save a video in this folder.
%                    Linux uses Motion JPEG AVI; Windows/macOS use MPEG-4.
%   uPhiLim          Optional. Two-element color-axis limit. Default:
%                    [-0.1, 0.1].
%   frameRate        Optional. Video frame rate. Default: 30.
%   maxNumStepsPerBatch
%                    Optional. Maximum number of snapshots loaded into
%                    memory at once. Default: 16.

    narginchk(3, 7);

    [animationStartTime, animationEndTime] = parseTimeWindow(dns, timeWindow);
    figPosition = parseOutputResolution(outputResolution);

    storeVideoFile = false;
    if nargin >= 4 && ~isempty(storePath)
        storeVideoFile = true;
    else
        storePath = '';
    end

    if nargin < 5 || isempty(uPhiLim)
        uPhiLim = [-0.1, 0.1];
    end
    validateColorLimits(uPhiLim, 'uPhiLim');

    if nargin < 6 || isempty(frameRate)
        frameRate = 30;
    end
    if nargin < 7 || isempty(maxNumStepsPerBatch)
        maxNumStepsPerBatch = 16;
    end
    validateattributes(maxNumStepsPerBatch, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'integer', 'positive'}, ...
        mfilename, 'maxNumStepsPerBatch', 7);
    
    % Use a denser spherical mesh than the original DNS mesh for smoother
    % animation frames. n1 controls longitude and n2 controls latitude.
    nPhi = max(dns.n1(:));
    nTheta = max(dns.n2(:));
    meshFull = obtainSphMesh(0, 2*pi, 0, pi/2, nPhi, nTheta);

    style = getAnimationStyle(figPosition, uPhiLim);
    RaStr = dnsGetLatexRaBubble(dns);

    videoFile = [];
    videoIsOpen = false;
    if storeVideoFile == true
        if exist(storePath, 'dir') ~= 7
            mkdir(storePath);
        end
        videoFile = dnsOpenVideoFile(dns, 'Uphi', storePath, frameRate);
        videoIsOpen = true;
    end

    fig = figure();
    set(fig, 'position', figPosition);

    % Start from the requested time window even if the input dns was left
    % open by previous inspection code.
    if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
        dns = asmFinishRead(dns);
    end

    renderState = [];
    try
        while dns.nextReadTime <= animationEndTime
            [dns, batch] = asmReadFieldBatch(dns, ...
                animationStartTime, animationEndTime, ...
                maxNumStepsPerBatch, {'u2d', 'v2d'});

            for idxStep = 1:batch.numSteps
                idxSubCase = batch.subCaseIdx(idxStep);
                frameTime = batch.time(idxStep);
                u2dOrg = batch.u2dOrg{idxStep};
                v2dOrg = batch.v2dOrg{idxStep};

                disp(['Rendering: time = ', num2str(frameTime, '%g')])

                u2d = interp2(dns.x2dU{idxSubCase}, ...
                    dns.y2dU{idxSubCase}, ...
                    u2dOrg, meshFull.x2d, meshFull.y2d, "spline");

                v2d = interp2(dns.x2dV{idxSubCase}, ...
                    dns.y2dV{idxSubCase}, ...
                    v2dOrg, meshFull.x2d, meshFull.y2d, "spline");

                [uPhi, ~] = velocity2DToSph(u2d, v2d, ...
                    meshFull.x2d, meshFull.y2d, ...
                    meshFull.phi, meshFull.theta);

                if isempty(renderState)
                    renderState = initializeUphiFrame4Views(fig, ...
                        meshFull, uPhi, RaStr, frameTime, style);
                else
                    updateUphiFrame4Views(renderState, uPhi, ...
                        RaStr, frameTime);
                end

                if storeVideoFile == true
                    frame = getframe(fig);
                    writeVideo(videoFile, frame);
                end
            end
        end

        disp('Close the file!');
        asmFinishRead(dns);
        if videoIsOpen == true
            close(videoFile);
        end
        if storeVideoFile == true
            close(fig);
        end
    catch ME
        if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
            asmFinishRead(dns);
        end
        if videoIsOpen == true
            close(videoFile);
        end
        rethrow(ME)
    end
end

function validateColorLimits(limits, argumentName)
    validateattributes(limits, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'finite'}, mfilename, argumentName);
    if limits(1) >= limits(2)
        error('showUphiAnimation4Views:InvalidColorLimits', ...
            '%s(1) must be smaller than %s(2).', ...
            argumentName, argumentName);
    end
end


function style = getAnimationStyle(figPosition, uPhiLim)
    style.figPosition = figPosition;
    style.fontSize = 20;
    style.labelFontSize = 25;
    style.titleFontSize = 30;
    style.colorBarTicks = linspace(uPhiLim(1),uPhiLim(2),5);
    style.lim = uPhiLim;
end


function renderState = initializeUphiFrame4Views(fig, meshFull, uPhi, ...
    RaStr, frameTime, style)

    clf(fig);
    tileObj = tiledlayout(fig, 2, 2, ...
        'TileSpacing', 'Compact', ...
        'Padding', 'Compact');

    viewList = [
        45, 30
        135, 30
        225, 30
        0, 90
        ];

    axList = gobjects(4, 1);
    surfaceList = gobjects(4, 1);
    cmap = crameri('vik', 256);
    for idxView = 1:4
        axList(idxView) = nexttile(tileObj);
        surfaceList(idxView) = plotUphiSurf(axList(idxView), ...
            meshFull, uPhi, viewList(idxView, :), style);
        setupAxes(axList(idxView), viewList(idxView, :), style);
        colormap(axList(idxView), cmap);
    end

    cb = colorbar(axList(4));
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';

    titleHandle = sgtitle(tileObj, ...
        getUphiFrameTitle(RaStr, frameTime), ...
        'Interpreter', 'latex', ...
        'FontSize', style.titleFontSize);

    renderState.surfaceList = surfaceList;
    renderState.titleHandle = titleHandle;
    drawnow;
end

function updateUphiFrame4Views(renderState, uPhi, RaStr, frameTime)
    for idxView = 1:numel(renderState.surfaceList)
        renderState.surfaceList(idxView).CData = uPhi;
    end
    renderState.titleHandle.String = ...
        getUphiFrameTitle(RaStr, frameTime);
    drawnow;
end

function titleText = getUphiFrameTitle(RaStr, frameTime)
    titleText = [RaStr, ' $t=', num2str(frameTime, '%.2f'), '$'];
end

function setupAxes(ax, viewAngle, style)

    view(ax, viewAngle(1), viewAngle(2));
    
    grid(ax, 'on');
    
    set(ax, 'FontSize', style.fontSize);
    
    xlabel(ax, '$x$', ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');
    
    ylabel(ax, '$y$', ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');
    
    zlabel(ax, '$z$', ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');

    % Important:
    % Contour lines are plotted on Rline = R * 1.003.
    % Therefore the axis limits must be slightly larger than [-1,1] and [0,1].
    limPad = 1.01;

    xlim(ax, [-limPad, limPad]);
    ylim(ax, [-limPad, limPad]);
    zlim(ax, [0, limPad]);

    xticks(ax, [-1, 0, 1]);
    yticks(ax, [-1, 0, 1]);
    zticks(ax, [0, 1]);

    axis(ax, 'equal');

end


function surfaceHandle = plotUphiSurf(ax, meshFull, uPhi, ...
    viewAngle, style)
    surfaceHandle = surf(ax, meshFull.y3d, meshFull.x3d, ...
        meshFull.z3d, uPhi);
    view(ax, viewAngle);
    shading(ax, 'interp');
    grid(ax, 'on');
    clim(ax, style.lim);
    format3DAxes(ax, style);
end

function format3DAxes(ax, style)
    set(ax, 'FontSize', style.fontSize);
    xlabel(ax, '$x_2$', 'FontSize', style.labelFontSize, 'interpreter', 'latex');
    ylabel(ax, '$x_1$', 'Rotation', 0, ...
        'FontSize', style.labelFontSize, 'interpreter', 'latex');
    zlabel(ax, '$x_3$', 'Rotation', 0, ...
        'FontSize', style.labelFontSize, 'interpreter', 'latex');
    set(ax, 'YDir', 'reverse');
    xlim(ax, [-1, 1]);
    xticks(ax, [-1, -0.5, 0, 0.5, 1]);
    ylim(ax, [-1, 1]);
    yticks(ax, [-1, -0.5, 0, 0.5, 1]);
    zlim(ax, [0, 1]);
    zticks(ax, [0, 0.4, 0.7, 1]);
end
