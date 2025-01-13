function [gradX3d, gradY3d, gradZ3d] = gradSphToGrad3d(phi, theta, gradPhi, gradTheta)
    
    gradX3d = ...,
        cos(theta).*cos(phi).*gradTheta + (-sin(phi)./sin(theta)).*gradPhi;
    gradY3d = ...,
        cos(theta).*sin(phi).*gradTheta + cos(phi)./sin(theta).*gradPhi;
    gradZ3d = -sin(theta).*gradTheta;

end