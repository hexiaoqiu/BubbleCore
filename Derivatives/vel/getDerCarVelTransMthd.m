function [parU3dParX3dOut, parU3dParY3dOut,parU3dParZ3dOut,parV3dParX3dOut, parV3dParY3dOut,parV3dParZ3dOut,parW3dParX3dOut, parW3dParY3dOut,parW3dParZ3dOut] = getDerCarVelTransMthd(bubble, timeStep, meshOutPut)

    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    n1 = bubble.n1;
    n2 = bubble.n2;
    h1 = bubble.h1;
    h2 = bubble.h2;
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);
    radius = sqrt(x2dGrid.^2 + y2dGrid.^2);
    z3dGrid(radius>=1) = 0;

    u2d = readField(bubble, 'u', timeStep);
    v2d = readField(bubble, 'v', timeStep);   
    u2dShift = interp2(bubble.x2dU, bubble.y2dU, u2d, x2d, y2d);
    v2dShift = interp2(bubble.x2dV, bubble.y2dV, v2d, x2d, y2d);
    [u3d, v3d, w3d] = velocity2DTo3D(u2dShift, v2dShift, x2dGrid, y2dGrid);

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    parX2dParX3d =  1 ./ (1+z3dGrid);
%     parX2dParY3d = zeros(size(x3dGrid));
    parX2dParZ3d = -1*x3dGrid ./ (1+z3dGrid).^2 ;

%     parY2dParX3d = zeros(size(y3dGrid));
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


    parU3dParX3d = parU3dParX2d.*parX2dParX3d;
    parU3dParY3d = parU3dParY2d.*parY2dParY3d;
    parU3dParZ3d = parU3dParX2d.*parX2dParZ3d + parU3dParY2d.*parY2dParZ3d;
    
    parV3dParX3d = parV3dParX2d.*parX2dParX3d;
    parV3dParY3d = parV3dParY2d.*parY2dParY3d;
    parV3dParZ3d = parV3dParX2d.*parX2dParZ3d + parV3dParY2d.*parY2dParZ3d;
    
    parW3dParX3d = parW3dParX2d.*parX2dParX3d;
    parW3dParY3d = parW3dParY2d.*parY2dParY3d;
    parW3dParZ3d = parW3dParX2d.*parX2dParZ3d + parW3dParY2d.*parY2dParZ3d;


    parU3dParX3dOut = interp2(x2d, y2d, parU3dParX3d, meshOutPut.x2d, meshOutPut.y2d);
    parU3dParY3dOut = interp2(x2d, y2d, parU3dParY3d, meshOutPut.x2d, meshOutPut.y2d);
    parU3dParZ3dOut = interp2(x2d, y2d, parU3dParZ3d, meshOutPut.x2d, meshOutPut.y2d);
    
    parV3dParX3dOut = interp2(x2d, y2d, parV3dParX3d, meshOutPut.x2d, meshOutPut.y2d);
    parV3dParY3dOut = interp2(x2d, y2d, parV3dParY3d, meshOutPut.x2d, meshOutPut.y2d);
    parV3dParZ3dOut = interp2(x2d, y2d, parV3dParZ3d, meshOutPut.x2d, meshOutPut.y2d);

    parW3dParX3dOut = interp2(x2d, y2d, parW3dParX3d, meshOutPut.x2d, meshOutPut.y2d);
    parW3dParY3dOut = interp2(x2d, y2d, parW3dParY3d, meshOutPut.x2d, meshOutPut.y2d);
    parW3dParZ3dOut = interp2(x2d, y2d, parW3dParZ3d, meshOutPut.x2d, meshOutPut.y2d);

end