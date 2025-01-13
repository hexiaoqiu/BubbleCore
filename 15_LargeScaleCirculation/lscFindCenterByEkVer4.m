function [centerX, centerZ] = lscFindCenterByEkVer4(lagranLSC)
    u = lagranLSC.uPhiScale;
    v = lagranLSC.vThetaScale;
    Ek = sqrt(u.^2 + v.^2);
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
    % remove the vortex far from the center
    [row1stFilter,~,~] = find(distanceToCenter<0.2);
    row = row(row1stFilter);
    col = col(row1stFilter);
    distanceToCenter = distanceToCenter(row1stFilter);
    % sort the votex from the rearest to farest
    [~,idxSorted] = sort(distanceToCenter,'ascend');
    row = row(idxSorted);
    col = col(idxSorted);
    
    % check if the circulation is around the center
    colNew = zeros(1);
    rowNew = zeros(1);
    centerCounter = 0;
    for idxPt = 1:numel(row)
        iX = col(idxPt);
        iZ = row(idxPt);
        [circulation] = checkCirculationVer3(iX,iZ,xLoc,zLoc,u,v);
        if circulation == true
            centerCounter = centerCounter + 1;
            colNew(centerCounter) = iX;
            rowNew(centerCounter) = iZ;
        end
    end
    if centerCounter == 0
        disp('fail to find the circulation!')
        centerX = xLoc(col(1));
        centerZ = zLoc(row(1));
        return
    end

    % find the Ek minimun one center
    EkCenter = zeros(numel(rowNew),1);
    for idxPt = 1:numel(rowNew)
        iX = colNew(idxPt);
        iZ = rowNew(idxPt);
        EkCenter(idxPt) = Ek(iZ,iX);
    end
    [~,idxSorted] = sort(EkCenter,'ascend');
    colNew = colNew(idxSorted);
    rowNew = rowNew(idxSorted);
    centerX = xLoc(colNew(1));
    centerZ = zLoc(rowNew(1));
    
end

function [circulation] = checkCirculationVer2(iX,iZ,xLoc,zLoc,u,v)
    x = xLoc(iX);
    z = zLoc(iZ);
    xSearch = x-0.05:0.001:x+0.05;
    zSearch = (z-0.05:0.001:z+0.05)';
    uSearch = interp2(xLoc,zLoc,u,xSearch,zSearch,"spline");
    vSearch = interp2(xLoc,zLoc,v,xSearch,zSearch,"spline");
    [~,windRight] = find(uSearch>0);
    [~,windLeft] = find(uSearch<0);
    [~,windUp] = find(vSearch>0);
    [~,windDown] = find(vSearch<0);
    good = (~isempty(windRight))&&(~isempty(windLeft))...
        &&(~isempty(windUp))&&(~isempty(windDown));
    if good == true
        circulation = true;
    else
        circulation = false;
    end
end

function [circulation] = checkCirculationVer3(iX,iZ,xLoc,zLoc,u,v)
    x = xLoc(iX);
    z = zLoc(iZ);
    xSearchFront = x:0.001:x+0.1;
    xSearchBack = x-0.1:0.001:x;
    zSearchUp = (z:0.001:z+0.1)';
    zSearchDown = (z-0.1:0.001:z)';

    vSearchFront = interp2(xLoc,zLoc,v,xSearchFront,z,"spline");
    vSearchBack = interp2(xLoc,zLoc,v,xSearchBack,z,"spline");

    uSearchUp = interp2(xLoc,zLoc,u,x,zSearchUp,"spline");
    uSearchDown = interp2(xLoc,zLoc,u,x,zSearchDown,"spline");
    
    meanVFront = mean(vSearchFront);
    meanVBack = mean(vSearchBack);
    meanUUp = mean(uSearchUp);
    meanUDown = mean(uSearchDown);

    condition_0 = (meanUDown < 0)&&(meanUUp > 0)&&(meanVFront < 0)&&(meanVBack > 0);
    condition_1 = (meanUDown > 0)&&(meanUUp < 0)&&(meanVFront > 0)&&(meanVBack < 0);

    if (condition_0)||(condition_1)
        circulation = true;
    else
        circulation = false;
    end
end