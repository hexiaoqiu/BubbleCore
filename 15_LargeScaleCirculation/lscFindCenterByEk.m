function [centerX, centerZ] = lscFindCenterByEk(lagranLSC)
    Ek = sqrt(lagranLSC.uPhiScale.^2 + lagranLSC.vThetaScale.^2);
    [numZ,numX] = size(Ek);
    xLoc = linspace(0,1,numX);
    zLoc = linspace(0,1,numZ)';

    maxEk = max(Ek,[],'all');
    Ek = Ek./maxEk;
    locMinX = islocalmin(Ek,2);
    locMinZ = islocalmin(Ek,1);
    [row,col,~] = find((locMinZ + locMinX)==2);
    distanceToCenter = zeros(numel(col),1);
    for idxPt = 1:numel(row)
        xPt = xLoc(col(idxPt));
        zPt = zLoc(row(idxPt));
        distanceToCenter(idxPt) = sqrt((xPt-0.5)^2 + (zPt-0.5)^2);
    end
    [~,idxCenter] = min(distanceToCenter,[],'all');
    centerX = xLoc(col(idxCenter));
    centerZ = zLoc(row(idxCenter));
    
end