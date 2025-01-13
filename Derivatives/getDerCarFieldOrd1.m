function [dPsiDX3d,dPsiDY3d,dPsiDZ3d] = getDerCarFieldOrd1(phiVector,thetaVector,psi)

    dPhi = phiVector(2) - phiVector(1);
    dTheta = thetaVector(2) - thetaVector(1);
    [phiGrid,thetaGrid] = meshgrid(phiVector,thetaVector);
    diffHalfPi = phiVector-pi/2;
    idxPhiMostCloseToHalfPi = find( diffHalfPi==min(diffHalfPi,[],'all'), 1 );

    [dPsiDPhi, dPsiDTheta] = getDerSphFieldOrd1(dPhi,dTheta,psi);

    dPsiDX3d    = cos(thetaGrid).*cos(phiGrid).*dPsiDTheta - sin(phiGrid)./sin(thetaGrid).*dPsiDPhi;
    dPsiDY3d    = cos(thetaGrid).*sin(phiGrid).*dPsiDTheta + cos(phiGrid)./sin(thetaGrid).*dPsiDPhi;
    dPsiDZ3d    = -sin(thetaGrid).*dPsiDTheta;
    dPsiDX3d(1,:) = dPsiDTheta(1,1);
    dPsiDY3d(1,:) = dPsiDTheta(1,idxPhiMostCloseToHalfPi);

end