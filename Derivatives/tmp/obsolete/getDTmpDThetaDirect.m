function [DTmpDTheta] = getDTmpDThetaDirect(tmp,dTheta)
    % this function use center 1th order scheme to calculate derivative of theta
    DTmpDTheta = zeros( size(tmp) );
    % middle part of tmp
    DTmpDTheta(2:end,:) = ( tmp(2:end,:) - tmp(1:end-1,:) )./dTheta;
    % top boundary
    DTmpDTheta(1,:) = DTmpDTheta(2,:);
end