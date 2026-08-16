function omegaR = getOmegaRFromSphereVelocity(uPhi, vTheta, phiVec, thetaVec, R)
%GETOMEGARFROMSPHEREVELOCITY Compute radial vorticity on a spherical surface.
%
%   omegaR = getOmegaRFromSphereVelocity(uPhi, vTheta, phiVec, thetaVec)
%   omegaR = getOmegaRFromSphereVelocity(uPhi, vTheta, phiVec, thetaVec, R)
%
%   Matrix convention:
%       row direction    -> theta direction
%       column direction -> phi direction
%
%   Inputs:
%       uPhi     : velocity component in phi direction, size [nTheta, nPhi]
%       vTheta   : velocity component in theta direction, size [nTheta, nPhi]
%       phiVec   : phi coordinate vector, length nPhi
%       thetaVec : theta coordinate vector, length nTheta
%       R        : sphere radius, optional, default R = 1
%
%   Output:
%       omegaR   : radial vorticity, same size as input uPhi
%
%   Formula:
%
%       omega_r = 1/(R*sin(theta)) * ...
%                 [ d/dtheta(u_phi * sin(theta)) - d(v_theta)/dphi ]
%
%   Notes:
%
%       This function accepts both kinds of phi grids:
%
%       Case 1: duplicated endpoint included
%           phiVec = linspace(0, 2*pi, nPhi);
%
%           In this case, phi = 0 and phi = 2*pi are duplicate physical lines.
%           The last column is ignored internally during computation, and the
%           output satisfies:
%
%               omegaR(:,end) = omegaR(:,1)
%
%       Case 2: duplicated endpoint not included
%           phiVec = linspace(0, 2*pi, nPhi+1);
%           phiVec(end) = [];
%
%           In this case, all columns are used directly.
%
%   Pole treatment:
%
%       At theta = 0 and theta = pi, the spherical-coordinate formula is
%       coordinate-singular. The pole values are computed from
%       circulation / cap area.
%
%       The pole is one physical point, so the whole pole row is assigned
%       the same value.
%       The pole value is approximated by the area-averaged vorticity
%       over the first polar cap. For a smooth field, this approximation
%       converges to the pointwise pole vorticity at second order.

    % ------------------------------------------------------------
    % Optional radius
    % ------------------------------------------------------------
    if nargin < 5 || isempty(R)
        R = 1;
    end

    if R <= 0
        error('R must be positive.');
    end

    % ------------------------------------------------------------
    % Basic checks
    % ------------------------------------------------------------
    if ~isequal(size(uPhi), size(vTheta))
        error('uPhi and vTheta must have the same size.');
    end

    [nThetaInput, nPhiInput] = size(uPhi);

    if numel(thetaVec) ~= nThetaInput
        error('Length of thetaVec must match the number of rows of uPhi.');
    end

    if numel(phiVec) ~= nPhiInput
        error('Length of phiVec must match the number of columns of uPhi.');
    end

    if nThetaInput < 3
        error('At least 3 theta points are required.');
    end

    if nPhiInput < 4
        error('At least 4 phi points are recommended.');
    end

    thetaVec = thetaVec(:);
    phiVec   = phiVec(:).';

    % ------------------------------------------------------------
    % Check thetaVec
    % ------------------------------------------------------------
    if any(diff(thetaVec) <= 0)
        error('thetaVec must be strictly increasing.');
    end

    dThetaVec = diff(thetaVec);
    dTheta = dThetaVec(1);

    tolTheta = 1e-12 * max(1, abs(thetaVec(end) - thetaVec(1)));

    if max(abs(dThetaVec - dTheta)) > tolTheta
        error('thetaVec must be uniformly spaced in this version.');
    end

    if thetaVec(1) < -1e-12 || thetaVec(end) > pi + 1e-12
        error('thetaVec should lie within [0, pi].');
    end

    % ------------------------------------------------------------
    % Detect whether phiVec contains duplicated endpoint
    % ------------------------------------------------------------
    if any(diff(phiVec) <= 0)
        error('phiVec must be strictly increasing.');
    end

    tolPhi = 1e-12 * 2*pi;

    hasDuplicateEndpoint = abs((phiVec(end) - phiVec(1)) - 2*pi) < tolPhi;

    if hasDuplicateEndpoint
        % phi = 0 and phi = 2*pi are the same physical line.
        % Ignore the last column internally.
        phiWork    = phiVec(1:end-1);
        uPhiWork   = uPhi(:, 1:end-1);
        vThetaWork = vTheta(:, 1:end-1);

        restoreDuplicateEndpoint = true;
    else
        phiWork    = phiVec;
        uPhiWork   = uPhi;
        vThetaWork = vTheta;

        restoreDuplicateEndpoint = false;
    end

    [nTheta, nPhi] = size(uPhiWork);

    if nPhi < 3
        error('At least 3 non-duplicated phi points are required.');
    end

    % ------------------------------------------------------------
    % Check phiWork as a periodic uniform grid without duplicated endpoint
    % ------------------------------------------------------------
    dPhiVec = diff(phiWork);
    dPhiMean = mean(dPhiVec);

    if max(abs(dPhiVec - dPhiMean)) > tolPhi
        error('phiVec must be uniformly spaced.');
    end

    % For a full periodic grid without duplicate endpoint, the periodic gap
    % from the last point back to the first point plus 2*pi should equal dPhi.
    periodicGap = phiWork(1) + 2*pi - phiWork(end);

    if abs(periodicGap - dPhiMean) > 100*tolPhi
        error(['phiVec must cover one full periodic interval. ', ...
               'Use either linspace(0,2*pi,nPhi) with duplicated endpoint, ', ...
               'or linspace(0,2*pi,nPhi+1); phiVec(end)=[] without duplicated endpoint.']);
    end

    % Use exact periodic spacing.
    dPhi = 2*pi / nPhi;

    % ------------------------------------------------------------
    % Main formula away from poles
    % ------------------------------------------------------------
    sinTheta = sin(thetaVec);

    uPhiSinTheta = uPhiWork .* sinTheta;

    d_uPhiSinTheta_dTheta = zeros(size(uPhiWork));

    % Interior theta derivative: centered difference
    d_uPhiSinTheta_dTheta(2:end-1, :) = ...
        (uPhiSinTheta(3:end, :) - uPhiSinTheta(1:end-2, :)) / (2*dTheta);

    % Boundary theta derivative: second-order one-sided difference
    d_uPhiSinTheta_dTheta(1, :) = ...
        (-3*uPhiSinTheta(1, :) + 4*uPhiSinTheta(2, :) - uPhiSinTheta(3, :)) ...
        / (2*dTheta);

    d_uPhiSinTheta_dTheta(end, :) = ...
        (3*uPhiSinTheta(end, :) - 4*uPhiSinTheta(end-1, :) + uPhiSinTheta(end-2, :)) ...
        / (2*dTheta);

    % Phi derivative: periodic centered difference
    d_vTheta_dPhi = ...
        (circshift(vThetaWork, [0, -1]) - circshift(vThetaWork, [0, 1])) / (2*dPhi);

    % ------------------------------------------------------------
    % omega_r away from poles
    % ------------------------------------------------------------
    omegaWork = zeros(size(uPhiWork));

    poleTol = 1e-12;
    nonPoleRows = abs(sinTheta) >= poleTol;

    omegaWork(nonPoleRows, :) = ...
        (d_uPhiSinTheta_dTheta(nonPoleRows, :) - d_vTheta_dPhi(nonPoleRows, :)) ...
        ./ (R * sinTheta(nonPoleRows));

    % ------------------------------------------------------------
    % North pole correction: theta = 0
    % ------------------------------------------------------------
    isNorthPole = abs(thetaVec(1)) < poleTol;

    if isNorthPole
        thetaRing = thetaVec(2);
        uPhiRing  = uPhiWork(2, :);

        % Circulation around the first off-pole latitude circle:
        %
        %   Gamma = integral u_phi * R*sin(theta) dphi
        %
        circulation = sum(uPhiRing) * R * sin(thetaRing) * dPhi;

        % Area of the north polar cap:
        %
        %   A_cap = 2*pi*R^2*(1 - cos(theta))
        %
        capArea = 2*pi*R^2*(1 - cos(thetaRing));

        omegaPole = circulation / capArea;

        % The pole is one physical point.
        omegaWork(1, :) = omegaPole;
    end

    % ------------------------------------------------------------
    % South pole correction: theta = pi
    % ------------------------------------------------------------
    isSouthPole = abs(thetaVec(end) - pi) < poleTol;

    if isSouthPole
        thetaRing = thetaVec(end-1);
        uPhiRing  = uPhiWork(end-1, :);

        % Circulation along increasing phi:
        circulation = sum(uPhiRing) * R * sin(thetaRing) * dPhi;

        % Area of the south polar cap:
        %
        %   A_cap = 2*pi*R^2*(1 + cos(theta))
        %
        capArea = 2*pi*R^2*(1 + cos(thetaRing));

        % Minus sign due to the boundary orientation of the south cap.
        omegaPole = -circulation / capArea;

        % The south pole is one physical point.
        omegaWork(end, :) = omegaPole;
    end

    % ------------------------------------------------------------
    % Restore duplicated phi endpoint if needed
    % ------------------------------------------------------------
    if restoreDuplicateEndpoint
        omegaR = zeros(nThetaInput, nPhiInput);

        omegaR(:, 1:end-1) = omegaWork;

        % phi = 2*pi is the same physical line as phi = 0
        omegaR(:, end) = omegaR(:, 1);
    else
        omegaR = omegaWork;
    end

end