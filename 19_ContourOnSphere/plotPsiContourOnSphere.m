function h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi, R, nLevel, omegaR, style)
%PLOTPSICONTOURONSPHERE Plot streamfunction contours on a spherical surface.
%
%   h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi)
%   h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi, R)
%   h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi, R, nLevel)
%   h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi, R, nLevel, omegaR)
%   h = plotPsiContourOnSphere(ax, phiVec, thetaVec, psi, R, nLevel, omegaR, style)
%
%   Inputs:
%       ax       : target axes handle
%       phiVec   : phi coordinate vector, length nPhi
%       thetaVec : theta coordinate vector, length nTheta
%       psi      : streamfunction matrix, size [nTheta, nPhi]
%       R        : sphere radius, optional, default 1
%       nLevel   : number of psi contour levels, optional, default 30
%       omegaR   : optional scalar field used as sphere background color
%       style    : plot style structure
%
%   Output:
%       h        : structure containing graphics handles
%
%   Notes:
%       1. psi is used for contour lines.
%       2. omegaR is used for sphere surface color.
%       3. This function does not set clim, colormap, or colorbar.
%       4. The pole singularity is regularized before calling contourc.

    % ------------------------------------------------------------
    % Optional inputs
    % ------------------------------------------------------------
    if nargin < 5 || isempty(R)
        R = 1;
    end

    if nargin < 6 || isempty(nLevel)
        nLevel = 30;
    end

    if nargin < 7 || isempty(omegaR)
        omegaR = psi;
    end

    if nargin < 8 || isempty(style)
        style = struct();
    end

    if ~isfield(style, 'fontSize')
        style.fontSize = 20;
    end

    if ~isfield(style, 'labelFontSize')
        style.labelFontSize = 25;
    end

    if ~isfield(style, 'contourLineWidth')
        style.contourLineWidth = 0.45;
    end

    % ------------------------------------------------------------
    % Input checks
    % ------------------------------------------------------------
    if isempty(ax) || ~isgraphics(ax, 'axes')
        error('The first input ax must be a valid axes handle.');
    end

    if R <= 0
        error('R must be positive.');
    end

    thetaVec = thetaVec(:);
    phiVec   = phiVec(:).';

    [nTheta, nPhi] = size(psi);

    if numel(thetaVec) ~= nTheta
        error('Length of thetaVec must match the number of rows of psi.');
    end

    if numel(phiVec) ~= nPhi
        error('Length of phiVec must match the number of columns of psi.');
    end

    if ~isequal(size(omegaR), size(psi))
        error('omegaR must have the same size as psi.');
    end

    if any(diff(thetaVec) <= 0)
        error('thetaVec must be strictly increasing.');
    end

    if any(diff(phiVec) <= 0)
        error('phiVec must be strictly increasing.');
    end

    % ------------------------------------------------------------
    % Handle duplicated phi endpoint
    % ------------------------------------------------------------
    tolPhi = 1e-12 * 2*pi;
    hasDuplicateEndpoint = abs((phiVec(end) - phiVec(1)) - 2*pi) < tolPhi;

    if hasDuplicateEndpoint
        phiWork = phiVec;

        psiWork = psi;
        psiWork(:, end) = psiWork(:, 1);

        colorWork = omegaR;
        colorWork(:, end) = colorWork(:, 1);
    else
        phiWork = [phiVec, phiVec(1) + 2*pi];

        psiWork = [psi, psi(:, 1)];
        colorWork = [omegaR, omegaR(:, 1)];
    end

    % ------------------------------------------------------------
    % Generate sphere surface
    % ------------------------------------------------------------
    [Phi, Theta] = meshgrid(phiWork, thetaVec);

    X = R * sin(Theta) .* cos(Phi);
    Y = R * sin(Theta) .* sin(Phi);
    Z = R * cos(Theta);

    % ------------------------------------------------------------
    % Prepare axes
    % ------------------------------------------------------------
    holdState = ishold(ax);
    hold(ax, 'on');

    h = struct();

    % ------------------------------------------------------------
    % Plot opaque sphere surface
    % ------------------------------------------------------------
    h.surface = surf(ax, X, Y, Z, colorWork, ...
        'EdgeColor', 'none', ...
        'FaceColor', 'interp', ...
        'FaceAlpha', 1.0, ...
        'FaceLighting', 'none', ...
        'SpecularStrength', 0, ...
        'DiffuseStrength', 1, ...
        'AmbientStrength', 1);

    % ------------------------------------------------------------
    % Extract psi contours with pole regularization
    % ------------------------------------------------------------
    psiMin = min(psiWork(:), [], 'omitnan');
    psiMax = max(psiWork(:), [], 'omitnan');

    h.contourLines = gobjects(0);

    if psiMin == psiMax
        warning('psi is constant. No contour lines are plotted.');
    else
        % Do not include exact extrema as contour levels.
        levels = linspace(psiMin, psiMax, nLevel + 2);
        levels = levels(2:end-1);

        [phiContour, thetaContour, psiContour] = ...
            buildPoleRegularizedContourGrid(phiWork, thetaVec, psiWork);

        C = contourc(phiContour, thetaContour, psiContour, levels);

        % Lift contour lines slightly above the sphere to avoid z-fighting.
        Rline = R * 1.003;

        idx = 1;
        count = 0;

        while idx < size(C, 2)
            nPoint = C(2, idx);

            phiLine   = C(1, idx+1 : idx+nPoint);
            thetaLine = C(2, idx+1 : idx+nPoint);

            xLine = Rline * sin(thetaLine) .* cos(phiLine);
            yLine = Rline * sin(thetaLine) .* sin(phiLine);
            zLine = Rline * cos(thetaLine);

            count = count + 1;

            h.contourLines(count, 1) = plot3(ax, xLine, yLine, zLine, ...
                'k-', ...
                'LineWidth', style.contourLineWidth);

            idx = idx + nPoint + 1;
        end
    end

    % ------------------------------------------------------------
    % Axes appearance
    % ------------------------------------------------------------
    axis(ax, 'tight');
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

    view(ax, 3);

    if ~holdState
        hold(ax, 'off');
    end

end


function [phiContour, thetaContour, psiContour] = ...
    buildPoleRegularizedContourGrid(phiWork, thetaVec, psiWork)
%BUILD POLEREGULARIZED CONTOUR GRID
%
%   contourc works on a rectangular parameter plane. However, theta = 0
%   and theta = pi are coordinate singularities on a sphere. This function
%   adds ghost rows across the pole before calling contourc.
%
%   North pole extension:
%
%       psi(-theta, phi) = psi(theta, phi + pi)
%
%   South pole extension:
%
%       psi(pi + alpha, phi) = psi(pi - alpha, phi + pi)

    thetaVec = thetaVec(:);
    phiWork  = phiWork(:).';

    [nTheta, nPhiInput] = size(psiWork);

    if numel(thetaVec) ~= nTheta
        error('thetaVec length does not match psiWork.');
    end

    if numel(phiWork) ~= nPhiInput
        error('phiWork length does not match psiWork.');
    end

    % ------------------------------------------------------------
    % Remove duplicated phi endpoint if present
    % ------------------------------------------------------------
    tolPhi = 1e-12 * 2*pi;
    hasDuplicateEndpoint = abs((phiWork(end) - phiWork(1)) - 2*pi) < tolPhi;

    if hasDuplicateEndpoint
        phiNoDup = phiWork(1:end-1);
        psiNoDup = psiWork(:, 1:end-1);
    else
        phiNoDup = phiWork;
        psiNoDup = psiWork;
    end

    nPhi = numel(phiNoDup);

    thetaExt = thetaVec;
    psiExt = psiNoDup;

    poleTol = 1e-12;

    % Number of ghost rows across each pole.
    nGhost = min(3, nTheta - 1);

    % ------------------------------------------------------------
    % North pole regularization
    % ------------------------------------------------------------
    if abs(thetaVec(1)) < poleTol && nGhost >= 1

        thetaGhostNorth = zeros(nGhost, 1);
        psiGhostNorth = zeros(nGhost, nPhi);

        for g = 1:nGhost
            % Use rows nGhost+1, ..., 2, reversed, so theta stays increasing.
            srcRow = nGhost - g + 2;

            thetaGhostNorth(g) = -thetaVec(srcRow);

            psiGhostNorth(g, :) = shiftScalarRowByPi( ...
                psiNoDup(srcRow, :), phiNoDup);
        end

        thetaExt = [thetaGhostNorth; thetaExt];
        psiExt = [psiGhostNorth; psiExt];
    end

    % ------------------------------------------------------------
    % South pole regularization
    % ------------------------------------------------------------
    if abs(thetaVec(end) - pi) < poleTol && nGhost >= 1

        thetaGhostSouth = zeros(nGhost, 1);
        psiGhostSouth = zeros(nGhost, nPhi);

        for g = 1:nGhost
            % Use rows end-1, end-2, ...
            srcRow = nTheta - g;

            thetaGhostSouth(g) = 2*pi - thetaVec(srcRow);

            psiGhostSouth(g, :) = shiftScalarRowByPi( ...
                psiNoDup(srcRow, :), phiNoDup);
        end

        thetaExt = [thetaExt; thetaGhostSouth];
        psiExt = [psiExt; psiGhostSouth];
    end

    % ------------------------------------------------------------
    % Add duplicated phi endpoint for periodic closure
    % ------------------------------------------------------------
    phiContour = [phiNoDup, phiNoDup(1) + 2*pi];
    thetaContour = thetaExt;
    psiContour = [psiExt, psiExt(:, 1)];

end


function rowShifted = shiftScalarRowByPi(row, phiNoDup)
%SHIFTSCALARROWBYPI Shift a periodic scalar row by pi in phi.
%
%   rowShifted(phi) = row(phi + pi)

    row = row(:).';
    phiNoDup = phiNoDup(:).';

    nPhi = numel(phiNoDup);

    if numel(row) ~= nPhi
        error('row and phiNoDup must have the same length.');
    end

    phi0 = phiNoDup(1);

    phiExt = [phiNoDup, phiNoDup(1) + 2*pi];
    rowExt = [row, row(1)];

    phiQuery = phiNoDup + pi;
    phiQuery = mod(phiQuery - phi0, 2*pi) + phi0;

    rowShifted = interp1(phiExt, rowExt, phiQuery, 'linear');

end