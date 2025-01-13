function [LSC] = lscGetVel3D(LSC,nLSC,u3d,v3d,w3d)    
    % start to cut the field for LSC
    [LSC] = lscCutField(LSC,u3d,v3d,w3d);

    % rescale the field for LSC
    [LSC] = lscReScaleField(LSC,nLSC);
end

function [LSC] = lscCutField(LSC,u3d,v3d,w3d)
    numLSC = numel(LSC);  
    for idxLSC = 1:numLSC
        headIdx = LSC(idxLSC).headIdx;
        rearIdx = LSC(idxLSC).rearIdx;
        if headIdx < rearIdx
            LSC(idxLSC).u3dCut = u3d(:,headIdx:rearIdx);
            LSC(idxLSC).v3dCut = v3d(:,headIdx:rearIdx);
            LSC(idxLSC).w3dCut = w3d(:,headIdx:rearIdx);
        else
            LSC(idxLSC).u3dCut = [u3d(:,headIdx:end),u3d(:,1:rearIdx)];
            LSC(idxLSC).v3dCut = [v3d(:,headIdx:end),v3d(:,1:rearIdx)];
            LSC(idxLSC).w3dCut = [w3d(:,headIdx:end),w3d(:,1:rearIdx)];
        end
    end
end

function [LSC] = lscReScaleField(LSC,nLSC)
    numLSC = numel(LSC); 
    % formulate the coordinate system for local coordinate
    xScale = linspace(0,1,nLSC);
    zScale = linspace(0,1,nLSC)';
    for idxLSC = 1:numLSC
        [nZ,nX] = size(LSC(idxLSC).u3dCut);
        xCut = linspace(0,1,nX);
        zCut = linspace(0,1,nZ)';
        LSC(idxLSC).u3dScale = interp2(xCut,zCut,LSC(idxLSC).u3dCut,xScale,zScale,"spline");
        LSC(idxLSC).v3dScale = interp2(xCut,zCut,LSC(idxLSC).v3dCut,xScale,zScale,"spline");
        LSC(idxLSC).w3dScale = interp2(xCut,zCut,LSC(idxLSC).w3dCut,xScale,zScale,"spline");
    end
end

