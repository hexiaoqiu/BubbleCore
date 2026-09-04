function [sumUSqure, sumUphiSquare, sumVthetaSquare] = ...,
    getSumUSquareFromBatch(dns, batch, workMesh, interpolationMethod)
%CALCSUMTMPTHETABATCH Interpolate tmp snapshots and sum their theta profiles.

    if nargin < 4 || isempty(interpolationMethod)
        interpolationMethod = 'linear';
    end

    numSteps = batch.numSteps;
    nTheta = workMesh.nTheta;
    nPhi = workMesh.nPhi;
    x2d = workMesh.x2d;
    y2d = workMesh.y2d;
    phi = workMesh.phi;
    theta = workMesh.theta;

    u2dOrg = batch.u2dOrg;
    v2dOrg = batch.v2dOrg;
    n1 = batch.n1;
    n2 = batch.n2;
    timeTable = batch.time;

    x2dGauche = dns.x2dGauche;
    x2dDroit = dns.x2dDroit;
    y2dHaut = dns.y2dHaut;
    y2dBas = dns.y2dBas;

    sumUSqure = zeros(nTheta, nPhi);
    sumUphiSquare = zeros(nTheta, nPhi);
    sumVthetaSquare = zeros(nTheta, nPhi);
    parfor idxStep = 1:numSteps
        [~, ~, x2dU,y2dU,x2dV,y2dV] = buildMeshOrg( ...
            x2dGauche, x2dDroit, y2dHaut, y2dBas, ...
            n1(idxStep), n2(idxStep));

        u2d = interp2(x2dU, y2dU, u2dOrg{idxStep}, ...
            x2d, y2d, interpolationMethod);
        v2d = interp2(x2dV, y2dV, v2dOrg{idxStep}, ...
            x2d, y2d, interpolationMethod);
        [uPhi, vTheta] = velocity2DToSph( ...
            u2d, v2d, x2d, y2d, phi, theta);
        sumUSqure = sumUSqure + uPhi.^2 + vTheta.^2;
        sumUphiSquare = sumUphiSquare + uPhi.^2;
        sumVthetaSquare = sumVthetaSquare + vTheta.^2;

        disp([ ...
            'Processing: batch idx = ', num2str(idxStep, '%d'), ...
            ' DNS time = ', num2str(timeTable(idxStep), '%g') ...
            ])
    end

end
