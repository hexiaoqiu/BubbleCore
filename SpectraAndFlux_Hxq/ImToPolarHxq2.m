function [polarField] = ImToPolarHxq2(field)

    [n_x,n_y] = size(field);
    x = -(n_x/2):1:(n_x/2);
    y = -(n_y/2):1:(n_y/2);

    r = linspace(0,L_x,n_x/2);
    theta = linspace(0,pi*2,n_y);

    x2d_polar = zeros(n_x/2,n_y);
    y2d_polar = zeros(n_x/2,n_y);
    for idxR = 1:n_x/2
        for idxTheta = 1:n_y

            x2d_polar(idxR,idxTheta) = r(idxR)*cos(theta(idxTheta));
            y2d_polar(idxR,idxTheta) = r(idxR)*sin(theta(idxTheta));

        end
    end
    polarField = interp2(y2d,x2d,field,y2d_polar,x2d_polar) ;
 
end