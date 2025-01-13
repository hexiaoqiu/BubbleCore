function [DTmpDPhi, DTmpDTheta] = getTmpSphDerivativePrecise(bubble, timeStep, itpMesh)

    n1 = bubble.n1;
    n2 = bubble.n2;

    x2d  = bubble.x2dS;
    y2d  = bubble.y2dS;
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

    tmpOrg = readField(bubble, 'tmp', timeStep);

    % calculate the derivative in projection coordinate
    DTmpDx2dOrg = zeros( size(tmpOrg) );
    DTmpDy2dOrg = zeros( size(tmpOrg) );
    for j = 2:n1-1
        for i = 2:n2-1
            DTmpDx2dOrg(i,j) = (tmpOrg(i,j+1) - tmpOrg(i,j-1)) / (2*h1);
            DTmpDy2dOrg(i,j) = (tmpOrg(i+1,j) - tmpOrg(i-1,j)) / (2*h2);
        end
    end
    DTmpDx2dOrg(1,:) = 0;
    DTmpDx2dOrg(n2,:) = 0;
    DTmpDy2dOrg(:,1) = 0;
    DTmpDy2dOrg(:,n1) = 0;

    DTmpDPhiOrg = Jaccobi.*(DTmpDy2dOrg.*DThetaDx2d - DTmpDx2dOrg.*DPhiDy2d);
    DTmpDThetaOrg = Jaccobi.*(DTmpDx2dOrg.*DPhiDy2d - DTmpDy2dOrg.*DPhiDx2d);

    DTmpDTheta = interp2(x2d, y2d, DTmpDThetaOrg, itpMesh.x2d, itpMesh.y2d,'spline');
    DTmpDPhi = interp2(x2d, y2d, DTmpDPhiOrg, itpMesh.x2d, itpMesh.y2d,'spline');


end