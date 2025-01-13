function [sphMesh] = createSphMesh(phiLim,thetaLim,N_phi,N_theta)
    
    phiMin = phiLim(1);
    phiMax = phiLim(2);
    thetaMin = thetaLim(1);
    thetaMax = thetaLim(2),
    
    sphMesh.phi = linspace(phiMin,phiMax,N_phi);
    sphMesh.theta = linspace(thetaMin,thetaMax,N_theta)';
    sphMesh.dPhi = (phiMax - phiMin)/(N_phi-1);
    sphMesh.dTheta = (thetaMax - thetaMin)/(N_theta-1);

    [x3d,y3d,~] = posSphto3D(sphMesh.phi,sphMesh.theta);
    [sphMesh.x2d, sphMesh.y2d] = pos3Dto2D(x3d,y3d);

end