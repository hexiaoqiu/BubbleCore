function [DUphiDPhi, DUphiDTheta, DVthetaDPhi, DVthetaDTheta] = getDerVelDerSphFluctuate(bubble, timeStep, itpMesh, meanVelX2D, meanVelY2D)

    n1 = bubble.n1;
    n2 = bubble.n2;

    x2d  = bubble.x2dS;
    y2d  = bubble.y2dS;
    x2dU = bubble.x2dU;
    y2dU = bubble.y2dU;
    x2dV = bubble.x2dV;
    y2dV = bubble.y2dV;
    h1 = (bubble.x2dDroit - bubble.x2dGauche) / n1;
    h2 = (bubble.y2dHaut - bubble.y2dBas) / n2;

    % calculate the coefs for DTmpDTheta = f( DTmpDx2d, DTmpDy2d )
    r_hat = sqrt(x2d.^2 + y2d.^2);
    d = 2*r_hat./(1+r_hat.^2);
    DThetaDx2d = ...,
    ( sqrt(1-d.^2) + d.^2./sqrt(1-d.^2) ).*( 2*(1-r_hat.^2)./(r_hat.*(1+r_hat.^2).^2) ).*x2d;
    DThetaDy2d = ...,
    ( sqrt(1-d.^2) + d.^2./sqrt(1-d.^2) ).*( 2*(1-r_hat.^2)./(r_hat.*(1+r_hat.^2).^2) ).*y2d;
    DPhiDx2d = -y2d./(r_hat.^2);
    DPhiDy2d = x2d./(r_hat.^2);
    Jaccobi = (DThetaDx2d.*DPhiDy2d - DThetaDy2d.*DPhiDx2d).^-1;

    % u2dOrg = readField(bubble, 'u', timeStep);
    % v2dOrg = readField(bubble, 'v', timeStep);
    u2dOrg = readField(bubble, 'u', timeStep) - meanVelX2D;
    v2dOrg = readField(bubble, 'v', timeStep) - meanVelY2D;
    u2dOrgShifted = interp2(x2dU, y2dU, u2dOrg, x2d, y2d);
    v2dOrgShifted = interp2(x2dV, y2dV, v2dOrg, x2d, y2d);
    [x2dGrid,y2dGrid] = meshgrid(x2d,y2d);
    [u3dOrgShifted, v3dOrgShifted, w3dOrgShifted] = velocity2DTo3D(u2dOrgShifted, v2dOrgShifted, x2dGrid, y2dGrid);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);
    [phiGrid, thetaGrid] = pos3DtoSph(x3dGrid,y3dGrid,z3dGrid);
    [uPhiOrgShifted, vThetaOrgShifted] = velocity3DToSpherical(u3dOrgShifted, v3dOrgShifted, w3dOrgShifted, phiGrid, thetaGrid);  

    % calculate the derivative in projection coordinate
    % calculate the derivative in projection coordinate
    DUphiDx2d = zeros( n2, n1 );
    DUphiDy2d = zeros( n2, n1 );
    DVthetaDx2d = zeros( n2, n1 );
    DVthetaDy2d = zeros( n2, n1 );

    for j = 2:n1-1
        for i = 2:n2-1
            DUphiDx2d(i,j) = (uPhiOrgShifted(i,j+1) - uPhiOrgShifted(i,j-1))/(2*h1);
            DUphiDy2d(i,j) = (uPhiOrgShifted(i+1,j) - uPhiOrgShifted(i-1,j))/(2*h2);
            DVthetaDx2d(i,j) = (vThetaOrgShifted(i,j+1) - vThetaOrgShifted(i,j-1))/(2*h1);
            DVthetaDy2d(i,j) = (vThetaOrgShifted(i+1,j) - vThetaOrgShifted(i-1,j))/(2*h2);
        end
    end

    DUphiDx2d(1,:) = 0;
    DUphiDx2d(n2,:) = 0;
    DUphiDx2d(:,1) = 0;
    DUphiDx2d(:,n1) = 0;

    DUphiDy2d(1,:) = 0;
    DUphiDy2d(n2,:) = 0;
    DUphiDy2d(:,1) = 0;
    DUphiDy2d(:,n1) = 0;

    DVthetaDx2d(1,:) = 0;
    DVthetaDx2d(n2,:) = 0;
    DVthetaDx2d(:,1) = 0;
    DVthetaDx2d(:,n1) = 0;

    DVthetaDy2d(1,:) = 0;
    DVthetaDy2d(n2,:) = 0;
    DVthetaDy2d(:,1) = 0;
    DVthetaDy2d(:,n1) = 0;

    DUphiDPhiOrg = Jaccobi.*(DUphiDy2d.*DThetaDx2d - DUphiDx2d.*DPhiDy2d);
    DUphiDThetaOrg = Jaccobi.*(DUphiDx2d.*DPhiDy2d - DUphiDy2d.*DPhiDx2d);

    DVthetaDPhiOrg = Jaccobi.*(DVthetaDy2d.*DThetaDx2d - DVthetaDx2d.*DPhiDy2d);
    DVthetaDThetaOrg = Jaccobi.*(DVthetaDx2d.*DPhiDy2d - DVthetaDy2d.*DPhiDx2d);

    DUphiDPhi = interp2(x2d, y2d, DUphiDPhiOrg, itpMesh.x2d, itpMesh.y2d,'spline');
    DUphiDTheta = interp2(x2d, y2d, DUphiDThetaOrg, itpMesh.x2d, itpMesh.y2d,'spline');

    DVthetaDPhi = interp2(x2d, y2d, DVthetaDPhiOrg, itpMesh.x2d, itpMesh.y2d,'spline');
    DVthetaDTheta = interp2(x2d, y2d, DVthetaDThetaOrg, itpMesh.x2d, itpMesh.y2d,'spline');


end