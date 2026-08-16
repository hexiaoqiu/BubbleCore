function showTmpAnimation4Views(dns, timeWindow, outputResolution, storePath, frameRate)
%SHOWTMPANIMATION4VIEWS Show a four-view temperature animation for one DNS case.
%
% Usage:
%   showTmpAnimation4Views(dns, timeWindow, outputResolution)
%   showTmpAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showTmpAnimation4Views(dns, timeWindow, outputResolution, storePath, frameRate)
%
% Inputs:
%   dns              DNS structure created by setDnsCase/setAsmCase.
%   timeWindow       Two-element vector: [animationStartTime, animationEndTime].
%   outputResolution Two-element vector: [figureWidth, figureHeight].
%   storePath        Optional. If non-empty, save a video in this folder.
%                    Linux uses Motion JPEG AVI; Windows/macOS use MPEG-4.
%   frameRate        Optional. Video frame rate. Default: 30.

    narginchk(3, 5);

    [animationStartTime, animationEndTime] = parseTimeWindow(dns, timeWindow);
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

    % Use a denser spherical mesh than the original DNS mesh for smoother
    % animation frames. n1 controls longitude and n2 controls latitude.
    nPhi = max(dns.n1(:))*2;
    nTheta = max(dns.n2(:))*2;
    meshFull = obtainSphMesh(0, 2*pi, 0, pi/2, nPhi, nTheta);
    % meshCut = obtainSphMesh(0, 2*pi, dns.theta_c, pi/2, nPhi, nTheta);

    style = getAnimationStyle(figPosition);
    RaStr = dnsGetLatexRa(dns);
    % AStr = asmGetLatexA(dns);

    videoFile = [];
    videoIsOpen = false;
    if storeVideoFile == true
        if exist(storePath, 'dir') ~= 7
            mkdir(storePath);
        end
        videoFile = openVideoFile(dns, storePath, frameRate,'Tmp');
        videoIsOpen = true;
    end

    fig = figure();
    set(fig, 'position', figPosition);

    % Start from the requested time window even if the input dns was left
    % open by previous inspection code.
    if isfield(dns, 'readNowSubCaseIdx') && dns.readNowSubCaseIdx ~= -1
        dns = asmFinishRead(dns);
    end

    try
        while dns.nextReadTime <= animationEndTime
            if dns.readCounter == 0
                [dns, tmpOrg, ~, ~, ~] = asmInitRead(dns, animationStartTime);
            else
                [dns, tmpOrg, ~, ~, ~] = asmReadOneStepForward(dns);
            end

            disp(['time = ', num2str(dns.lastReadTime, '%g')])

            tmpFull = interp2( ...
                dns.x2dS{dns.readNowSubCaseIdx}, ...
                dns.y2dS{dns.readNowSubCaseIdx}, ...
                tmpOrg, ...
                meshFull.x2d, ...
                meshFull.y2d, ...
                "linear");

            % tmpCut = interp2( ...
            %     dns.x2dS{dns.readNowSubCaseIdx}, ...
            %     dns.y2dS{dns.readNowSubCaseIdx}, ...
            %     tmpOrg, ...
            %     meshCut.x2d, ...
            %     meshCut.y2d, ...
            %     "linear");

            drawTmpFrame4Views(fig, dns, meshFull, ...
                tmpFull, RaStr, style);

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
    style.tmpContourLevel = 0:0.05:1;
end

function drawTmpFrame4Views(fig, dns, meshFull, tmpFull, ...
    RaStr, style)

    clf(fig);
    tileObj = tiledlayout(fig, 2, 2, 'TileSpacing', 'Compact');

    ax = nexttile(tileObj);
    plotTmpSurf(ax, meshFull, tmpFull, [45, 30], style);
    % plotTmpContourOnSphere(ax, meshFull, tmpFull, ...
    %     style.tmpContourLevel, [0,0.85*pi/2]);
    
    ax = nexttile(tileObj);
    plotTmpSurf(ax, meshFull, tmpFull, [135, 30], style);
    % plotTmpContourOnSphere(ax, meshFull, tmpFull, ...
    %     style.tmpContourLevel, [0,0.85*pi/2]);
    
    ax = nexttile(tileObj);
    plotTmpSurf(ax, meshFull, tmpFull, [225, 30], style);
    % plotTmpContourOnSphere(ax, meshFull, tmpFull, ...
    %     style.tmpContourLevel, [0,0.85*pi/2]);
    
    ax = nexttile(tileObj);
    plotTmpSurf(ax, meshFull, tmpFull, [0, 90], style);
    % plotTmpContourOnSphere(ax, meshFull, tmpFull, ...
    %     style.tmpContourLevel, [0,0.85*pi/2]);

    cb = colorbar;
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';

    sgtitle( ...
        [RaStr, ' ', '$t=', num2str(dns.lastReadTime, '%.1f'), '$'], ...
        'interpreter', 'latex', ...
        'FontSize', style.titleFontSize);

    drawnow;
end

function plotTmpSurf(ax, meshFull, tmpFull, viewAngle, style)
    surf(ax, meshFull.y3d, meshFull.x3d, meshFull.z3d, tmpFull);
    view(ax, viewAngle);
    colormap(ax, jet(256));
    shading(ax, 'interp');
    grid(ax, 'on');
    clim(ax, [0, 1]);
    format3DAxes(ax, style);
end

function plotTmpPhiTheta(ax, dns, meshCut, tmpCut, style)
    pcolor(ax, meshCut.phi, meshCut.theta, tmpCut);
    colormap(ax, jet(256));
    shading(ax, 'interp');
    grid(ax, 'on');
    clim(ax, [0, 1]);

    set(ax, 'FontSize', style.fontSize);
    set(ax, 'TickLabelInterpreter', 'latex');
    xlabel(ax, '$\phi$', 'FontSize', style.labelFontSize, 'interpreter', 'latex');
    ylabel(ax, '$\theta$', 'Rotation', 0, ...
        'FontSize', style.labelFontSize, 'interpreter', 'latex');
    set(ax, 'YDir', 'reverse');
    xlim(ax, [0, 2*pi]);
    xticks(ax, deg2rad(0:90:360));
    xticklabels(ax, {'$0^{\circ}$', '$90^{\circ}$', ...
        '$180^{\circ}$', '$270^{\circ}$', '$360^{\circ}$'});
    ylim(ax, [dns.theta_c, deg2rad(90)]);
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

function plotTmpContourOnSphere( ...
    ax, meshFull, tmpFull, contourLevels, thetaRange)
%PLOTTMCONTOURONSPHERE Plot temperature contours on a spherical surface.
%
% Inputs:
%   ax              Target axes.
%   meshFull        Spherical mesh structure.
%   tmpFull         Temperature field on the spherical mesh.
%   contourLevels   Temperature contour levels.
%   thetaRange      Two-element vector:
%                   [thetaMin, thetaMax], in radians.
%
% Example:
%   plotTmpContourOnSphere( ...
%       ax, meshFull, tmpFull, 0.1:0.1:0.9, ...
%       [0, pi/4]);
%
% This plots contours only in:
%       0 <= theta <= pi/4

    arguments
        ax
        meshFull struct
        tmpFull double
        contourLevels double
        thetaRange (1, 2) double
    end

    thetaMin = thetaRange(1);
    thetaMax = thetaRange(2);

    if thetaMin > thetaMax
        error('plotTmpContourOnSphere:BadThetaRange', ...
            'thetaRange(1) must be smaller than or equal to thetaRange(2).');
    end

    if ~isequal(size(tmpFull), size(meshFull.x3d), ...
            size(meshFull.y3d), size(meshFull.z3d))
        error('plotTmpContourOnSphere:SizeMismatch', ...
            ['tmpFull, meshFull.x3d, meshFull.y3d, and ', ...
             'meshFull.z3d must have the same size.']);
    end

    % -------------------------------------------------------------
    % Calculate colatitude theta from the Cartesian coordinates:
    %
    %       theta = acos(z/r)
    %
    % This avoids depending on whether meshFull.theta is stored as
    % a vector or a two-dimensional matrix.
    % -------------------------------------------------------------
    radius = sqrt( ...
        meshFull.x3d.^2 + ...
        meshFull.y3d.^2 + ...
        meshFull.z3d.^2);

    cosTheta = meshFull.z3d ./ radius;

    % Avoid acos receiving values slightly outside [-1, 1] because
    % of floating-point roundoff.
    cosTheta = max(-1, min(1, cosTheta));

    thetaGrid = acos(cosTheta);

    % Mask the region outside the requested colatitude interval.
    tmpMasked = tmpFull;

    outsideThetaRange = ...
        thetaGrid < thetaMin | ...
        thetaGrid > thetaMax;

    tmpMasked(outsideThetaRange) = NaN;

    % Generate contours only in the unmasked region.
    contourMatrix = contourc(tmpMasked, contourLevels);

    [nRow, nCol] = size(tmpFull);

    colIndex = 1:nCol;
    rowIndex = 1:nRow;

    % Slightly move contours away from the spherical surface to avoid
    % z-fighting between the contour lines and the surface.
    radialOffset = 1.002;

    holdState = ishold(ax);
    hold(ax, 'on');

    idx = 1;

    while idx < size(contourMatrix, 2)

        contourValue = contourMatrix(1, idx); %#ok<NASGU>
        numPoints = contourMatrix(2, idx);

        pointRange = idx + (1:numPoints);

        contourCol = contourMatrix(1, pointRange);
        contourRow = contourMatrix(2, pointRange);

        % Interpolate the Cartesian coordinates of the spherical surface.
        %
        % Notice that the plotting coordinate convention is:
        %   plot x-coordinate <- meshFull.y3d
        %   plot y-coordinate <- meshFull.x3d
        xContour = interp2( ...
            colIndex, rowIndex, meshFull.y3d, ...
            contourCol, contourRow, 'linear');

        yContour = interp2( ...
            colIndex, rowIndex, meshFull.x3d, ...
            contourCol, contourRow, 'linear');

        zContour = interp2( ...
            colIndex, rowIndex, meshFull.z3d, ...
            contourCol, contourRow, 'linear');

        plot3(ax, ...
            radialOffset*xContour, ...
            radialOffset*yContour, ...
            radialOffset*zContour, ...
            'k-', ...
            'LineWidth', 0.8);

        idx = idx + numPoints + 1;
    end

    if ~holdState
        hold(ax, 'off');
    end
end