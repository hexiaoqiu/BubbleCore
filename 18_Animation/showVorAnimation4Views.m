function showVorAnimation4Views(dns, options)
%SHOWVORANIMATION4VIEWS Show a four-view vorticity animation for one DNS case.
%
%   OPTIONS fields and defaults:
%       timeWindow             [dns.dnsBeginTime, dns.dnsStopTime]
%       outputResolution       [1024, 768]
%       interpolationResolution [] -> maximum original DNS resolution
%       outputDirectory        '' -> display only; do not save video
%       vorLim                 [] -> symmetric limit from first frame
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
    vorLim = options.vorLim;
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

function options = normalizeOptions(dns, options)
%NORMALIZEOPTIONS 补齐并验证涡量动画选项。
    validateattributes(options, {'struct'}, {'scalar'}, mfilename, 'options', 2);
    defaults = struct('timeWindow', [dns.dnsBeginTime, dns.dnsStopTime], ...
        'outputResolution', [1024, 768], 'interpolationResolution', [], ...
        'outputDirectory', '', 'vorLim', [], ...
        'frameRate', 30, 'maxNumStepsPerBatch', 16);
    options = applyDefaults(options, defaults);
    validateCommonOptions(options);
    if ~isempty(options.vorLim)
        validateColorLimits(options.vorLim);
    end
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
