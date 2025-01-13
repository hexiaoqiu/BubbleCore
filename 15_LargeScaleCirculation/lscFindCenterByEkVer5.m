function [centerX, centerZ] = lscFindCenterByEkVer5(lagranLSC)
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
    [distanceToCenter,idxSorted] = sort(distanceToCenter,'ascend');
    row = row(idxSorted);
    col = col(idxSorted);
    
    % check if the circulation is around the center
    colNew = zeros(1);
    rowNew = zeros(1);
    noteList = zeros(1);
    distanceToCenterNew = zeros(1);
    centerCounter = 0;
    for idxPt = 1:numel(row)
        iX = col(idxPt);
        iZ = row(idxPt);
        [note] = checkCirculationVer4(iX,iZ,xLoc,zLoc,u,v);
        if note > 10
            centerCounter = centerCounter + 1;
            colNew(centerCounter) = iX;
            rowNew(centerCounter) = iZ;
            noteList(centerCounter) = note;
            distanceToCenterNew(centerCounter) = distanceToCenter(idxPt);
        end
    end
    if centerCounter == 0
        disp('fail to find the circulation!')
        centerX = NaN;
        centerZ = NaN;
        return
    end
    [noteList,idxSorted] = sort(noteList,'descend');
    rowNew = rowNew(idxSorted);
    colNew = colNew(idxSorted);
    distanceToCenterNew = distanceToCenterNew(idxSorted);

    noteMax = noteList(1);
    rowLast = rowNew(1);
    colLast = colNew(1);
    distanceToCenterLast = distanceToCenterNew(1);
    counterLast = 1;
    for idxPt = 2:numel(noteList)
        if noteList(idxPt) == noteMax
            counterLast = counterLast + 1;
            rowLast(counterLast) = rowNew(idxPt);
            colLast(counterLast) = colNew(idxPt);
            distanceToCenterLast(counterLast) = distanceToCenterNew(idxPt);
        else
            break
        end
    end
    [~,idxSorted] = sort(distanceToCenterLast,'ascend');
    rowLast = rowLast(idxSorted);
    colLast = colLast(idxSorted);
    centerX = xLoc(colLast(1));
    centerZ = zLoc(rowLast(1));
    
    % % find the Ek minimun one center
    % EkCenter = zeros(numel(rowNew),1);
    % for idxPt = 1:numel(rowNew)
    %     iX = colNew(idxPt);
    %     iZ = rowNew(idxPt);
    %     EkCenter(idxPt) = Ek(iZ,iX);
    % end
    % [~,idxSorted] = sort(EkCenter,'ascend');
    % colNew = colNew(idxSorted);
    % rowNew = rowNew(idxSorted);
    % centerX = xLoc(colNew(1));
    % centerZ = zLoc(rowNew(1));
    
end



function [note] = checkCirculationVer4(iX,iZ,xLoc,zLoc,u,v)
    note = 0;

    x = xLoc(iX);
    z = zLoc(iZ);
    searchScop = 0.05;
    xSearchFront = x:0.001:x+searchScop;
    xSearchBack = x-searchScop:0.001:x;
    zSearchUp = (z:0.001:z+searchScop)';
    zSearchDown = (z-searchScop:0.001:z)';

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
        note = 100;
        return
    end

    condition_2 = (meanUDown < 0)&&(meanUUp > 0);
    condition_3 = (meanUDown > 0)&&(meanUUp < 0);
    if (condition_2)||(condition_3)
        note = note + 10;
    end

    condition_4 = (meanVFront < 0)&&(meanVBack > 0);
    condition_5 = (meanVFront > 0)&&(meanVBack < 0);
    if (condition_4)||(condition_5)
        note = note + 10;
    end

end