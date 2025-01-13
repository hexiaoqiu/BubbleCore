function [x,y,z,x2d,y2d,theta,phi,l] = obtainHorizontal(degSigma,N)
    r = 1;
    sigma = deg2rad(degSigma);
    yStart = r*sin(sigma);
    yEnd = -r*sin(sigma);
    y = linspace(yStart,yEnd,N);
    xFix = round( r*cos(sigma) );
    x = linspace(xFix,xFix,N);
    z = sqrt(1- x.^2 - y.^2);
    theta = acos(z ./ r);
    phi = atan(y ./ x);
    l = linspace(0,pi*r*sin(sigma),N);
    % transform to 2D position
    x2d = 1 * x ./ (1 + z);
    y2d = 1 * y ./ (1 + z);
end

