function [parTmpParPhi, parTmpParTheta] = getDerSphOrd1TmpDirect(bubble, timeStep, itpMesh)

    dTheta = itpMesh.theta(2) - itpMesh.theta(1);
    dPhi = itpMesh.phi(2) - itpMesh.phi(1);
    tmp = itpField(bubble, 'tmp', timeStep, itpMesh);

    parTmpParPhi = zeros(size(tmp));
    parTmpParTheta = zeros(size(tmp));
    
    parTmpParPhi(:,2:end) = ( tmp(:,2:end) - tmp(:,1:end-1) )./(dPhi);
    parTmpParPhi(:,1) = parTmpParPhi(:,end);

    parTmpParTheta(2:end,:) = ( tmp(2:end,:) - tmp(1:end-1,:) )./(dTheta);
    parTmpParTheta(1,:) = (-3*tmp(1,:) + 4*tmp(2,:) - tmp(3,:))./(2*dTheta);

end