function [derCarVel] = getDerCarVelTrans(meshU,meshV,meshS,u2d,v2d)

    x2d = meshS.x2d;
    y2d = meshS.y2d;
    n1 = numel(x2d);
    n2 = numel(y2d);
    h1 = x2d(2) - x2d(1);
    h2 = y2d(2) - y2d(1);
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);
    radius = sqrt(x2dGrid.^2 + y2dGrid.^2);
    z3dGrid(radius>=1) = 0;
   
    u2dShift = interp2(meshU.x2d, meshU.y2d, u2d, x2d, y2d);
    v2dShift = interp2(meshV.x2d, meshV.y2d, v2d, x2d, y2d);
    [u3d, v3d, w3d] = velocity2DTo3D(u2dShift, v2dShift, x2dGrid, y2dGrid);

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    parX2dParX3d =  1 ./ (1+z3dGrid);
    parX2dParZ3d = -1*x3dGrid ./ (1+z3dGrid).^2 ;

    parY2dParY3d = 1 ./ (1+z3dGrid);
    parY2dParZ3d = -1*y3dGrid ./ (1+z3dGrid).^2 ;

    % calculate the derivative in projection coordinate
    parU3dParX2d = zeros( n2, n1 );
    parU3dParY2d = zeros( n2, n1 );
    parU3dParX2d(:,2:n1-1) = (u3d(:,3:n1) - u3d(:,1:n1-2)) ./ (2*h1);
    parU3dParY2d(2:n2-1,:) = (u3d(3:n2,:) - u3d(1:n2-2,:)) ./ (2*h2);
    parV3dParX2d = zeros( n2, n1 );
    parV3dParY2d = zeros( n2, n1 );
    parV3dParX2d(:,2:n1-1) = (v3d(:,3:n1) - v3d(:,1:n1-2)) ./ (2*h1);
    parV3dParY2d(2:n2-1,:) = (v3d(3:n2,:) - v3d(1:n2-2,:)) ./ (2*h2);
    parW3dParX2d = zeros( n2, n1 );
    parW3dParY2d = zeros( n2, n1 );
    parW3dParX2d(:,2:n1-1) = (w3d(:,3:n1) - w3d(:,1:n1-2)) ./ (2*h1);
    parW3dParY2d(2:n2-1,:) = (w3d(3:n2,:) - w3d(1:n2-2,:)) ./ (2*h2);


    derCarVel.dU3d_dX3d = parU3dParX2d.*parX2dParX3d;
    derCarVel.dU3d_dY3d = parU3dParY2d.*parY2dParY3d;
    derCarVel.dU3d_dZ3d = parU3dParX2d.*parX2dParZ3d + parU3dParY2d.*parY2dParZ3d;
    
    derCarVel.dV3d_dX3d = parV3dParX2d.*parX2dParX3d;
    derCarVel.dV3d_dY3d = parV3dParY2d.*parY2dParY3d;
    derCarVel.dV3d_dZ3d = parV3dParX2d.*parX2dParZ3d + parV3dParY2d.*parY2dParZ3d;
    
    derCarVel.dW3d_dX3d = parW3dParX2d.*parX2dParX3d;
    derCarVel.dW3d_dY3d = parW3dParY2d.*parY2dParY3d;
    derCarVel.dW3d_dZ3d = parW3dParX2d.*parX2dParZ3d + parW3dParY2d.*parY2dParZ3d;


end