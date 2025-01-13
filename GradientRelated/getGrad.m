function [grad] = getGrad(bubble, field)
    
    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    h1 = x2d(2) - x2d(1);
    h2 = y2d(2) - y2d(1);

    gradX2d = zeros( size(field) );
    gradY2d = zeros( size(field) );

    gradX2d(:,2:end-1) = (field(:,3:end) - field(:,1:end-2)) ./ (2*h1);
    gradY2d(2:end-1,:) = (field(3:end,:) - field(1:end-2,:)) ./ (2*h2);

    grad.gradX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradX2d - x2d.*y2d.*gradY2d;
    grad.gradY3d = - x2d.*y2d.*gradX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradY2d;
    grad.gradZ3d = - x2d.*gradX2d - y2d.*gradY2d;

end