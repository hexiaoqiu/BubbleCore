function [cartesianMesh] = createCartesianMesh(x3dLim,y3dLim,N_x,N_y)
    
    x3dMin = x3dLim(1);
    x3dMax = x3dLim(2);
    y3dMin = y3dLim(1);
    y3dMax = y3dLim(2);

    cartesianMesh.x3d = linspace(x3dMin,x3dMax,N_x);
    cartesianMesh.y3d = linspace(y3dMin,y3dMax,N_y)';
    cartesianMesh.dx = (x3dMax - x3dMin)/(N_x-1);
    cartesianMesh.dy = (y3dMax - y3dMin)/(N_y-1);

    [x3d,y3d] = meshgrid(cartesianMesh.x3d,cartesianMesh.y3d);
    z3d = real( sqrt(1 - x3d.^2 - y3d.^2) );
    r = sqrt( x3d.^2 + y3d.^2 );
    z3d(r>=1) = 0;
    cartesianMesh.z3d = z3d;


    [cartesianMesh.x2d, cartesianMesh.y2d] = pos3Dto2D(x3d,y3d);

end