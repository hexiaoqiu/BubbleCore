function [A] = intSurBubbleSphericalWithResCPU(phi_field, theta_field, field, N)
    
    phiMax = max(phi_field,[],'all');
    phiMin = min(phi_field,[],'all');
    thetaMax = max(theta_field,[],'all');
    thetaMin = min(theta_field,[],'all');

    phi = linspace(phiMin,phiMax,N+1);
    theta = linspace(thetaMin,thetaMax,N+1);
    dPhi = (phiMax - phiMin)/N;
    dTheta = (thetaMax - thetaMin)/N;
    dPhiForIntegral = dPhi/3;
    dThetaForIntegral = dTheta/3;


    A = 0;
    for i = 1:N
        aimPhi = phi(i);
        parfor j = 1:N
            phi_sub = linspace(aimPhi,aimPhi+dPhi,4);
            theta_sub = linspace(theta(j),theta(j)+dTheta,4)';

            field_sub = interp2(phi_field, theta_field, field, phi_sub, theta_sub);
            field_sub(:,1:end) = field_sub(:,1:end).*sin(theta_sub);
            
            
            A = A + int2DimSimpsonOrder3Acc(dPhiForIntegral,dThetaForIntegral,field_sub);
        end
    end

end