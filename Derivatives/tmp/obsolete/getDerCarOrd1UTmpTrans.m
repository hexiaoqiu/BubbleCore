function [dU3dTmpDx,dV3dTmpDy,dW3dTmpDz] = getDerCarOrd1UTmpTrans(bubble, time, itpMesh)
    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    h1 = bubble.h1;
    h2 = bubble.h2;
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);

    tmp = readField(bubble, 'tmp', time);
    u2dOrg = readField(bubble,'u', time);
    v2dOrg = readField(bubble,'v', time);
    u2d = interp2(bubble.x2dU,bubble.y2dU,u2dOrg,x2d,y2d);
    v2d = interp2(bubble.x2dU,bubble.y2dU,u2dOrg,x2d,y2d);
    [u3d,v3d,w3d] = velocity2DTo3D(u2d, v2d, x2dGrid, y2dGrid);

    u3dTmpSquare = u3d.*(tmp.^2);
    v3dTmpSquare = v3d.*(tmp.^2);
    w3dTmpSquare = w3d.*(tmp.^2);

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    parX2dParX3d =  1 ./ (1+z3dGrid);
    parX2dParZ3d = -1*x3dGrid ./ (1+z3dGrid).^2 ;
    parY2dParY3d = 1 ./ (1+z3dGrid);
    parY2dParZ3d = -1*y3dGrid ./ (1+z3dGrid).^2 ;

    % calculate the derivative in projection coordinate
    dU3dTmpSquareDX2d = zeros( size(tmp) );
    dU3dTmpSquareDY2d = zeros( size(tmp) );
    dV3dTmpSquareDX2d = zeros( size(tmp) );
    dV3dTmpSquareDY2d = zeros( size(tmp) );
    dW3dTmpSquareDX2d = zeros( size(tmp) );
    dW3dTmpSquareDY2d = zeros( size(tmp) );

    dU3dTmpSquareDX2d(:,2:end-1) = ( u3dTmpSquare(:,3:end) - u3dTmpSquare(:,1:end-2) )./(2*h1);
    dV3dTmpSquareDX2d(:,2:end-1) = ( v3dTmpSquare(:,3:end) - v3dTmpSquare(:,1:end-2) )./(2*h1);
    dW3dTmpSquareDX2d(:,2:end-1) = ( w3dTmpSquare(:,3:end) - w3dTmpSquare(:,1:end-2) )./(2*h1);

    dU3dTmpSquareDY2d(2:end-1,:) = ( u3dTmpSquare(3:end,:) - u3dTmpSquare(1:end-2,:) )./(2*h1);
    dV3dTmpSquareDY2d(2:end-1,:) = ( v3dTmpSquare(3:end,:) - v3dTmpSquare(1:end-2,:) )./(2*h1);
    dW3dTmpSquareDY2d(2:end-1,:) = ( w3dTmpSquare(3:end,:) - w3dTmpSquare(1:end-2,:) )./(2*h1);

    dTmpDX3d = parTmpParX2d.*parX2dParX3d;
    dTmpDY3d = parTmpParY2d.*parY2dParY3d;
    dTmpDZ3d = parTmpParX2d.*parX2dParZ3d + parTmpParY2d.*parY2dParZ3d;


end