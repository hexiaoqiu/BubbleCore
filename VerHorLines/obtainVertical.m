function [x,y,z,x2d,y2d,theta,phi,l] = obtainVertical(degSigma,N)
    r = 1;
    radSigma = deg2rad(degSigma);
    xStart = r*cos(radSigma);
    xEnd = -1*r*cos(radSigma);
    x = linspace(xStart,xEnd,N);
    yFix = r*sin(radSigma);
    y = linspace(yFix,yFix,N);
    z = sqrt(1- x.^2 - y.^2);
    theta = acos(z ./ r);
    phi = atan(y ./ x);
    l = linspace(0,pi*r*cos(radSigma),N);
    % transform to 2D position
    x2d = 1 * x ./ (1 + z);
    y2d = 1 * y ./ (1 + z);
end

