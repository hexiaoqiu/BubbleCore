function showUphiAnimation4Views(dns, options)
%SHOWUPHIANIMATION4VIEWS Show a four-view azimuthal-velocity animation.
%
%   OPTIONS fields and defaults:
%       timeWindow             [dns.dnsBeginTime, dns.dnsStopTime]
%       outputResolution       [1024, 768]
%       interpolationResolution [] -> maximum original DNS resolution
%       outputDirectory        '' -> display only; do not save video
%       uPhiLim                [-0.1, 0.1]
%       frameRate              30
%       maxNumStepsPerBatch    16

    narginchk(1, 2);
    if nargin < 2 || isempty(options)
        options = struct();
    end
    options = normalizeOptions(dns, options);

    [animationStartTime, animationEndTime] = ...
        parseTimeWindow(dns, options.timeWindow);
    figPosition = parseOutputResolution(options.outputResolution);
    storePath = options.outputDirectory;
    storeVideoFile = ~isempty(storePath);
    uPhiLim = options.uPhiLim;
    frameRate = options.frameRate;
    maxNumStepsPerBatch = options.maxNumStepsPerBatch;

    if isempty(options.interpolationResolution)
        nPhi = max(dns.n1(:));
        nTheta = max(dns.n2(:));
    else
        nPhi = options.interpolationResolution(1);
        nTheta = options.interpolationResolution(2);
    end
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

function options = normalizeOptions(dns, options)
%NORMALIZEOPTIONS 补齐并验证方位角速度动画选项。
    validateattributes(options, {'struct'}, {'scalar'}, mfilename, 'options', 2);
    defaults = struct('timeWindow', [dns.dnsBeginTime, dns.dnsStopTime], ...
        'outputResolution', [1024, 768], 'interpolationResolution', [], ...
        'outputDirectory', '', 'uPhiLim', [-0.1, 0.1], ...
        'frameRate', 30, 'maxNumStepsPerBatch', 16);
    options = applyDefaults(options, defaults);
    validateCommonOptions(options);
    validateColorLimits(options.uPhiLim, 'options.uPhiLim');
end

function options = applyDefaults(options, defaults)
    validFields = fieldnames(defaults);
    unknownFields = setdiff(fieldnames(options), validFields, 'stable');
    if ~isempty(unknownFields)
        error([mfilename, ':UnknownOption'], ...
            'Unknown options field(s): %s', strjoin(unknownFields, ', '));
    end
    for idxField = 1:numel(validFields)
        fieldName = validFields{idxField};
        if ~isfield(options, fieldName)
            options.(fieldName) = defaults.(fieldName);
        end
    end
end

function validateCommonOptions(options)
    validateattributes(options.outputResolution, {'numeric'}, ...
        {'vector', 'numel', 2, 'real', 'finite', 'integer', 'positive'});
    if ~isempty(options.interpolationResolution)
        validateattributes(options.interpolationResolution, {'numeric'}, ...
            {'vector', 'numel', 2, 'real', 'finite', 'integer', 'positive'});
        if any(options.interpolationResolution < 2)
            error([mfilename, ':InterpolationResolutionTooSmall'], ...
                'Each interpolation resolution must be at least 2.');
        end
    end
    validateattributes(options.frameRate, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});
    validateattributes(options.maxNumStepsPerBatch, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'integer', 'positive'});
    if ~((ischar(options.outputDirectory) && ...
            (isrow(options.outputDirectory) || isempty(options.outputDirectory))) || ...
            (isstring(options.outputDirectory) && isscalar(options.outputDirectory)))
        error([mfilename, ':InvalidOutputDirectory'], ...
            'options.outputDirectory must be a character vector or string scalar.');
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
