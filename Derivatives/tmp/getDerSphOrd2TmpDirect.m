function [parTmpParPhi, parTmpParTheta] = getDerTmpDerSphDirect(bubble, timeStep, itpMesh)

    dTheta = itpMesh.theta(2) - itpMesh.theta(1);
    dPhi = itpMesh.phi(2) - itpMesh.phi(1);
    tmp = itpField(bubble, 'tmp', timeStep, itpMesh);

    parTmpParPhiOrd2 = zeros(size(tmp));
    parTmpParThetaOrd2 = zeros(size(tmp));
    
    parTmpParPhiOrd2(:,2:end-1) = ( tmp(:,3:end) -2*tmp(:,2:end-1) + tmp(:,1:end-2) )./(2*dPhi);
    parTmpParPhiOrd2(:,1) = ( tmp(:,2) - 2*tmp(:,1) tmp(:,end-1) )./(2*dPhi);
    parTmpParPhiOrd2(:,end) = parTmpParPhiOrd2(:,1);
    
    parTmpParThetaOrd2(2:end-1,:) = ( tmp(3:end,:) -2*tmp(2:end-1,:) + tmp(1:end-2,:) )./(2*dTheta);
    parTmpParThetaOrd2(1,:) = 0;
    parTmpParThetaOrd2(end,:) = ( 3*tmp(end,:) - 4*tmp(end-1,:) + 1*tmp(end-2,:) )./(2*dTheta);

    parTmpParPhiOrd2(:,2:end) = ( tmp(:,2:end) - tmp(:,1:end-1) )./(dPhi);
    parTmpParPhiOrd2(:,1) = parTmpParPhiOrd2(:,end);

    parTmpParThetaOrd2(2:end,:) = ( tmp(2:end,:) - tmp(1:end-1,:) )./(dTheta);
    parTmpParThetaOrd2(1,:) = (-3*tmp(1,:) + 4*tmp(2,:) - tmp(3,:))./(2*dTheta);

end