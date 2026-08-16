function showUphiAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, uPhiLim, frameRate)
%SHOWTMPANIMATION4VIEWS Show a four-view U in phi direction animation for 
% one DNS case.
%
% Usage:
%   showUphiAnimation4Views(dns, timeWindow, outputResolution)
%   showUphiAnimation4Views(dns, timeWindow, outputResolution, storePath)
%   showUphiAnimation4Views(dns, timeWindow, outputResolution, storePath, frameRate)
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

    if nargin < 6 || isempty(frameRate)
        frameRate = 30;
    end
    
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

    try
        while dns.nextReadTime <= animationEndTime
            if dns.readCounter == 0
                [dns, ~, u2dOrg, v2dOrg, ~] = asmInitRead(dns, animationStartTime);
            else
                [dns, ~, u2dOrg, v2dOrg, ~] = asmReadOneStepForward(dns);
            end

            disp(['time = ', num2str(dns.lastReadTime, '%g')])

            u2d = interp2(dns.x2dU{dns.readNowSubCaseIdx}, ...
                dns.y2dU{dns.readNowSubCaseIdx}, ...
                u2dOrg, meshFull.x2d, meshFull.y2d,"spline");

            v2d = interp2(dns.x2dV{dns.readNowSubCaseIdx}, ...
                dns.y2dV{dns.readNowSubCaseIdx}, ...
                v2dOrg, meshFull.x2d, meshFull.y2d,"spline");

            [uPhi, ~] = velocity2DToSph(u2d, v2d, ...
                meshFull.x2d, meshFull.y2d, meshFull.phi, meshFull.theta);


            drawUphiFrame4Views(fig, dns, meshFull, ...
                uPhi, RaStr, style);

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


function style = getAnimationStyle(figPosition, uPhiLim)
    style.figPosition = figPosition;
    style.fontSize = 20;
    style.labelFontSize = 25;
    style.titleFontSize = 30;
    style.colorBarTicks = linspace(uPhiLim(1),uPhiLim(2),5);
    style.lim = uPhiLim;
end


function drawUphiFrame4Views(fig, dns, meshFull, uPhi, ...
    RaStr, style)

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
    
    % ------------------------------------------------------------
    % 1. First axes: really draw the sphere and psi contours
    % ------------------------------------------------------------
    axList(1) = nexttile(tileObj);
    
    plotUphiSurf(axList(1), meshFull, uPhi, [45, 30], style);
    
    setupAxes(axList(1), viewList(1, :), style);
    
    % ------------------------------------------------------------
    % 2. Other axes: copy graphics objects from the first axes
    % ------------------------------------------------------------
    sourceChildren = allchild(axList(1));
    
    for k = 2:4
        axList(k) = nexttile(tileObj);
    
        copyobj(sourceChildren, axList(k));
    
        setupAxes(axList(k), viewList(k, :), style);
    end
    
    % ------------------------------------------------------------
    % 3. Shared colormap and colorbar
    % ------------------------------------------------------------
    cmap = crameri('vik', 256);
    for k = 1:4
        clim(axList(k), style.lim);
        colormap(axList(k), cmap);
    end
    
    cb = colorbar(axList(4));
    cb.Ticks = style.colorBarTicks;
    cb.TickLabelInterpreter = 'latex';
    cb.Layout.Tile = 'east';
    
    sgtitle( ...
        [RaStr, ' $t=', num2str(dns.lastReadTime, '%.2f'), '$'], ...
        'Interpreter', 'latex', ...
        'FontSize', style.titleFontSize);
    
    drawnow;

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


function plotUphiSurf(ax, meshFull, tmpFull, viewAngle, style)
    surf(ax, meshFull.y3d, meshFull.x3d, meshFull.z3d, tmpFull);
    % surf(ax, meshFull.y3d, meshFull.x3d, tmpFull);
    view(ax, viewAngle);
    colormap(ax, bluewhitered(256));
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