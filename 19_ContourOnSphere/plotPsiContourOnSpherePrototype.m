function plotPsiContourOnSpherePrototype(phiVec, thetaVec, psi, R, nLevel)
%PLOTPSICONTOURONSPHERE Plot streamfunction contours on a spherical surface.
%
%   plotPsiContourOnSphere(phiVec, thetaVec, psi)
%   plotPsiContourOnSphere(phiVec, thetaVec, psi, R)
%   plotPsiContourOnSphere(phiVec, thetaVec, psi, R, nLevel)
%
%   Inputs:
%       phiVec   : phi coordinate vector, length nPhi
%       thetaVec : theta coordinate vector, length nTheta
%       psi      : streamfunction matrix, size [nTheta, nPhi]
%       R        : sphere radius, optional, default 1
%       nLevel   : number of contour levels, optional, default 30
%
%   Matrix convention:
%       row direction    -> theta
%       column direction -> phi
%
%   Coordinate convention:
%       theta = 0       : north pole
%       theta = pi/2    : equator
%       theta = pi      : south pole
%       phi             : azimuthal angle

    if nargin < 4 || isempty(R)
        R = 1;
    end

    if nargin < 5 || isempty(nLevel)
        nLevel = 30;
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

    % ------------------------------------------------------------
    % Handle duplicated phi endpoint
    % ------------------------------------------------------------
    tolPhi = 1e-12 * 2*pi;
    hasDuplicateEndpoint = abs((phiVec(end) - phiVec(1)) - 2*pi) < tolPhi;

    if hasDuplicateEndpoint
        phiWork = phiVec;
        psiWork = psi;

        % Ensure exact periodic closure for plotting
        psiWork(:, end) = psiWork(:, 1);
    else
        % Add duplicated endpoint for visual closure
        phiWork = [phiVec, phiVec(1) + 2*pi];
        psiWork = [psi, psi(:, 1)];
    end

    % ------------------------------------------------------------
    % Generate sphere surface
    % ------------------------------------------------------------
    [Phi, Theta] = meshgrid(phiWork, thetaVec);

    X = R * sin(Theta) .* cos(Phi);
    Y = R * sin(Theta) .* sin(Phi);
    Z = R * cos(Theta);

    % ------------------------------------------------------------
    % Plot base surface
    % ------------------------------------------------------------
    figure;
    surf(X, Y, Z, psiWork, ...
        'EdgeColor', 'none');

    axis equal;
    axis tight;
    hold on;
    colorbar;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('Streamfunction contours on spherical surface');

    shading interp;
    view(3);

    % ------------------------------------------------------------
    % Build contour levels
    % ------------------------------------------------------------
    psiMin = min(psiWork(:), [], 'omitnan');
    psiMax = max(psiWork(:), [], 'omitnan');

    if psiMin == psiMax
        warning('psi is constant. No contour can be plotted.');
        return;
    end

    levels = linspace(psiMin, psiMax, nLevel);

    % ------------------------------------------------------------
    % Extract contours in parameter plane: x = phi, y = theta
    % ------------------------------------------------------------
    C = contourc(phiWork, thetaVec, psiWork, levels);

    % ------------------------------------------------------------
    % Plot contours mapped to the sphere
    % ------------------------------------------------------------
    idx = 1;

    % Slightly lift contour lines above sphere to avoid z-fighting
    Rline = R * 1.002;

    while idx < size(C, 2)
        levelValue = C(1, idx);
        nPoint = C(2, idx);

        phiLine   = C(1, idx+1 : idx+nPoint);
        thetaLine = C(2, idx+1 : idx+nPoint);

        xLine = Rline * sin(thetaLine) .* cos(phiLine);
        yLine = Rline * sin(thetaLine) .* sin(phiLine);
        zLine = Rline * cos(thetaLine);

        plot3(xLine, yLine, zLine, 'k-', 'LineWidth', 0.8);

        idx = idx + nPoint + 1;
    end

    hold off;

end