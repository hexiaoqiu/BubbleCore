function [I] = int2DimSimpsonOrder3AccV2(dx, dy, f)
    h = (3*dy/8)*(f(1,:) + 3*f(2,:) + 3*f(3,:) + f(4,:));
    I = (3*dx/8)*(h(1) + 3*h(2) + 3*h(3) + h(4));
end