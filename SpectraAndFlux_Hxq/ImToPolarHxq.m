function [polarField] = ImToPolarHxq(field, x2d, y2d)

    [n_x,n_y] = size(field);
    L_x = x2d(end) - x2d(1);
    % L_y = y2d(end) - y2d(1);

    n_thetaSph = n_x/2;
    thetaSphVec = linspace(0,pi/2,n_thetaSph+1);
    thetaSphVec = thetaSphVec(2:end);

    rPolar = 1/(L_x/2)*sin(thetaSphVec)./(1 + cos(thetaSphVec));
    thetaPolar = linspace(0,pi*2,n_y+1);

    x2d_polar = zeros(n_x/2,n_y);
    y2d_polar = zeros(n_x/2,n_y);
    for idxR = 1:n_x/2
        for idxTheta = 1:n_y

            x2d_polar(idxR,idxTheta) = rPolar(idxR)*cos(thetaPolar(idxTheta));
            y2d_polar(idxR,idxTheta) = rPolar(idxR)*sin(thetaPolar(idxTheta));

        end
    end
    polarField = interp2(y2d,x2d,field,y2d_polar,x2d_polar) ;
 
end