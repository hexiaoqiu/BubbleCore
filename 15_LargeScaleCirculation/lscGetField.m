function [LSC] = lscGetField(LSC,nLSC,tmp,uPhi,vTheta)    
    % start to cut the field for LSC
    [LSC] = lscCutField(LSC,tmp,uPhi,vTheta);

    % rescale the field for LSC
    [LSC] = lscReScaleField(LSC,nLSC);
end

function [LSC] = lscCutField(LSC,tmp,uPhi,vTheta)
    numLSC = numel(LSC);  
    for idxLSC = 1:numLSC
        headIdx = LSC(idxLSC).headIdx;
        rearIdx = LSC(idxLSC).rearIdx;
        if headIdx < rearIdx
            LSC(idxLSC).tmpCut = tmp(:,headIdx:rearIdx);
            LSC(idxLSC).uPhiCut = uPhi(:,headIdx:rearIdx);
            LSC(idxLSC).vThetaCut = vTheta(:,headIdx:rearIdx);
        else
            LSC(idxLSC).tmpCut = [tmp(:,headIdx:end),tmp(:,1:rearIdx)];
            LSC(idxLSC).uPhiCut = [uPhi(:,headIdx:end),uPhi(:,1:rearIdx)];
            LSC(idxLSC).vThetaCut = [vTheta(:,headIdx:end),vTheta(:,1:rearIdx)];
        end
    end
end

function [LSC] = lscReScaleField(LSC,nLSC)
    numLSC = numel(LSC); 
    % formulate the coordinate system for local coordinate
    xScale = linspace(0,1,nLSC);
    zScale = linspace(0,1,nLSC)';
    for idxLSC = 1:numLSC
        [nZ,nX] = size(LSC(idxLSC).tmpCut);
        xCut = linspace(0,1,nX);
        zCut = linspace(0,1,nZ)';
        LSC(idxLSC).tmpScale = interp2(xCut,zCut,LSC(idxLSC).tmpCut,xScale,zScale,"spline");
        LSC(idxLSC).uPhiScale = interp2(xCut,zCut,LSC(idxLSC).uPhiCut,xScale,zScale,"spline");
        LSC(idxLSC).vThetaScale = interp2(xCut,zCut,LSC(idxLSC).vThetaCut,xScale,zScale,"spline");
    end
end

