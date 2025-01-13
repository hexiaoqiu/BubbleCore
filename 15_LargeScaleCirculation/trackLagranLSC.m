function [lagranLSC] = trackLagranLSC(x,lagranLSCOld,LSC)
    lagranLSC = lagranLSCOld;
    numLagrangLSC = numel(lagranLSCOld);
    idxLagranLSCToLSC = zeros(numLagrangLSC,1);
    length = x(end);

    for i = 1:numLagrangLSC
        [center] = getIntervalCenter(length,lagranLSCOld(i));
        numCLSC = numel(LSC);
        distance = zeros(numCLSC,1);
        for idxEulerLSC = 1:numCLSC
            centerEuler = getIntervalCenter(length,LSC(idxEulerLSC));
            distance(idxEulerLSC) = getDistanceShortest(center, centerEuler, length);
        end
        [~,idxCorrespond] = min(distance,[],"all",'linear');
        lagranLSC(i) = LSC(idxCorrespond);
        idxLagranLSCToLSC(i) = idxCorrespond;
    end

    idxCheck = unique(idxLagranLSCToLSC);
    if numel(idxCheck) < numel(idxLagranLSCToLSC)
        disp('Wrong track! Two or more Euler is correspond to one Lagran')
    end
end

function [center] = getIntervalCenter(length,LSC)
    if LSC.headIdx < LSC.rearIdx
        center = 0.5*(LSC.head + LSC.rear);
    else
        center = 0.5*(LSC.head + length + LSC.rear);
        if center > length
            center = center - length;
        end
    end
end

function [shortest] = getDistanceShortest(center1, center2, length)
    if center1 < center2
        distance1 = center2 - center1;
        distance2 = center1 + length - center2;
        shortest = min(distance1, distance2);
    else
        distance1 = center1 - center2;
        distance2 = center2 + length - center1;
        shortest = min(distance1, distance2);
    end
end
