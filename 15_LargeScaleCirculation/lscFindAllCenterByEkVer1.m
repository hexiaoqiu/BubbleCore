function [centerX, centerZ] = lscFindAllCenterByEkVer1(lagranLSC)
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
    
    centerX = zeros(1);
    centerZ = zeros(1);
    centerCounter = 0;
    for idxPt = 1:numel(row)
        iX = col(idxPt);
        iZ = row(idxPt);
        [circulation] = checkCirculationVer2(iX,iZ,xLoc,zLoc,u,v);
        if circulation == true
            centerCounter = centerCounter + 1;
            centerX(centerCounter) = xLoc(iX);
            centerZ(centerCounter) = zLoc(iZ);
        end
    end
    if centerCounter == 0
        disp('fail to find the circulation!')
        centerX = xLoc(col(1));
        centerZ = zLoc(row(1));
    end
    
end

% function [circulation] = checkCirculation(iX,iZ,xLoc,zLoc,u,v)
%     x = xLoc(iX);
%     z = zLoc(iZ);
%     xSearch = x-0.2:0.01:x+0.2;
%     zSearch = (z-0.2:0.01:z+0.2)';
%     uSearch = interp2(xLoc,zLoc,u,xSearch,zSearch,"spline");
%     vSearch = interp2(xLoc,zLoc,v,xSearch,zSearch,"spline");
%     [~,idxUPlus] = find(uSearch>0);
%     [~,wind_0] = find(vSearch(idxUPlus)>0);
%     [~,wind_1] = find(vSearch(idxUPlus)<0);
%     [~,idxUMinus] = find(uSearch<0);
%     [~,wind_2] = find(vSearch(idxUMinus)>0);
%     [~,wind_3] = find(vSearch(idxUMinus)<0);
%     good = (~isempty(wind_0))&&(~isempty(wind_1))...
%         &&(~isempty(wind_3))&&(~isempty(wind_2));
%     if good == true
%         circulation = true;
%     else
%         circulation = false;
%     end
% end

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