function [LSC] = lscGetVor(LSC,nLSC,vor)    
    % start to cut the field for LSC
    [LSC] = lscCutField(LSC,vor);

    % rescale the field for LSC
    [LSC] = lscReScaleField(LSC,nLSC);
end

function [LSC] = lscCutField(LSC,vor)
    numLSC = numel(LSC);  
    for idxLSC = 1:numLSC
        headIdx = LSC(idxLSC).headIdx;
        rearIdx = LSC(idxLSC).rearIdx;
        if headIdx < rearIdx
            LSC(idxLSC).vorCut = vor(:,headIdx:rearIdx);
        else
            LSC(idxLSC).vorCut = [vor(:,headIdx:end),vor(:,1:rearIdx)];
        end
    end
end

function [LSC] = lscReScaleField(LSC,nLSC)
    numLSC = numel(LSC); 
    % formulate the coordinate system for local coordinate
    xScale = linspace(0,1,nLSC);
    zScale = linspace(0,1,nLSC)';
    for idxLSC = 1:numLSC
        [nZ,nX] = size(LSC(idxLSC).vorCut);
        xCut = linspace(0,1,nX);
        zCut = linspace(0,1,nZ)';
        LSC(idxLSC).vorScale = interp2(xCut,zCut,LSC(idxLSC).vorCut,xScale,zScale,"spline");
    end
end

