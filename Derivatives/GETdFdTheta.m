function [dFdTheta] = GETdFdTheta(f,dTheta)
    dFdTheta = zeros(size(f));

    % the top boundary 
    dFdTheta(1,:) = ((-3/2)*f(1,:) + 2*f(2,:) - (1/2)*f(3,:))./(dTheta);
    % the middle field
    dFdTheta(2:end-1,:) = ( (1/2)*f(3:end,:) - (1/2)*f(1:end-2,:) )./(dTheta);
    % the bottom boundary
    dFdTheta(end,:) = ((3/2)*f(end,:) - 2*f(end-1,:) + (1/2)*f(end-2,:))./(dTheta);

end

