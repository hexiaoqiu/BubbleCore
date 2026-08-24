function showTmpStreamAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, frameRate)
%SHOWTMPSTREAMANIMATION4VIEWS Show temperature and streamfunction in four views.
%
% Usage:
%   showTmpStreamAnimation4Views(dns, timeWindow, outputResolution)
%   showTmpStreamAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showTmpStreamAnimation4Views(dns, timeWindow, outputResolution, ...
%       storePath, frameRate)
%
% Inputs:
%   dns              DNS structure created by getDNS/setAsmCase.
%   timeWindow       Two-element vector: [animationStartTime, animationEndTime].
%   outputResolution Two-element vector: [figureWidth, figureHeight].
%   storePath        Optional. If non-empty, save a video in this folder.
%                    Linux uses Motion JPEG AVI; Windows/macOS use MPEG-4.
%   frameRate        Optional. Video frame rate. Default: 30.
%
% The instantaneous temperature is used as the sphere surface color. Black
% contour lines show the instantaneous streamfunction reconstructed from
% the two spherical velocity components.

    narginchk(3, 5);

    [animationStartTime, animationEndTime] = ...
        parseTimeWindow(dns, timeWindow);
    figPosition = parseOutputResolution(outputResolution);

    storeVideoFile = false;
    if nargin >= 4 && ~isempty(storePath)
        storeVideoFile = true;
    else
        storePath = '';
    end

    if nargin < 5 || isempty(frameRate)
        frameRate = 30;
    end

    % Keep the same dense visualization mesh as showTmpAnimation4Views.
    nPhi = max(dns.n1(:))*2;
    nTheta = max(dns.n2(:))*2;
    meshFull = obtainSphMesh(0, 2*pi, 0, pi/2, nPhi, nTheta);

    style = getAnimationStyle(figPosition);
    RaStr = dnsGetLatexRa(dns);

    videoFile = [];
    videoIsOpen = false;
    if storeVideoFile == true
        if exist(storePath, 'dir') ~= 7
            mkdir(storePath);
        end
        videoFile = openVideoFile( ...
            dns, storePath, frameRate, 'TmpStream');
        videoIsOpen = true;
    end

    fig = figure();
    set(fig, 'position', figPosition);

    % Start from the requested time window even if dns was left open by
    % previous inspection or post-processing code.
    if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
        dns = asmFinishRead(dns);
    end

    try
        while dns.nextReadTime <= animationEndTime
            if dns.readCounter == 0
                [dns, tmpOrg, u2dOrg, v2dOrg, ~] = ...
                    asmInitRead(dns, animationStartTime);
            else
                [dns, tmpOrg, u2dOrg, v2dOrg, ~] = ...
                    asmReadOneStepForward(dns);
            end

            disp(['time = ', num2str(dns.lastReadTime, '%g')])

            idxSubCase = dns.readNowSubCaseIdx;

            tmpFull = interp2( ...
                dns.x2dS{idxSubCase}, ...
                dns.y2dS{idxSubCase}, ...
                tmpOrg, ...
                meshFull.x2d, ...
                meshFull.y2d, ...
                'linear');

            u2d = interp2( ...
                dns.x2dU{idxSubCase}, ...
                dns.y2dU{idxSubCase}, ...
                u2dOrg, ...
                meshFull.x2d, ...
                meshFull.y2d, ...
                'spline');

            v2d = interp2( ...
                dns.x2dV{idxSubCase}, ...
                dns.y2dV{idxSubCase}, ...
                v2dOrg, ...
                meshFull.x2d, ...
                meshFull.y2d, ...
                'spline');

            [uPhi, vTheta] = velocity2DToSph( ...
                u2d, v2d, ...
                meshFull.x2d, meshFull.y2d, ...
                meshFull.phi, meshFull.theta);

            psi = getStreamFunctionFromSphereVelocity( ...
                meshFull.phiVec, meshFull.thetaVec, ...
                uPhi, vTheta);

            drawTmpStreamFrame4Views( ...
                fig, dns, meshFull, tmpFull, psi, RaStr, style);

            if storeVideoFile == true
                frame = getframe(fig);
                writeVideo(videoFile, frame);
            end
        end

        disp('Close the file!');
        dns = asmFinishRead(dns);
        if videoIsOpen == true
            close(videoFile);
        end
        if storeVideoFile == true
            close(fig);
        end
    catch ME
        if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
            dns = asmFinishRead(dns);
        end
        if videoIsOpen == true
            close(videoFile);
        end
        rethrow(ME)
    end
end

function style = getAnimationStyle(figPosition)
    style.figPosition = figPosition;
    style.fontSize = 20;
    style.labelFontSize = 25;
    style.titleFontSize = 30;
    style.colorBarTicks = 0:0.2:1;
    style.numPsiContourLevels = 15;
    style.contourLineWidth = 0.8;
end

function drawTmpStreamFrame4Views( ...
    fig, dns, meshFull, tmpFull, psi, RaStr, style)

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

    % Draw once, then copy the graphics objects to the other three axes.
    axList(1) = nexttile(tileObj);

    h = plotPsiContourOnSphere( ...
        axList(1), ...
        meshFull.phiVec, meshFull.thetaVec, ...
        psi, 1, style.numPsiContourLevels, tmpFull, style);

    % showTmpAnimation4Views plots x_2 horizontally and x_1 vertically.
    % plotPsiContourOnSphere uses the conventional x/y ordering, so swap
    % the graphics coordinates to preserve the temperature animation view.
    swapGraphicsXY(h);
    setupTmpAxes(axList(1), viewList(1, :), style);

    sourceChildren = allchild(axList(1));

    for k = 2:4
        axList(k) = nexttile(tileObj);
        copyobj(sourceChildren, axList(k));
        setupTmpAxes(axList(k), viewList(k, :), style);
    end

    for k = 1:4
        clim(axList(k), [0, 1]);
        colormap(axList(k), jet(256));
    end

    cb = colorbar(axList(4));
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';

    sgtitle( ...
        [RaStr, ' ', '$t=', num2str(dns.lastReadTime, '%.1f'), '$'], ...
        'Interpreter', 'latex', ...
        'FontSize', style.titleFontSize);

    drawnow;
end

function swapGraphicsXY(h)
    xData = h.surface.XData;
    h.surface.XData = h.surface.YData;
    h.surface.YData = xData;

    for k = 1:numel(h.contourLines)
        xData = h.contourLines(k).XData;
        h.contourLines(k).XData = h.contourLines(k).YData;
        h.contourLines(k).YData = xData;
    end
end

function setupTmpAxes(ax, viewAngle, style)
    view(ax, viewAngle);
    grid(ax, 'on');

    set(ax, 'FontSize', style.fontSize);
    set(ax, 'YDir', 'reverse');

    xlabel(ax, '$x_2$', ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');
    ylabel(ax, '$x_1$', ...
        'Rotation', 0, ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');
    zlabel(ax, '$x_3$', ...
        'Rotation', 0, ...
        'FontSize', style.labelFontSize, ...
        'Interpreter', 'latex');

    % Streamfunction contours are lifted to R = 1.003 to avoid z-fighting.
    limPad = 1.01;
    xlim(ax, [-limPad, limPad]);
    ylim(ax, [-limPad, limPad]);
    zlim(ax, [0, limPad]);

    xticks(ax, [-1, -0.5, 0, 0.5, 1]);
    yticks(ax, [-1, -0.5, 0, 0.5, 1]);
    zticks(ax, [0, 0.4, 0.7, 1]);
end
