function [A] = intSurBubbleSphericalWithResGPUSingleThread(phi_field, theta_field, field, N)
    
    phiMax = max(phi_field,[],'all');
    phiMin = min(phi_field,[],'all');
    thetaMax = max(theta_field,[],'all');
    thetaMin = min(theta_field,[],'all');

    phi = linspace(phiMin,phiMax,N+1);
    theta = linspace(thetaMin,thetaMax,N+1);
    dPhiForIntegral = (phiMax-phiMin)/N/3;
    dThetaForIntegral = (thetaMax-thetaMin)/N/3;

    % use gpu acceleration
    phi_fieldGPU = gpuArray(phi_field);
    theta_fieldGPU = gpuArray(theta_field);
    fieldGPU = gpuArray(field);

    A = 0;
    for i = 1:N
        for j = 1:N
            phi_sub = gpuArray( linspace(phi(i),phi(i+1),4) );
            theta_sub = gpuArray( linspace(theta(j),theta(j+1),4)' );

%             phi_sub = linspace(phi(i),phi(i+1),4) ;
%             theta_sub = linspace(theta(j),theta(j+1),4)' ;

            field_sub = interp2(phi_fieldGPU, theta_fieldGPU, fieldGPU, phi_sub, theta_sub) ;
            field_sub(:,1:end) = field_sub(:,1:end).* sin(theta_sub);

%             field_sub = interp2(phi_field, theta_field, field, phi_sub, theta_sub) ;
%             field_sub(:,1:end) = field_sub(:,1:end).* sin(theta_sub);
            
            
            A = A + int2DimSimpsonOrder3Acc(dPhiForIntegral,dThetaForIntegral,gather(field_sub));
%             A = A + int2DimSimpsonOrder3Acc(dPhiForIntegral,dThetaForIntegral,field_sub);
%             if A == -Inf
%                 disp('Surface integration have met a fatal error !');
%             end
        end
    end

end