function [dTmpDX3d, dTmpDY3d, dTmpDZ3d] = getDerCarOrd1TmpDirect(bubble, timeStep, itpMesh)

    dTheta = itpMesh.theta(2) - itpMesh.theta(1);
    dPhi = itpMesh.phi(2) - itpMesh.phi(1);
    diffHalfPi = itpMesh.phi-pi/2;
    idxPhiMostCloseToHalfPi = find( diffHalfPi==min(diffHalfPi,'all') );
    
    [thetaGrid,phiGrid] = meshgrid(itpMesh.phi,itpMesh.theta);

    tmp = itpField(bubble, 'tmp', timeStep, itpMesh);

    dTmpDPhi = zeros(size(tmp));
    dTmpDTheta = zeros(size(tmp));
    
    dTmpDPhi(:,2:end) = ( tmp(:,2:end) - tmp(:,1:end-1) )./(dPhi);
    dTmpDPhi(:,1) = dTmpDPhi(:,end);

    dTmpDTheta(2:end,:) = ( tmp(2:end,:) - tmp(1:end-1,:) )./(dTheta);
    dTmpDTheta(1,:) = (-3*tmp(1,:) + 4*tmp(2,:) - tmp(3,:))./(2*dTheta);

    dTmpDX3d    = cos(thetaGrid).*cos(phiGrid).*dTmpDTheta - sin(phiGrid)./sin(thetaGrid).*dTmpDPhi;
    dTmpDY3d    = cos(thetaGrid).*sin(phiGrid).*dTmpDTheta + cos(phiGrid)./sin(thetaGrid).*dTmpDPhi;
    dTmpDZ3d    = -sin(thetaGrid).*dTmpDTheta;
    dTmpDX3d(1,:) = dTmpDTheta(1,1);
    dTmpDY3d(1,:) = dTmpDTheta(1,idxPhiMostCloseToHalfPi);

end