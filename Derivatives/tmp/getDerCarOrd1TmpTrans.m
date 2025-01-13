function [parTmpParX3d, parTmpParY3d, parTmpParZ3d] = getDerCarOrd1TmpTrans(x2d,y2d,tmp)

    h1 = x2d(2) - x2d(1);
    h2 = y2d(2) - y2d(1);
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3dGrid,y3dGrid,z3dGrid] = pos2Dto3D(x2dGrid,y2dGrid);


    % calculate the local derivative of x2d y2d to x3d y3d z3d
    parX2dParX3d =  1 ./ (1+z3dGrid);
    parX2dParZ3d = -1*x3dGrid ./ (1+z3dGrid).^2 ;

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

end