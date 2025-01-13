function [parTmpParX3dOut, parTmpParY3dOut, parTmpParZ3dOut] = getDTmpCartesianTrans(bubble, timeStep, meshOutPut)

    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    h1 = bubble.h1;
    h2 = bubble.h2;
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);

    tmp = readField(bubble, 'tmp', timeStep);


    % calculate the local derivative of x2d y2d to x3d y3d z3d
    parX2dParX3d =  1 ./ (1+z3dGrid);
%     parX2dParY3d = zeros(size(x3dGrid));
    parX2dParZ3d = -1*x3dGrid ./ (1+z3dGrid).^2 ;

%     parY2dParX3d = zeros(size(y3dGrid));
    parY2dParY3d = 1 ./ (1+z3dGrid);
    parY2dParZ3d = -1*y3dGrid ./ (1+z3dGrid).^2 ;

    % calculate the derivative in projection coordinate
    parTmpParX2d = zeros( size(tmp) );
    parTmpParY2d = zeros( size(tmp) );
    

    parTmpParX2d(:,2:end-1) = (tmp(:,3:end) - tmp(:,1:end-2)) ./ (2*h1);
    parTmpParY2d(2:end-1,:) = (tmp(3:end,:) - tmp(1:end-2,:)) ./ (2*h2);


    parTmpParX3d = parTmpParX2d.*parX2dParX3d;
    parTmpParY3d = parTmpParY2d.*parY2dParY3d;
    parTmpParZ3d = parTmpParX2d.*parX2dParZ3d + parTmpParY2d.*parY2dParZ3d;

    parTmpParX3dOut = interp2(x2d, y2d, parTmpParX3d, meshOutPut.x2d, meshOutPut.y2d,'linear');
    parTmpParY3dOut = interp2(x2d, y2d, parTmpParY3d, meshOutPut.x2d, meshOutPut.y2d,'linear');
    parTmpParZ3dOut = interp2(x2d, y2d, parTmpParZ3d, meshOutPut.x2d, meshOutPut.y2d,'linear');

end