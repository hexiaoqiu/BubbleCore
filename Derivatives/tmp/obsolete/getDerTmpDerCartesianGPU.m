function [parTmpParX3dOut, parTmpParY3dOut, parTmpParZ3dOut] = getDerTmpDerCartesianGPU(bubble, timeStep, itpMesh)

    n1 = bubble.n1;
    n2 = bubble.n2;

    x2d  = bubble.x2dS;
    y2d  = bubble.y2dS;
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

    tmpOrgCPU = readField(bubble, 'tmp', timeStep);
    tmpOrgCPU(radius>=1) = 1;

    tmpOrg = gpuArray( tmpOrgCPU );
    
    % calculate the derivative in projection coordinate
    parTmpParX2d = gpuArray( zeros( n2, n1 ) );
    parTmpParY2d = gpuArray( zeros( n2, n1 ) );
    

    parTmpParX2d(:,2:n1-1) = (tmpOrg(:,3:n1) - tmpOrg(:,1:n1-2)) ./ (2*h1);
    parTmpParY2d(2:n2-1,:) = (tmpOrg(3:n2,:) - tmpOrg(1:n2-2,:)) ./ (2*h2);



    parTmpParX3d = parTmpParX2d.*parX2dParX3d + parTmpParY2d.*parY2dParX3d;
    parTmpParY3d = parTmpParX2d.*parX2dParY3d + parTmpParY2d.*parY2dParY3d;
    parTmpParZ3d = parTmpParX2d.*parX2dParZ3d + parTmpParY2d.*parY2dParZ3d;

    parTmpParX3dOut = interp2(x2d, y2d, parTmpParX3d, itpMesh.x2d, itpMesh.y2d,'cubic');
    parTmpParY3dOut = interp2(x2d, y2d, parTmpParY3d, itpMesh.x2d, itpMesh.y2d,'cubic');
    parTmpParZ3dOut = interp2(x2d, y2d, parTmpParZ3d, itpMesh.x2d, itpMesh.y2d,'cubic');

end