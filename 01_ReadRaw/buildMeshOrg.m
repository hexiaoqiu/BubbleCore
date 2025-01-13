% Aurthor: Xiaoqiu HE
% Date: 2019/12/23
% The purpose of the function: 
% This function is aimed at generating the coordinate mesh grid for the original discrete points
% in the 2D projection system
function [x2dS, y2dS, x2dU, y2dU, x2dV, y2dV] = buildMeshOrg(x2dGauche, x2dDroit, y2dHaut, y2dBas, n1, n2)

    h1 = (x2dDroit - x2dGauche) / n1;
    h2 = (y2dHaut - y2dBas) / n2;

    % mesh vector orthgonal in 2D system
    x2dS = x2dGauche+h1/2:h1:x2dDroit-h1/2;
    y2dS = (y2dBas+h2/2:h2:y2dHaut-h2/2)';
    x2dU = x2dGauche:h1:x2dDroit;
    y2dU = y2dS;
    x2dV = x2dS;
    y2dV = (y2dBas:h2:y2dHaut)';

end