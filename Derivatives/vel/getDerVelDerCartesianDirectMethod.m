function [parU3dParX3d, parU3dParY3d,parU3dParZ3d,parV3dParX3d, parV3dParY3d,parV3dParZ3d,parW3dParX3d, parW3dParY3d,parW3dParZ3d] = getDerVelDerCartesianDirectMethod(bubble, timeStep, itpMesh)


    [parU3dParPhi, parU3dParTheta, parV3dParPhi, parV3dParTheta, parW3dParPhi, parW3dParTheta] = getDerVelDerSphDirect(bubble, timeStep, itpMesh);
    phiVector = itpMesh.phi;
    thetaVector = itpMesh.theta;
    [phiGrid,thetaGrid] = meshgrid(phiVector,thetaVector);
    idxPhiEqualHalfPi = find(round(phiVector-pi/2,2) == 0,1);

    parU3dParX3d    = cos(thetaGrid).*cos(phiGrid).*parU3dParTheta - sin(phiGrid)./sin(thetaGrid).*parU3dParPhi;
    parU3dParY3d    = cos(thetaGrid).*sin(phiGrid).*parU3dParTheta + cos(phiGrid)./sin(thetaGrid).*parU3dParPhi;
    parU3dParZ3d    = -sin(thetaGrid).*parU3dParTheta;
    parU3dParX3d(1,:) = parU3dParTheta(1,1);
    parU3dParY3d(1,:) = parU3dParTheta(1,idxPhiEqualHalfPi);

    parV3dParX3d    = cos(thetaGrid).*cos(phiGrid).*parV3dParTheta - sin(phiGrid)./sin(thetaGrid).*parV3dParPhi;
    parV3dParY3d    = cos(thetaGrid).*sin(phiGrid).*parV3dParTheta + cos(phiGrid)./sin(thetaGrid).*parV3dParPhi;
    parV3dParZ3d    = -sin(thetaGrid).*parV3dParTheta;
    parV3dParX3d(1,:) = parV3dParTheta(1,1);
    parV3dParY3d(1,:) = parV3dParTheta(1,idxPhiEqualHalfPi);

    parW3dParX3d    = cos(thetaGrid).*cos(phiGrid).*parW3dParTheta - sin(phiGrid)./sin(thetaGrid).*parW3dParPhi;
    parW3dParY3d    = cos(thetaGrid).*sin(phiGrid).*parW3dParTheta + cos(phiGrid)./sin(thetaGrid).*parW3dParPhi;
    parW3dParZ3d    = -sin(thetaGrid).*parW3dParTheta;
    parW3dParX3d(1,:) = parW3dParTheta(1,1);
    parW3dParY3d(1,:) = parW3dParTheta(1,idxPhiEqualHalfPi);

end