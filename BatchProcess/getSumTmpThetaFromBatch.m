function [sumTmpTheta] = getSumTmpThetaFromBatch(dns, batch, postMesh)
%CALCSUMTMPTHETABATCH Interpolate tmp snapshots and sum their theta profiles.

    numSteps = batch.numSteps;
    nTheta = postMesh.nTheta;
    x2d = postMesh.x2d;
    y2d = postMesh.y2d;

    tmpOrg = batch.tmpOrg;
    n1 = batch.n1;
    n2 = batch.n2;
    timeTable = batch.time;

    x2dGauche = dns.x2dGauche;
    x2dDroit = dns.x2dDroit;
    y2dHaut = dns.y2dHaut;
    y2dBas = dns.y2dBas;

    sumTmpTheta = zeros(nTheta, 1);
    if postMesh.nPhi < 2
        error('getSumTmpThetaFromBatch:InsufficientPhiPoints', ...
            'At least two phi points are required.');
    end
    parfor idxStep = 1:numSteps
        [x2dS, y2dS] = buildMeshOrg( ...
            x2dGauche, x2dDroit, y2dHaut, y2dBas, ...
            n1(idxStep), n2(idxStep));

        tmp = interp2(x2dS, y2dS, tmpOrg{idxStep}, x2d, y2d, "spline");
        % phi = 0 and phi = 2*pi are the same physical point. Exclude the
        % final duplicated endpoint from the periodic phi average.
        sumTmpTheta = sumTmpTheta + mean(tmp(:, 1:end-1), 2);

        disp([ ...
            'Processing: batch idx = ', num2str(idxStep, '%d'), ...
            ' DNS time = ', num2str(timeTable(idxStep), '%g') ...
            ])
    end

end
