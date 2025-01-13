function [dTmpDX3d, dTmpDY3d, dTmpDZ3d] = getDerCarOrd1TmpDirect(bubble, timeStep, itpMesh)

    dTheta = itpMesh.theta(2) - itpMesh.theta(1);
    dPhi = itpMesh.phi(2) - itpMesh.phi(1);
    diffHalfPi = itpMesh.phi-pi/2;
    idxPhiMostCloseToHalfPi = find( diffHalfPi==min(diffHalfPi,'all') );
    
    [thetaGrid,phiGrid] = meshgrid(itpMesh.phi,itpMesh.theta);

    [fx, fy, fz] = getDerCarOrd1TmpDirect(bubble, timeStep, itpMesh);

    [dFxDPhi,dFxDTheta] = getDerSphFieldDirect(dPhi,dTheta,fx);
    [dFyDPhi,dFyDTheta] = getDerSphFieldDirect(dPhi,dTheta,fy);
    [dFzDPhi,dFzDTheta] = getDerSphFieldDirect(dPhi,dTheta,fz);

    dFyDPhi = zeros(size(fx));
    dFyDTheta = zeros(size(fx));
    
    dFzDPhi = zeros(size(fx));
    dFzDTheta = zeros(size(fx));




end