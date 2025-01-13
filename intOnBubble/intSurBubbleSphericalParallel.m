function [A] = intSurBubbleSphericalParallel(phi,theta,field)
    
    n_phi = numel(phi);
    n_theta = numel(theta);
    numIntervalPhi = (n_phi-1)/3;
    numIntervalTheta = (n_theta-1)/3;

    A = 0;
    for idxIntervalPhi = 1:numIntervalPhi
        prefixPhi = (idxIntervalPhi-1)*3;
        phi_sub = phi(1+prefixPhi:4+prefixPhi);
        parfor idxIntervalTheta = 1:numIntervalTheta

            prefixTheta = (idxIntervalTheta-1)*3;
            theta_sub = theta(1+prefixTheta:4+prefixTheta);
            [~,thetaGrid_sub] = meshgrid(phi_sub,theta_sub);

            slicePrefix = 2*idxIntervalTheta -3 + 1;
            field_sub_1 = field(idxIntervalTheta + slicePrefix,:);
            slicePrefix = 2*idxIntervalTheta -3 + 2;
            field_sub_2 = field(idxIntervalTheta + slicePrefix,:);
            slicePrefix = 2*idxIntervalTheta -3 + 3;
            field_sub_3 = field(idxIntervalTheta + slicePrefix,:);
            slicePrefix = 2*idxIntervalTheta -3 + 4;
            field_sub_4 = field(idxIntervalTheta + slicePrefix,:);

            field_sub = zeros(4,4);
            field_sub(1,:) = field_sub_1(1,1+prefixPhi:4+prefixPhi);
            field_sub(2,:) = field_sub_2(1,1+prefixPhi:4+prefixPhi);
            field_sub(3,:) = field_sub_3(1,1+prefixPhi:4+prefixPhi);
            field_sub(4,:) = field_sub_4(1,1+prefixPhi:4+prefixPhi);
            
            A = A + int2DimSimpsonOrder3(phi_sub,theta_sub,field_sub.*sin(thetaGrid_sub));
        end
    end
end