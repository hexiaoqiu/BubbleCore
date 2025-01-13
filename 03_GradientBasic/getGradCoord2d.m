function [gradX2d,gradY2d] = getGradCoord2d(h1, h2, field2D)

    gradX2d = zeros( size(field2D) );
    gradY2d = zeros( size(field2D) );

    gradX2d(:,2:end-1) = ( field2D(:,3:end) - field2D(:,1:end-2) )./ (2*h1);
    gradY2d(2:end-1,:) = ( field2D(3:end,:) - field2D(1:end-2,:) )./ (2*h2);
    
end