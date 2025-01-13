function [parVelX3dParX3dOut, parVelX3dParY3dOut, parVelX3dParZ3dOut, parVelY3dParX3dOut, parVelY3dParY3dOut, parVelY3dParZ3dOut, parVelZ3dParX3dOut, parVelZ3dParY3dOut, parVelZ3dParZ3dOut] = getDerVelDerCartesian(bubble, timeStep, itpMesh)

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
    radius = sqrt(x2dGrid.^2 + y2dGrid.^2);
    [x3d,y3d,z3d] = pos2Dto3D(x2dGrid,y2dGrid);

    parX2dParX3d = gpuArray( 1 ./ (1+z3d) );
    parX2dParY3d = gpuArray( zeros(size(x3d)) );
    parX2dParZ3d = gpuArray( -1*x3d ./ (1+z3d).^2 );

    parY2dParX3d = gpuArray( zeros(size(y3d)) );
    parY2dParY3d = gpuArray( 1 ./ (1+z3d) );
    parY2dParZ3d = gpuArray( -1*y3d ./ (1+z3d).^2 );
                    
    u2dOrg = readField(bubble, 'u', timeStep);
    v2dOrg = readField(bubble, 'v', timeStep);
    u2dOrgShifted = interp2(x2dU, y2dU, u2dOrg, x2d, y2d);
    u2dOrgShifted(radius>=1) = 0;
    v2dOrgShifted = interp2(x2dV, y2dV, v2dOrg, x2d, y2d);
    v2dOrgShifted(radius>=1) = 0;
    [u3dOrgShiftedCPU, v3dOrgShiftedCPU, w3dOrgShiftedCPU] = velocity2DTo3D(u2dOrgShifted, v2dOrgShifted, x2dGrid, y2dGrid);

    u3dOrgShifted = gpuArray(u3dOrgShiftedCPU);
    v3dOrgShifted = gpuArray(v3dOrgShiftedCPU);
    w3dOrgShifted = gpuArray(w3dOrgShiftedCPU);
    
    % calculate the derivative in projection coordinate
    parVelX3dParX2d = gpuArray( zeros( n2, n1 ) );
    parVelY3dParX2d = gpuArray( zeros( n2, n1 ) );
    parVelZ3dParX2d = gpuArray( zeros( n2, n1 ) );
    
    parVelX3dParY2d = gpuArray( zeros( n2, n1 ) );
    parVelY3dParY2d = gpuArray( zeros( n2, n1 ) );
    parVelZ3dParY2d = gpuArray( zeros( n2, n1 ) );
    

    parVelX3dParX2d(:,2:n1-1) = (u3dOrgShifted(:,3:n1) - u3dOrgShifted(:,1:n1-2)) ./ (2*h1);
    parVelY3dParX2d(:,2:n1-1) = (v3dOrgShifted(:,3:n1) - v3dOrgShifted(:,1:n1-2)) ./ (2*h1);
    parVelZ3dParX2d(:,2:n1-1) = (w3dOrgShifted(:,3:n1) - w3dOrgShifted(:,1:n1-2)) ./ (2*h1);

    parVelX3dParY2d(2:n2-1,:) = (u3dOrgShifted(3:n2,:) - u3dOrgShifted(1:n2-2,:)) ./ (2*h2);
    parVelY3dParY2d(2:n2-1,:) = (v3dOrgShifted(3:n2,:) - v3dOrgShifted(1:n2-2,:)) ./ (2*h2);
    parVelZ3dParY2d(2:n2-1,:) = (w3dOrgShifted(3:n2,:) - w3dOrgShifted(1:n2-2,:)) ./ (2*h2);


    parVelX3dParX3d = parVelX3dParX2d.*parX2dParX3d + parVelX3dParY2d.*parY2dParX3d;
    parVelX3dParY3d = parVelX3dParX2d.*parX2dParY3d + parVelX3dParY2d.*parY2dParY3d;
    parVelX3dParZ3d = parVelX3dParX2d.*parX2dParZ3d + parVelX3dParY2d.*parY2dParZ3d;

    parVelY3dParX3d = parVelY3dParX2d.*parX2dParX3d + parVelY3dParY2d.*parY2dParX3d;
    parVelY3dParY3d = parVelY3dParX2d.*parX2dParY3d + parVelY3dParY2d.*parY2dParY3d;
    parVelY3dParZ3d = parVelY3dParX2d.*parX2dParZ3d + parVelY3dParY2d.*parY2dParZ3d;

    parVelZ3dParX3d = parVelZ3dParX2d.*parX2dParX3d + parVelZ3dParY2d.*parY2dParX3d;
    parVelZ3dParY3d = parVelZ3dParX2d.*parX2dParY3d + parVelZ3dParY2d.*parY2dParY3d;
    parVelZ3dParZ3d = parVelZ3dParX2d.*parX2dParZ3d + parVelZ3dParY2d.*parY2dParZ3d;

    parVelX3dParX3dOut = interp2(x2d, y2d, parVelX3dParX3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelX3dParY3dOut = interp2(x2d, y2d, parVelX3dParY3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelX3dParZ3dOut = interp2(x2d, y2d, parVelX3dParZ3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;

    parVelY3dParX3dOut = interp2(x2d, y2d, parVelY3dParX3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelY3dParY3dOut = interp2(x2d, y2d, parVelY3dParY3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelY3dParZ3dOut = interp2(x2d, y2d, parVelY3dParZ3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;

    parVelZ3dParX3dOut = interp2(x2d, y2d, parVelZ3dParX3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelZ3dParY3dOut = interp2(x2d, y2d, parVelZ3dParY3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;
    parVelZ3dParZ3dOut = interp2(x2d, y2d, parVelZ3dParZ3d, itpMesh.x2d, itpMesh.y2d,'cubic') ;

end