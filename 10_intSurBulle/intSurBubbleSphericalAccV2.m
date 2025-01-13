function [A] = intSurBubbleSphericalAccV2(phi,theta,field)
    % phi and theta is position vector
    n_phi = numel(phi);
    n_theta = numel(theta);
    numIntervalPhi = (n_phi-1)/3;
    numIntervalTheta = (n_theta-1)/3;
    dPhi = phi(2) - phi(1);
    dTheta = theta(2) - theta(1);

    A = 0;
    for idxIntervalPhi = 1:numIntervalPhi
        for idxIntervalTheta = 1:numIntervalTheta
            % phi_sub = phi(1+(idxIntervalPhi-1)*3:1:4+(idxIntervalPhi-1)*3);
            theta_sub = theta(1+(idxIntervalTheta-1)*3:1:4+(idxIntervalTheta-1)*3);

            % [~,thetaGrid_sub] = meshgrid(phi_sub,theta_sub);
            
            field_sub = field(1+(idxIntervalTheta-1)*3:1:4+(idxIntervalTheta-1)*3,1+(idxIntervalPhi-1)*3:1:4+(idxIntervalPhi-1)*3);
            field_sub(:,1:end) = field_sub(:,1:end).*sin(theta_sub);
            A = A + int2DimSimpsonOrder3AccV2(dPhi,dTheta,field_sub);
        end
    end

end