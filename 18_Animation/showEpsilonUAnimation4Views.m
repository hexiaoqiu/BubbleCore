function showEpsilonUAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, limMax, frameRate, maxNumStepsPerBatch)
%SHOWEPSILONUANIMATION4VIEWS Show dissipation and streamfunction in four views.
%
% Usage:
%   showEpsilonUAnimation4Views(dns, timeWindow, outputResolution)
%   showEpsilonUAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showEpsilonUAnimation4Views(dns, timeWindow, outputResolution, ...
%       storePath, limMax, frameRate, maxNumStepsPerBatch)
%
% Inputs:
%   dns              DNS structure created by setDnsCase/setAsmCase.
%   timeWindow       Two-element vector: [animationStartTime, animationEndTime].
%   outputResolution Two-element vector: [figureWidth, figureHeight].
%   storePath        Optional. If non-empty, save a video in this folder.
%                    Linux uses Motion JPEG AVI; Windows/macOS use MPEG-4.
%   limMax           Optional. Two-element color-axis limit for
%                    log10(epsilonU). Default: [-10, 10].
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

    if nargin < 5 || isempty(limMax)
        limMax = [-10,10];
    end
    validateColorLimits(limMax, 'limMax');

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

    style = getAnimationStyle(figPosition, limMax);
    RaStr = dnsGetLatexRaBubble(dns);

    videoFile = [];
    videoIsOpen = false;
    if storeVideoFile == true
        if exist(storePath, 'dir') ~= 7
            mkdir(storePath);
        end
        videoFile = dnsOpenVideoFile(dns, 'EpsilonU', storePath, frameRate);
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

                epsilonU = dnsGetEpsilonU(dns, idxSubCase, ...
                    u2dOrg, v2dOrg, meshFull);

                u2d = interp2(dns.x2dU{idxSubCase}, ...
                    dns.y2dU{idxSubCase}, ...
                    u2dOrg, meshFull.x2d, meshFull.y2d, "spline");

                v2d = interp2(dns.x2dV{idxSubCase}, ...
                    dns.y2dV{idxSubCase}, ...
                    v2dOrg, meshFull.x2d, meshFull.y2d, "spline");

                [uPhi, vTheta] = velocity2DToSph(u2d, v2d, ...
                    meshFull.x2d, meshFull.y2d, ...
                    meshFull.phi, meshFull.theta);

                psi = getStreamFunctionFromSphereVelocity( ...
                    meshFull.phiVec, meshFull.thetaVec, ...
                    uPhi, vTheta);
                logEpsilonU = log10(epsilonU);

                if isempty(renderState)
                    renderState = initializeEpsilonUFrame4Views(fig, ...
                        meshFull, logEpsilonU, psi, ...
                        RaStr, frameTime, style);
                else
                    renderState = updateEpsilonUFrame4Views( ...
                        renderState, meshFull, logEpsilonU, psi, ...
                        RaStr, frameTime, style);
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
        error('showEpsilonUAnimation4Views:InvalidColorLimits', ...
            '%s(1) must be smaller than %s(2).', ...
            argumentName, argumentName);
    end
end

function [animationStartTime, animationEndTime] = parseTimeWindow(dns, timeWindow)
    if numel(timeWindow) ~= 2
        error('showTmpAnimation4Views:BadTimeWindow', ...
            'timeWindow must be a two-element vector: [startTime, endTime].')
    end

    animationStartTime = timeWindow(1);
    animationEndTime = timeWindow(2);

    if animationStartTime > animationEndTime
        error('showTmpAnimation4Views:BadTimeWindow', ...
            'timeWindow(1) must be smaller than or equal to timeWindow(2).')
    end
    if animationStartTime < dns.dnsBeginTime || animationEndTime > dns.dnsStopTime
        error('showTmpAnimation4Views:TimeOutOfRange', ...
            'The requested animation time window is outside the DNS time range.')
    end
end

function figPosition = parseOutputResolution(outputResolution)
    if numel(outputResolution) ~= 2
        error('showTmpAnimation4Views:BadOutputResolution', ...
            'outputResolution must be a two-element vector: [width, height].')
    end

    figWidth = outputResolution(1);
    figHeight = outputResolution(2);
    if figWidth <= 0 || figHeight <= 0
        error('showTmpAnimation4Views:BadOutputResolution', ...
            'outputResolution values must be positive.')
    end

    figPosition = [0, 0, figWidth, figHeight];
end

function style = getAnimationStyle(figPosition, limMax)
    style.figPosition = figPosition;
    style.fontSize = 20;
    style.labelFontSize = 25;
    style.titleFontSize = 30;
    style.colorBarTicks = linspace(limMax(1),limMax(2),5);
    style.limMax = limMax;
    style.numPsiContourLevels = 15;
    style.contourLineWidth = 0.45;
end


function renderState = initializeEpsilonUFrame4Views( ...
    fig, meshFull, logEpsilonU, psi, RaStr, frameTime, style)

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
    contourLineList = cell(4, 1);
    for idxView = 1:4
        axList(idxView) = nexttile(tileObj);
        surfaceList(idxView) = plotEpsilonUSurf( ...
            axList(idxView), meshFull, logEpsilonU);
        contourLineList{idxView} = gobjects(0, 1);
        setupAxes(axList(idxView), viewList(idxView, :), style);
        clim(axList(idxView), style.limMax);
        colormap(axList(idxView), turbo);
    end

    cb = colorbar(axList(4));
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';

    titleHandle = sgtitle(tileObj, ...
        getEpsilonUFrameTitle(RaStr, frameTime), ...
        'Interpreter', 'latex', ...
        'FontSize', style.titleFontSize);

    renderState.axList = axList;
    renderState.surfaceList = surfaceList;
    renderState.contourLineList = contourLineList;
    renderState.titleHandle = titleHandle;
    renderState = updateEpsilonUFrame4Views(renderState, ...
        meshFull, logEpsilonU, psi, RaStr, frameTime, style);
end

function renderState = updateEpsilonUFrame4Views( ...
    renderState, meshFull, logEpsilonU, psi, ...
    RaStr, frameTime, style)

    lineData = getPsiContourLinesOnSphere( ...
        meshFull.phiVec, meshFull.thetaVec, psi, ...
        1, style.numPsiContourLevels);

    for idxView = 1:numel(renderState.axList)
        renderState.surfaceList(idxView).CData = logEpsilonU;
        renderState.contourLineList{idxView} = updateContourLinePool( ...
            renderState.axList(idxView), ...
            renderState.contourLineList{idxView}, ...
            lineData, style.contourLineWidth);
    end
    renderState.titleHandle.String = ...
        getEpsilonUFrameTitle(RaStr, frameTime);
    drawnow;
end

function linePool = updateContourLinePool( ...
    ax, linePool, lineData, lineWidth)

    numRequiredLines = numel(lineData);
    numExistingLines = numel(linePool);
    if numExistingLines < numRequiredLines
        expandedLinePool = gobjects(numRequiredLines, 1);
        expandedLinePool(1:numExistingLines) = linePool;
        linePool = expandedLinePool;
        holdState = ishold(ax);
        hold(ax, 'on');
        for idxLine = numExistingLines + 1:numRequiredLines
            linePool(idxLine, 1) = plot3(ax, nan, nan, nan, ...
                'k-', 'LineWidth', lineWidth);
        end
        if ~holdState
            hold(ax, 'off');
        end
    end

    for idxLine = 1:numRequiredLines
        set(linePool(idxLine), ...
            'XData', lineData(idxLine).xData, ...
            'YData', lineData(idxLine).yData, ...
            'ZData', lineData(idxLine).zData, ...
            'Visible', 'on');
    end
    for idxLine = numRequiredLines + 1:numel(linePool)
        linePool(idxLine).Visible = 'off';
    end
end

function surfaceHandle = plotEpsilonUSurf(ax, meshFull, logEpsilonU)
    surfaceHandle = surf(ax, ...
        meshFull.x3d, meshFull.y3d, meshFull.z3d, logEpsilonU, ...
        'EdgeColor', 'none', ...
        'FaceColor', 'interp', ...
        'FaceAlpha', 1.0, ...
        'FaceLighting', 'none', ...
        'SpecularStrength', 0, ...
        'DiffuseStrength', 1, ...
        'AmbientStrength', 1);
end

function titleText = getEpsilonUFrameTitle(RaStr, frameTime)
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
