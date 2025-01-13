function gradient3D = get3DGradBy2DMesh(xVec,yVec,field2D)
    
    [x2d,y2d] = meshgrid(xVec,yVec);
    h1 = xVec(2) - xVec(1);
    h2 = yVec(2) - yVec(1);
    radius = sqrt(x2d.^2 + y2d.^2);

    gradX2d = zeros( size(field2D) );
    gradY2d = zeros( size(field2D) );

    for i_X2d = 1:numel(xVec)
        for i_Y2d = 1:numel(yVec)
            % out of the bubble
            if radius(i_Y2d,i_X2d) > 1
                gradX2d(i_Y2d,i_X2d) = NaN;
                gradY2d(i_Y2d,i_X2d) = NaN;
            else
                % x2d direction derivative
                if (radius(i_Y2d,i_X2d-1)<1) && (radius(i_Y2d,i_X2d+1)<1)
                    gradX2d(i_Y2d,i_X2d) = ( field2D(i_Y2d,i_X2d+1) - field2D(i_Y2d,i_X2d-1) )./ (2*h1);
                elseif (radius(i_Y2d,i_X2d-1)<1) && (radius(i_Y2d,i_X2d+1)>1)
                    gradX2d(i_Y2d,i_X2d) = ( field2D(i_Y2d,i_X2d-2) - 4*field2D(i_Y2d,i_X2d-1) + 3*field2D(i_Y2d,i_X2d) )./ (2*h1);
                elseif (radius(i_Y2d,i_X2d-1)>1) && (radius(i_Y2d,i_X2d+1)<1)
                    gradX2d(i_Y2d,i_X2d) = ( -1*field2D(i_Y2d,i_X2d+2) + 4*field2D(i_Y2d,i_X2d+1) - 3*field2D(i_Y2d,i_X2d) )./ (2*h1);
                end
                % y2d direction derivative
                if (radius(i_Y2d-1,i_X2d)<1) && (radius(i_Y2d+1,i_X2d)<1)
                    gradY2d(i_Y2d,i_X2d) = ( field2D(i_Y2d+1,i_X2d) - field2D(i_Y2d-1,i_X2d) )./ (2*h2);
                elseif (radius(i_Y2d-1,i_X2d)<1) && (radius(i_Y2d+1,i_X2d)>1)
                    gradY2d(i_Y2d,i_X2d) = ( field2D(i_Y2d-2,i_X2d) - 4*field2D(i_Y2d-1,i_X2d) + 3*field2D(i_Y2d,i_X2d) )./ (2*h2);
                elseif (radius(i_Y2d-1,i_X2d)>1) && (radius(i_Y2d+1,i_X2d)<1)
                    gradY2d(i_Y2d,i_X2d) = ( -1*field2D(i_Y2d+2,i_X2d) + 4*field2D(i_Y2d+1,i_X2d) - 3*field2D(i_Y2d,i_X2d) )./ (2*h2);
                end
            end
        end
    end

    gradient3D.gradX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradX2d - x2d.*y2d.*gradY2d;
    gradient3D.gradY3d = - x2d.*y2d.*gradX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradY2d;
    gradient3D.gradZ3d = - x2d.*gradX2d - y2d.*gradY2d;
    
end