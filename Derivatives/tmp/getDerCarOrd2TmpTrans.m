function [parTmpParX3dOrd2Out, parTmpParY3dOrd2Out, parTmpParZ3dOrd2Out] = getDerCarOrd2TmpTrans(bubble, timeStep, meshOutPut)

    x2dVector = bubble.x2dS;
    y2dVector = bubble.y2dS;
    h1 = bubble.h1;
    h2 = bubble.h2;
    [x2d, y2d] = meshgrid(x2dVector,y2dVector);
    d = (1 + x2d.^2 + y2d.^2);

    tmp = readField(bubble, 'tmp', timeStep);


    % calculate the local derivative of x2d y2d to x3d y3d z3d

    % calculate the derivative in projection coordinate
    parTmpParX2d = zeros( size(tmp) );
    parTmpParY2d = zeros( size(tmp) );
    parTmpParX2dOrd2 = zeros( size(tmp) );
    parTmpParY2dOrd2 = zeros( size(tmp) );
    parTmpParX2dY2dOrd2 = zeros( size(tmp) );

    parTmpParX2d(:,2:end-1) = (tmp(:,3:end) - tmp(:,1:end-2)) ./ (2*h1);

    parTmpParX2dOrd2(:,2:end-1) = (tmp(:,3:end) -2.*tmp(:,2:end-1) + tmp(:,1:end-2)) ./ (h1^2);
    % parTmpParX2dOrd2(:,3:end-2) = (-1*tmp(:,5:end) + 16*tmp(:,4:end-1) - 30*tmp(:,3:end-2) + 16*tmp(:,2:end-3) - tmp(:,1:end-4) ) ./ (12*(h1^2));
    
    parTmpParY2d(2:end-1,:) = (tmp(3:end,:) - tmp(1:end-2,:)) ./ (2*h2);
    parTmpParY2dOrd2(2:end-1,:) = (tmp(3:end,:) -2.*tmp(2:end-1,:) + tmp(1:end-2,:)) ./ (h2^2);
    parTmpParX2dY2dOrd2(2:end-1,2:end-1) = (tmp(3:end,3:end) + tmp(1:end-2,1:end-2) - tmp(3:end,1:end-2) - tmp(1:end-2,3:end)) ./ (4*h2*h1);


    parTmpParX3dOrd2 = (1/4)*(d.^2).*parTmpParX2dOrd2 + (1/2)*x2d.*d.*parTmpParX2d;
    parTmpParY3dOrd2 = (1/4)*(d.^2).*parTmpParY2dOrd2 + (1/2)*y2d.*d.*parTmpParY2d;
    parTmpParZ3dOrd2 = (1/16)*(x2d + 5*x2d.^3 + 5*x2d.*(y2d.^2)).*(d.^3).*parTmpParX2d + (1/16)*(y2d + 5*y2d.^3 + 5*y2d.*(x2d.^2)).*(d.^3).*parTmpParY2d ...,
                    + (1/16)*(x2d.^2).*(d.^4).*parTmpParX2dOrd2 + (1/16)*(y2d.^2).*(d.^4).*parTmpParY2dOrd2 ...,
                    + (1/8)*x2d.*y2d.*(d.^4).*parTmpParX2dY2dOrd2;

    parTmpParX3dOrd2Out = interp2(x2d, y2d, parTmpParX3dOrd2, meshOutPut.x2d, meshOutPut.y2d,'linear');
    parTmpParY3dOrd2Out = interp2(x2d, y2d, parTmpParY3dOrd2, meshOutPut.x2d, meshOutPut.y2d,'linear');
    parTmpParZ3dOrd2Out = interp2(x2d, y2d, parTmpParZ3dOrd2, meshOutPut.x2d, meshOutPut.y2d,'linear');

end