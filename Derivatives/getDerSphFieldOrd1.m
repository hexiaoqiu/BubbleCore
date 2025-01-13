function [dPsiDPhi, dPsiDTheta] = getDerSphFieldOrd1(dPhi,dTheta,psi)

    dPsiDPhi = zeros(size(psi));
    dPsiDTheta = zeros(size(psi));

    dPsiDPhi(:,2:end) = ( psi(:,2:end) - psi(:,1:end-1) )./(dPhi);
    dPsiDPhi(:,1) = dPsiDPhi(:,end);

    dPsiDTheta(2:end,:) = ( psi(2:end,:) - psi(1:end-1,:) )./(dTheta);
    dPsiDTheta(1,:) = (-3*psi(1,:) + 4*psi(2,:) - psi(3,:))./(2*dTheta);
end