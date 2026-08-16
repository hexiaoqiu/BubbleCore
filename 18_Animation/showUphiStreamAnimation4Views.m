function showUphiStreamAnimation4Views(dns, timeWindow, outputResolution, ...
    storePath, limMax, frameRate)
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

    if nargin < 5 || isempty(limMax)
        limMax = 0.1;
    end

    if nargin < 6 || isempty(frameRate)
        frameRate = 30;
    end

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

            [uPhi, vTheta] = velocity2DToSph(u2d, v2d, ...
                meshFull.x2d, meshFull.y2d, meshFull.phi, meshFull.theta);

            psi = getStreamFunctionFromSphereVelocity(meshFull.phiVec, ...
                meshFull.thetaVec, ...
                uPhi, vTheta);

            drawUphiFrame4Views(fig, dns, meshFull, ...
                uPhi, psi, RaStr, style);

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
    style.colorBarTicks = linspace(-limMax,limMax,5);
    style.limMax = limMax;
end


function drawUphiFrame4Views(fig, dns, meshFull, uPhi, psi, ...
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
    
    plotPsiContourOnSphere(axList(1), ...
        meshFull.phiVec, meshFull.thetaVec, ...
        psi, 1, 15, uPhi, style);
    
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
    for k = 1:4
        clim(axList(k), [-style.limMax, style.limMax]);
        colormap(axList(k), turbo);
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
