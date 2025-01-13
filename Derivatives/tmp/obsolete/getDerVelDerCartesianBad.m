function [parVelX3dParX3dOut, parVelX3dParY3dOut, parVelX3dParZ3dOut, parVelY3dParX3dOut, parVelY3dParY3dOut, parVelY3dParZ3dOut, parVelZ3dParX3dOut, parVelZ3dParY3dOut, parVelZ3dParZ3dOut] = getDerVelDerCartesianBad(bubble, timeStep, itpMesh)

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

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3d,y3d,z3d] = pos2Dto3D(x2dGrid,y2dGrid);

    parX2dParX3d = 1./( (1+sqrt(1-x3d.^2-y3d.^2)).^2 ) ...,
                    .* ...,
                    ( 1+sqrt(1-x3d.^2-y3d.^2) + (x3d.^2)./(sqrt(1-x3d.^2-y3d.^2)) );
    parX2dParY3d = (x3d.*y3d) ...,
                    ./ ...,
                    ( ( sqrt(1-x3d.^2-y3d.^2) ) .* (1+sqrt(1-x3d.^2-y3d.^2)).^2  );
    parX2dParZ3d = x3d ./ (1+z3d).^2;

    parY2dParX3d = (x3d.*y3d) ...,
                    ./ ...,
                    ( ( sqrt(1-x3d.^2-y3d.^2) ) .* (1+sqrt(1-x3d.^2-y3d.^2)).^2  );
    parY2dParY3d = 1./( (1+sqrt(1-x3d.^2-y3d.^2)).^2 ) ...,
                    .* ...,
                    ( 1+sqrt(1-x3d.^2-y3d.^2) + (y3d.^2)./(sqrt(1-x3d.^2-y3d.^2)) );
    parY2dParZ3d = y3d ./ (1+z3d).^2;
                    

    u2dOrg = readField(bubble, 'u', timeStep);
    v2dOrg = readField(bubble, 'v', timeStep);
    u2dOrgShifted = interp2(x2dU, y2dU, u2dOrg, x2d, y2d);
    v2dOrgShifted = interp2(x2dV, y2dV, v2dOrg, x2d, y2d);
    [u3dOrgShifted, v3dOrgShifted, w3dOrgShifted] = velocity2DTo3D(u2dOrgShifted, v2dOrgShifted, x2dGrid, y2dGrid);
    
    % calculate the derivative in projection coordinate
    % calculate the derivative in projection coordinate
    parVelX3dParX2d = zeros( n2, n1 );
    parVelY3dParX2d = zeros( n2, n1 );
    parVelZ3dParX2d = zeros( n2, n1 );
    
    parVelX3dParY2d = zeros( n2, n1 );
    parVelY3dParY2d = zeros( n2, n1 );
    parVelZ3dParY2d = zeros( n2, n1 );
    

    for j = 2:n1-1
        for i = 2:n2-1
            parVelX3dParX2d(i,j) = (u3dOrgShifted(i,j+1) - u3dOrgShifted(i,j-1))/(2*h1);
            parVelY3dParX2d(i,j) = (v3dOrgShifted(i,j+1) - v3dOrgShifted(i,j-1))/(2*h1);
            parVelZ3dParX2d(i,j) = (w3dOrgShifted(i,j+1) - w3dOrgShifted(i,j-1))/(2*h1);

            parVelX3dParY2d(i,j) = (u3dOrgShifted(i+1,j) - u3dOrgShifted(i-1,j))/(2*h2);
            parVelY3dParY2d(i,j) = (v3dOrgShifted(i+1,j) - v3dOrgShifted(i-1,j))/(2*h2);
            parVelZ3dParY2d(i,j) = (w3dOrgShifted(i+1,j) - w3dOrgShifted(i-1,j))/(2*h2);
        end
    end

    parVelX3dParX2d(1,:) = 0;
    parVelX3dParX2d(n2,:) = 0;
    parVelX3dParX2d(:,1) = 0;
    parVelX3dParX2d(:,n1) = 0;

    parVelY3dParX2d(1,:) = 0;
    parVelY3dParX2d(n2,:) = 0;
    parVelY3dParX2d(:,1) = 0;
    parVelY3dParX2d(:,n1) = 0;

    parVelZ3dParX2d(1,:) = 0;
    parVelZ3dParX2d(n2,:) = 0;
    parVelZ3dParX2d(:,1) = 0;
    parVelZ3dParX2d(:,n1) = 0;

    parVelX3dParY2d(1,:) = 0;
    parVelX3dParY2d(n2,:) = 0;
    parVelX3dParY2d(:,1) = 0;
    parVelX3dParY2d(:,n1) = 0;

    parVelY3dParY2d(1,:) = 0;
    parVelY3dParY2d(n2,:) = 0;
    parVelY3dParY2d(:,1) = 0;
    parVelY3dParY2d(:,n1) = 0;

    parVelZ3dParY2d(1,:) = 0;
    parVelZ3dParY2d(n2,:) = 0;
    parVelZ3dParY2d(:,1) = 0;
    parVelZ3dParY2d(:,n1) = 0;


    parVelX3dParX3d = parVelX3dParX2d.*parX2dParX3d + parVelX3dParY2d.*parY2dParX3d;
    parVelX3dParY3d = parVelX3dParX2d.*parX2dParY3d + parVelX3dParY2d.*parY2dParY3d;
    parVelX3dParZ3d = parVelX3dParX2d.*parX2dParZ3d + parVelX3dParY2d.*parY2dParZ3d;

    parVelY3dParX3d = parVelY3dParX2d.*parX2dParX3d + parVelY3dParY2d.*parY2dParX3d;
    parVelY3dParY3d = parVelY3dParX2d.*parX2dParY3d + parVelY3dParY2d.*parY2dParY3d;
    parVelY3dParZ3d = parVelY3dParX2d.*parX2dParZ3d + parVelY3dParY2d.*parY2dParZ3d;

    parVelZ3dParX3d = parVelZ3dParX2d.*parX2dParX3d + parVelZ3dParY2d.*parY2dParX3d;
    parVelZ3dParY3d = parVelZ3dParX2d.*parX2dParY3d + parVelZ3dParY2d.*parY2dParY3d;
    parVelZ3dParZ3d = parVelZ3dParX2d.*parX2dParZ3d + parVelZ3dParY2d.*parY2dParZ3d;

    parVelX3dParX3dOut = interp2(x2d, y2d, parVelX3dParX3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelX3dParY3dOut = interp2(x2d, y2d, parVelX3dParY3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelX3dParZ3dOut = interp2(x2d, y2d, parVelX3dParZ3d, itpMesh.x2d, itpMesh.y2d,'spline');

    parVelY3dParX3dOut = interp2(x2d, y2d, parVelY3dParX3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelY3dParY3dOut = interp2(x2d, y2d, parVelY3dParY3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelY3dParZ3dOut = interp2(x2d, y2d, parVelY3dParZ3d, itpMesh.x2d, itpMesh.y2d,'spline');

    parVelZ3dParX3dOut = interp2(x2d, y2d, parVelZ3dParX3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelZ3dParY3dOut = interp2(x2d, y2d, parVelZ3dParY3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parVelZ3dParZ3dOut = interp2(x2d, y2d, parVelZ3dParZ3d, itpMesh.x2d, itpMesh.y2d,'spline');

end