function [Q] = getQForSphVel(phi,theta,uPhi,vTheta)
    % get mesh size
    [nTheta, nPhi] = size(phi);

    % get dTheta dPhi
    dTheta = theta(2,1) - theta(1,1);
    dPhi = phi(1,2) - phi(1,1);

    % calculate derivatives:
    gradUPhi_phi = zeros(nTheta,nPhi);
    gradUPhi_theta = zeros(nTheta,nPhi);
    gradVTheta_phi = zeros(nTheta,nPhi);
    gradVTheta_theta = zeros(nTheta,nPhi);
    for idxTheta = 2:nTheta
        gradUPhi_theta(idxTheta,:) = (uPhi(idxTheta,:) - uPhi(idxTheta-1,:))/dTheta;
        gradVTheta_theta(idxTheta,:) = (vTheta(idxTheta,:) - vTheta(idxTheta-1,:))/dTheta;
    end
    gradUPhi_theta(1,:) = (uPhi(2,:) - uPhi(1,:))/dTheta;
    gradVTheta_theta(1,:) = (vTheta(2,:) - vTheta(1,:))/dTheta;
    for idxPhi = 2:nPhi
        gradUPhi_phi(:,idxPhi) = (uPhi(:,idxPhi) - uPhi(:,idxPhi-1))/dPhi;
        gradVTheta_phi(:,idxPhi) = (vTheta(:,idxPhi) - vTheta(:,idxPhi-1))/dPhi;
    end
    gradUPhi_phi(:,1) = (uPhi(:,1) - uPhi(:,end-1))/dPhi;
    gradVTheta_phi(:,1) = (vTheta(:,1) - vTheta(:,end-1))/dPhi;
    
    % calculate tensor
    S_11 = gradVTheta_theta;
    S_12 = 0.5*(gradVTheta_phi + gradUPhi_theta);
    S_21 = 0.5*(gradUPhi_theta + gradVTheta_phi);
    S_22 = gradUPhi_phi;
    Omega_11 = 0;
    Omega_12 = 0.5*(gradVTheta_phi - gradUPhi_theta);
    Omega_21 = 0.5*(gradUPhi_theta - gradVTheta_phi);
    Omega_22 = 0;

    Q = 0.5*(Omega_11.^2 + Omega_12.^2 + Omega_21.^2 + Omega_22.^2 - ...
        S_11.^2 - S_12.^2 - S_21.^2 - S_22.^2);

end

