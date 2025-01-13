function [gradX3d, gradY3d, gradZ3d] = grad2dToGrad3d(x2d, y2d,gradX2d, gradY2d)

    gradX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradX2d - x2d.*y2d.*gradY2d;
    gradY3d = - x2d.*y2d.*gradX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradY2d;
    gradZ3d = - x2d.*gradX2d - y2d.*gradY2d;
    
end