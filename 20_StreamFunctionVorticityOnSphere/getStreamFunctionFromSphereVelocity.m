function [psi, info] = getStreamFunctionFromSphereVelocity(phiVec, thetaVec, uPhi, vTheta, R)
%GETSTREAMFUNCTIONFROMSPHEREVELOCITY Compute streamfunction on a sphere.
%
%   psi = getStreamFunctionFromSphereVelocity(phiVec, thetaVec, uPhi, vTheta)
%   psi = getStreamFunctionFromSphereVelocity(phiVec, thetaVec, uPhi, vTheta, R)
%   [psi, info] = getStreamFunctionFromSphereVelocity(...)
%
%   Matrix convention:
%       row direction    -> theta direction
%       column direction -> phi direction
%
%   Inputs:
%       phiVec   : phi coordinate vector, length nPhi
%       thetaVec : theta coordinate vector, length nTheta
%       uPhi     : velocity component in phi direction, size [nTheta, nPhi]
%       vTheta   : velocity component in theta direction, size [nTheta, nPhi]
%       R        : sphere radius, optional, default R = 1
%
%   Output:
%       psi      : streamfunction, same size as uPhi and vTheta
%       info     : diagnostic information
%
%   Streamfunction convention:
%
%       u_phi   =  (1/R) * d(psi)/d(theta)
%
%       v_theta = -(1/(R*sin(theta))) * d(psi)/d(phi)
%
%   Therefore:
%
%       d(psi)/d(theta) = R * u_phi
%       d(psi)/d(phi)   = -R * sin(theta) * v_theta
%
%   This function reconstructs psi from both velocity components:
%
%       1. Integrate R*uPhi in theta direction.
%       2. Integrate -R*sin(theta)*vTheta in phi direction.
%       3. Align the row-wise constants.
%       4. Blend the two reconstructions.
%
%   This is designed for visualization/post-processing. For a perfectly
%   divergence-free velocity field, the two reconstructions should be
%   consistent up to numerical errors.
%
%   Notes:
%       1. phi direction is treated as periodic.
%       2. phiVec may include the duplicated endpoint 2*pi.
%       3. If thetaVec includes theta = 0 or theta = pi, the pole row is
%          forced to be a single value because all phi columns correspond
%          to the same physical point.

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

    if nThetaInput < 2
        error('At least 2 theta points are required.');
    end

    if nPhiInput < 4
        error('At least 4 phi points are recommended.');
    end

    thetaVec = thetaVec(:);
    phiVec   = phiVec(:).';

    if any(diff(thetaVec) <= 0)
        error('thetaVec must be strictly increasing.');
    end

    if any(diff(phiVec) <= 0)
        error('phiVec must be strictly increasing.');
    end

    if thetaVec(1) < -1e-12 || thetaVec(end) > pi + 1e-12
        error('thetaVec should lie within [0, pi].');
    end

    % ------------------------------------------------------------
    % Check theta grid
    % ------------------------------------------------------------
    dThetaVec = diff(thetaVec);
    dTheta = dThetaVec(1);

    tolTheta = 1e-12 * max(1, abs(thetaVec(end) - thetaVec(1)));

    if max(abs(dThetaVec - dTheta)) > tolTheta
        error('thetaVec must be uniformly spaced in this version.');
    end

    % ------------------------------------------------------------
    % Handle duplicated phi endpoint
    % ------------------------------------------------------------
    tolPhi = 1e-12 * 2*pi;

    hasDuplicateEndpoint = abs((phiVec(end) - phiVec(1)) - 2*pi) < tolPhi;

    if hasDuplicateEndpoint
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
    % Check phi grid
    % ------------------------------------------------------------
    dPhiVec = diff(phiWork);
    dPhiMean = mean(dPhiVec);

    if max(abs(dPhiVec - dPhiMean)) > tolPhi
        error('phiVec must be uniformly spaced.');
    end

    periodicGap = phiWork(1) + 2*pi - phiWork(end);

    if abs(periodicGap - dPhiMean) > 100*tolPhi
        error(['phiVec must cover one full periodic interval. ', ...
               'Use either linspace(0,2*pi,nPhi) with duplicated endpoint, ', ...
               'or linspace(0,2*pi,nPhi+1); phiVec(end)=[] without duplicated endpoint.']);
    end

    dPhi = 2*pi / nPhi;

    % ------------------------------------------------------------
    % Reconstruction 1:
    % integrate dpsi/dtheta = R*uPhi
    % ------------------------------------------------------------
    psiTheta = cumtrapz(thetaVec, R * uPhiWork, 1);

    % Set gauge: remove global mean
    psiTheta = psiTheta - mean(psiTheta(:), 'omitnan');

    % ------------------------------------------------------------
    % Reconstruction 2:
    % integrate dpsi/dphi = -R*sin(theta)*vTheta
    % ------------------------------------------------------------
    sinTheta = sin(thetaVec);

    dPsi_dPhi = -R * (sinTheta .* vThetaWork);

    % For periodic psi, the phi derivative should have zero integral over phi.
    % Remove row-wise mean to avoid artificial linear drift.
    dPsi_dPhi = dPsi_dPhi - mean(dPsi_dPhi, 2, 'omitnan');

    psiPhi = zeros(nTheta, nPhi);

    for j = 2:nPhi
        psiPhi(:, j) = psiPhi(:, j-1) ...
            + 0.5 * (dPsi_dPhi(:, j-1) + dPsi_dPhi(:, j)) * dPhi;
    end

    % Remove row-wise mean of psiPhi, then align it with psiTheta row mean.
    psiPhi = psiPhi - mean(psiPhi, 2, 'omitnan');

    rowMeanTheta = mean(psiTheta, 2, 'omitnan');
    psiPhi = psiPhi + rowMeanTheta;

    % ------------------------------------------------------------
    % Blend two reconstructions
    % ------------------------------------------------------------
    psiWork = 0.5 * (psiTheta + psiPhi);

    % ------------------------------------------------------------
    % Pole treatment
    % ------------------------------------------------------------
    poleTol = 1e-12;

    isNorthPole = abs(thetaVec(1)) < poleTol;
    isSouthPole = abs(thetaVec(end) - pi) < poleTol;

    if isNorthPole
        psiWork(1, :) = mean(psiWork(1, :), 'omitnan');
    end

    if isSouthPole
        psiWork(end, :) = mean(psiWork(end, :), 'omitnan');
    end

    % ------------------------------------------------------------
    % Final gauge: set global mean to zero
    % ------------------------------------------------------------
    psiWork = psiWork - mean(psiWork(:), 'omitnan');

    % ------------------------------------------------------------
    % Restore duplicated phi endpoint if needed
    % ------------------------------------------------------------
    if restoreDuplicateEndpoint
        psi = zeros(nThetaInput, nPhiInput);

        psi(:, 1:end-1) = psiWork;
        psi(:, end) = psi(:, 1);
    else
        psi = psiWork;
    end

    % ------------------------------------------------------------
    % Diagnostics
    % ------------------------------------------------------------
    if nargout > 1
        info = struct();

        info.R = R;
        info.hasDuplicateEndpoint = hasDuplicateEndpoint;
        info.dTheta = dTheta;
        info.dPhi = dPhi;

        % Difference between theta-based and phi-based reconstructions.
        diffPsi = psiTheta - psiPhi;

        info.reconstructionDifferenceRMS = rms(diffPsi(:), 'omitnan');
        info.psiRMS = rms(psiWork(:), 'omitnan');

        if info.psiRMS > 0
            info.relativeReconstructionDifference = ...
                info.reconstructionDifferenceRMS / info.psiRMS;
        else
            info.relativeReconstructionDifference = NaN;
        end
    end

end