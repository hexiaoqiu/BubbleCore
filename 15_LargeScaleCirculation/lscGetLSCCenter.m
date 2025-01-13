function [center] = lscGetLSCCenter(x,z,LSC,uPhi,vTheta)
    nLSC = 1024;
    numLSC = numel(LSC);
    center(numLSC) = struct( ...
        'x',0, ...
        'z',0, ...
        'xLoc',0, ...
        'zLoc',0, ...
        'iXLoc',0, ...
        'iZLoc',0);

    [cutUPhi] = lscCutField(LSC,uPhi);
    [cutVTheta] = lscCutField(LSC,vTheta);
    [scaleUPhi] = lscReScaleField(LSC,nLSC,cutUPhi);
    [scaleVTheta] = lscReScaleField(LSC,nLSC,cutVTheta);
    
    xLoc = linspace(0,1,nLSC);
    zLoc = linspace(0,1,nLSC)';
    for idxLSC = 1:numLSC
        Ek = sqrt(scaleUPhi{idxLSC}.^2 + scaleVTheta{idxLSC}.^2);
        maxEk = max(Ek,[],'all');
        Ek = Ek./maxEk;
        locMinX = islocalmin(Ek,2);
        locMinZ = islocalmin(Ek,1);
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

        [xCut] = getXCut(x,LSC(idxLSC).headIdx,LSC(idxLSC).rearIdx);
        xLocCut = linspace(0,1,numel(xCut));
        realX = interp1(xLocCut,xCut,centerX,'spline');
        if realX > x(end)
            realX = realX - x(end);
        end

        zLocCut = linspace(0,1,numel(z));
        realZ = interp1(zLocCut,z,centerZ,'spline');

        center(idxLSC).x = realX;
        center(idxLSC).z = realZ;
        center(idxLSC).xLoc = centerX;
        center(idxLSC).zLoc = centerZ;
        center(idxLSC).iXLoc = col(idxCenter);
        center(idxLSC).iZLoc = row(idxCenter);
    end

    [center] = sortByRealX(center);
end

function [cutPiece] = lscCutField(LSC,field)
    numLSC = numel(LSC);
    cutPiece = cell(numLSC,1);
    for idxLSC = 1:numLSC
        headIdx = LSC(idxLSC).headIdx;
        rearIdx = LSC(idxLSC).rearIdx;
        if headIdx < rearIdx
            cutPiece{idxLSC} = field(:,headIdx:rearIdx);
        else
            cutPiece{idxLSC} = [field(:,headIdx:end),field(:,1:rearIdx)];
        end
    end
end

function [scaleField] = lscReScaleField(LSC,nLSC,cutField)
    numLSC = numel(LSC);
    scaleField = cell(numLSC,1);
    % formulate the coordinate system for local coordinate
    xScale = linspace(0,1,nLSC);
    zScale = linspace(0,1,nLSC)';
    for idxLSC = 1:numLSC
        [nZ,nX] = size(cutField{idxLSC});
        xCut = linspace(0,1,nX);
        zCut = linspace(0,1,nZ)';
        scaleField{idxLSC} = interp2(xCut,zCut,cutField{idxLSC},xScale,zScale,"spline");
    end
end

function [xCut] = getXCut(x,headIdx,rearIdx)
    if headIdx < rearIdx
        xCut = x(headIdx:rearIdx);
    else
        xDoulbe = [x,(x+x(end))];
        length = numel(x);
        rearIdxPesudo = rearIdx + length;
        xCut = xDoulbe(headIdx:rearIdxPesudo);
    end
end

function [center] = sortByRealX(centerOld)
    numCenter = numel(centerOld);
    xArray = zeros(numCenter,1);
    for idx = 1:numCenter
        xArray(idx) = centerOld(idx).x;
    end
    [~, idxShift] = sort(xArray,'ascend');
    center = centerOld(idxShift);
end
