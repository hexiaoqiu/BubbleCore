function [centerX, centerZ] = lscFindCenterByVor(lagranLSC)
    
    u = lagranLSC.uPhiScale;
    v = lagranLSC.vThetaScale;
    [numZ,numX] = size(u);
    xLoc = linspace(0,1,numX);
    dx = xLoc(2);
    zLoc = linspace(0,1,numZ)';
    dz = xLoc(2);

    du_dx = zeros(numZ,numX);
    dv_dy = zeros(numZ,numX);
    for idx = 2:numX
        du_dx(:,idx) = (u(:,idx) - u(:,idx-1))./dx;
        dv_dy(idx,:) = (u(idx,:) - u(idx-1,:))./dx;
    end
    du_dx(:,1) = (u(:,2) - u(:,1))./dx;
    dv_dy(1,:) = (u(2,:) - u(1,:))./dx;
    
    vor = du_dx - dv_dy;
    maxVor = max(abs(vor),[],'all');
    vor = vor./maxVor;
    locMinX = islocalmax(vor,2);
    locMinZ = islocalmax(vor,1);
    [row,col,~] = find((locMinZ + locMinX)==2);
    distanceToCenter = zeros(numel(col),1);
    for idxPt = 1:numel(row)
        xPt = xLoc(row(idxPt));
        zPt = zLoc(col(idxPt));
        distanceToCenter(idxPt) = sqrt((xPt-0.5)^2 + (zPt-0.5)^2);
    end
    [~,idxCenter] = min(distanceToCenter,[],'all');
    centerX = xLoc(col(idxCenter));
    centerZ = zLoc(row(idxCenter));
    
end