function [phi, theta] = pos3DtoSph(x3d,y3d,z3d)

    r = ones( size(x3d) );
    [n,m] = size(x3d);

    % theta = zeros(n,m);
    theta = acos(z3d ./ r);
    % theta(r>1) = pi/2;
    
    phi = zeros(n,m);
    for i = 1:n
        for j = 1:m
            
            if (x3d(i,j) > 0)&&(y3d(i,j) > 0)
                phi(i,j) = atan( y3d(i,j)/x3d(i,j) );
            end
            
            if (x3d(i,j) < 0)&&(y3d(i,j) > 0)
                phi(i,j) = pi + atan( y3d(i,j)/x3d(i,j) );
            end

            if (x3d(i,j) < 0)&&(y3d(i,j) < 0)
                phi(i,j) = pi + atan( y3d(i,j)/x3d(i,j) );
            end

            if (x3d(i,j) > 0)&&(y3d(i,j) < 0)
                phi(i,j) = 2*pi + atan( y3d(i,j)/x3d(i,j) );
            end
            
        end
    end


end