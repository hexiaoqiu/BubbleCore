function [gradT,T,theta] = pureHeatCondt_0(Ra,Pr,St,N)
    
    theta = linspace(0,pi/2,N)';
    dTheta = theta(2) - theta(1);
    A = zeros(N,N);
    % A(1,1) = 1;
    A(1,1) = -1/dTheta;
    A(1,2) = 1/dTheta;
    for j = 2:N-1
        A(j,j-1) = 1/(dTheta^2);
        A(j,j) = -1*(cot(theta(j))/dTheta + 2/dTheta^2 + sqrt(Ra*Pr)*abs(St));
        A(j,j+1) = 1/dTheta^2 + cot(theta(j))/dTheta;
    end
    A(N,N) = 1;
    B = zeros(size(theta));
    B(1) = 0;
    B(N) = 1;

    T = A\B;
    gradT = gradient(T,dTheta);
%     gradT(1) = 0;

end
