function [parU3dParPhi, parU3dParTheta, parV3dParPhi, parV3dParTheta, parW3dParPhi, parW3dParTheta] = getDerVelDerSphDirect(bubble, timeStep, itpMesh)

    dTheta = itpMesh.theta(2) - itpMesh.theta(1);
    dPhi = itpMesh.phi(2) - itpMesh.phi(1);
    [u3d,v3d,w3d]=obtainU3d(bubble,timeStep,itpMesh);

    parU3dParPhi = zeros(size(u3d));
    parU3dParTheta = zeros(size(u3d));
    parU3dParPhi(:,2:end) = ( u3d(:,2:end) - u3d(:,1:end-1) )./(dPhi);
    parU3dParPhi(:,1) = parU3dParPhi(:,end);
    parU3dParTheta(2:end,:) = ( u3d(2:end,:) - u3d(1:end-1,:) )./(dTheta);
    parU3dParTheta(1,:) = (-3*u3d(1,:) + 4*u3d(2,:) - u3d(3,:))./(2*dTheta);

    parV3dParPhi = zeros(size(v3d));
    parV3dParTheta = zeros(size(v3d));
    parV3dParPhi(:,2:end) = ( v3d(:,2:end) - v3d(:,1:end-1) )./(dPhi);
    parV3dParPhi(:,1) = parV3dParPhi(:,end);
    parV3dParTheta(2:end,:) = ( v3d(2:end,:) - v3d(1:end-1,:) )./(dTheta);
    parV3dParTheta(1,:) = (-3*v3d(1,:) + 4*v3d(2,:) - v3d(3,:))./(2*dTheta);
    
    parW3dParPhi = zeros(size(w3d));
    parW3dParTheta = zeros(size(w3d));
    parW3dParPhi(:,2:end) = ( w3d(:,2:end) - w3d(:,1:end-1) )./(dPhi);
    parW3dParPhi(:,1) = parU3dParPhi(:,end);
    parW3dParTheta(2:end,:) = ( w3d(2:end,:) - w3d(1:end-1,:) )./(dTheta);
    parW3dParTheta(1,:) = (-3*w3d(1,:) + 4*w3d(2,:) - w3d(3,:))./(2*dTheta);

    
end