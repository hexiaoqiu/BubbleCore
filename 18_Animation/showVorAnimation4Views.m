function showVorAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, vorLim, frameRate, maxNumStepsPerBatch)
%SHOWVORANIMATION4VIEWS Show a four-view vorticity animation for one DNS case.
%
% Usage:
%   showVorAnimation4Views(dns, timeWindow, outputResolution)
%   showVorAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showVorAnimation4Views(dns, timeWindow, outputResolution, ...
%       storePath, vorLim, frameRate, maxNumStepsPerBatch)
%
% Inputs:
%   dns              DNS structure created by getDNS/setAsmCase.
%   timeWindow       Two-element vector: [animationStartTime, animationEndTime].
%   outputResolution Two-element vector: [figureWidth, figureHeight].
%   storePath        Optional. If non-empty, save a video in this folder.
%   vorLim           Optional. Two-element color-axis limit. When empty,
%                    a fixed symmetric limit is obtained from the first
%                    rendered snapshot.
%   frameRate        Optional. Video frame rate. Default: 30.
%   maxNumStepsPerBatch
%                    Optional. Maximum number of snapshots loaded into
%                    memory at once. Default: 16.

    narginchk(3, 7);

    [animationStartTime, animationEndTime] = ...
        parseTimeWindow(dns, timeWindow);
    figPosition = parseOutputResolution(outputResolution);

    storeVideoFile = false;
    if nargin >= 4 && ~isempty(storePath)
        storeVideoFile = true;
    else
        storePath = '';
    end

    if nargin < 5
        vorLim = [];
    end
    if ~isempty(vorLim)
        validateColorLimits(vorLim);
    end
    if nargin < 6 || isempty(frameRate)
        frameRate = 30;
    end
    if nargin < 7 || isempty(maxNumStepsPerBatch)
        maxNumStepsPerBatch = 16;
    end
    validateattributes(maxNumStepsPerBatch, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'integer', 'positive'}, ...
        mfilename, 'maxNumStepsPerBatch', 7);

    nPhi = max(dns.n1(:));
    nTheta = max(dns.n2(:));
    meshFull = obtainSphMesh(0, 2*pi, 0, pi/2, nPhi, nTheta);

    style = getAnimationStyle(figPosition, vorLim);
    RaStr = dnsGetLatexRaBubble(dns);

    videoFile = [];
    videoIsOpen = false;
    if storeVideoFile == true
        if exist(storePath, 'dir') ~= 7
            mkdir(storePath);
        end
        videoFile = dnsOpenVideoFile(dns, 'Vor', storePath, frameRate);
        videoIsOpen = true;
    end

    fig = figure();
    set(fig, 'position', figPosition);

    if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
        dns = asmFinishRead(dns);
    end

    renderState = [];
    try
        while dns.nextReadTime <= animationEndTime
            [dns, batch] = asmReadFieldBatch(dns, ...
                animationStartTime, animationEndTime, ...
                maxNumStepsPerBatch, {'vor'});

            for idxStep = 1:batch.numSteps
                idxSubCase = batch.subCaseIdx(idxStep);
                frameTime = batch.time(idxStep);
                vorOrg = batch.vorOrg{idxStep};

                disp(['Rendering: time = ', num2str(frameTime, '%g')])

                vor = interp2( ...
                    dns.x2dS{idxSubCase}, ...
                    dns.y2dS{idxSubCase}, ...
                    vorOrg, meshFull.x2d, meshFull.y2d, "spline");

                if isempty(renderState)
                    if isempty(style.lim)
                        style = setAutomaticColorLimits(style, vor);
                    end
                    renderState = initializeVorFrame4Views(fig, ...
                        meshFull, vor, RaStr, frameTime, style);
                else
                    updateVorFrame4Views(renderState, vor, ...
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

function validateColorLimits(limits)
    validateattributes(limits, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'finite'}, mfilename, 'vorLim', 5);
    if limits(1) >= limits(2)
        error('showVorAnimation4Views:InvalidColorLimits', ...
            'vorLim(1) must be smaller than vorLim(2).');
    end
end

function style = getAnimationStyle(figPosition, vorLim)
    style.figPosition = figPosition;
    style.fontSize = 20;
    style.labelFontSize = 25;
    style.titleFontSize = 30;
    style.lim = vorLim;
    if isempty(vorLim)
        style.colorBarTicks = [];
    else
        style.colorBarTicks = linspace(vorLim(1), vorLim(2), 5);
    end
end

function style = setAutomaticColorLimits(style, vor)
    finiteMagnitude = abs(vor(isfinite(vor)));
    if isempty(finiteMagnitude)
        error('showVorAnimation4Views:NoFiniteVorticity', ...
            'The first rendered vorticity field has no finite values.');
    end

    limitMagnitude = max(finiteMagnitude);
    if limitMagnitude == 0
        limitMagnitude = 1;
    end
    style.lim = [-limitMagnitude, limitMagnitude];
    style.colorBarTicks = linspace(style.lim(1), style.lim(2), 5);
end

function renderState = initializeVorFrame4Views( ...
    fig, meshFull, vor, RaStr, frameTime, style)

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
        surfaceList(idxView) = plotVorSurf( ...
            axList(idxView), meshFull, vor, style);
        setupAxes(axList(idxView), viewList(idxView, :), style);
        colormap(axList(idxView), cmap);
    end

    cb = colorbar(axList(4));
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';

    titleHandle = sgtitle(tileObj, ...
        getVorFrameTitle(RaStr, frameTime), ...
        'Interpreter', 'latex', ...
        'FontSize', style.titleFontSize);

    renderState.surfaceList = surfaceList;
    renderState.titleHandle = titleHandle;
    drawnow;
end

function updateVorFrame4Views(renderState, vor, RaStr, frameTime)
    for idxView = 1:numel(renderState.surfaceList)
        renderState.surfaceList(idxView).CData = vor;
    end
    renderState.titleHandle.String = getVorFrameTitle(RaStr, frameTime);
    drawnow;
end

function surfaceHandle = plotVorSurf(ax, meshFull, vor, style)
    surfaceHandle = surf(ax, meshFull.y3d, meshFull.x3d, ...
        meshFull.z3d, vor);
    shading(ax, 'interp');
    grid(ax, 'on');
    clim(ax, style.lim);
end

function setupAxes(ax, viewAngle, style)
    view(ax, viewAngle(1), viewAngle(2));
    grid(ax, 'on');
    set(ax, 'FontSize', style.fontSize);

    xlabel(ax, '$x$', ...
        'FontSize', style.labelFontSize, 'Interpreter', 'latex');
    ylabel(ax, '$y$', ...
        'FontSize', style.labelFontSize, 'Interpreter', 'latex');
    zlabel(ax, '$z$', ...
        'FontSize', style.labelFontSize, 'Interpreter', 'latex');

    xlim(ax, [-1, 1]);
    ylim(ax, [-1, 1]);
    zlim(ax, [0, 1]);
    xticks(ax, [-1, 0, 1]);
    yticks(ax, [-1, 0, 1]);
    zticks(ax, [0, 1]);
    axis(ax, 'equal');
end

function titleText = getVorFrameTitle(RaStr, frameTime)
    titleText = [RaStr, ' $t=', num2str(frameTime, '%.2f'), '$'];
end
