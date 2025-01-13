function [gradPhi,gradTheta] = getGradCoordSph(dPhi, dTheta, fieldSph)
    
    [nTheta, nPhi] = size(fieldSph);

    gradTheta = zeros(nTheta, nPhi);
    gradPhi = zeros(nTheta, nPhi);

    gradTheta(1,:) = ( -fieldSph(3,:) + 4*fieldSph(2,:) - 3*fieldSph(1,:) )./ (2*dTheta);
    gradTheta(2:end-1,:) = (fieldSph(3:end,:) - fieldSph(1:end-2,:))./ (2*dTheta);
    gradTheta(end,:) = ( fieldSph(end-2,:) - 4*fieldSph(end-1,:) + 3*fieldSph(end,:) )./ (2*dTheta);
    
    gradPhi(:,2:end-1) = (fieldSph(:,3:end) - fieldSph(:,1:end-2))./ (2*dPhi);
    gradPhi(:,end) = ( fieldSph(:,2) - fieldSph(:,end-1))./ (2*dPhi);
    gradPhi(:,1) = ( fieldSph(:,2) - fieldSph(:,end-1))./ (2*dPhi);

end