% **************************************************************************************************
% Aurthor: Xiaoqiu HE
% Date: 2019/12/23
% **************************************************************************************************
% Purpose : 
%   This function reads one case which is stored in the <caseRawDir> and store it to the <storeDir>
%   the <storeDir> is a subdir of <rootDir>. The appearance of <storeDir> is just like:
%       <storeDir> = <rootDir>\DeltaXX\RaXXRoXX -> XX indicates the value of Ra, Ro and Delta
% **************************************************************************************************
% Attention :
%   2023/08/01 : This version is used specially for the vibration bubble cases
% **************************************************************************************************
% Updates :
%    
%   
%   

function [storeDir] = transOneCase(caseRawDir, rootDir)
    
    % do not modify the existed function for the maintainablity
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(caseRawDir);
    disp('The case specification:')
    disp(['Ra = ',num2str(Ra,'%2.1e')])
    disp(['Pr = ',num2str(Pr,'%2.1f')])
    disp(['R0 = ',num2str(R0,'%3.2f')])
    disp(['Delat = ',num2str(Delta,'%d')])
    disp(['x2dGauche = ',num2str(x2dGauche,'%3.2f')])
    disp(['x2dDroit = ',num2str(x2dDroit,'%3.2f')])
    disp(['y2dHaut = ',num2str(y2dHaut,'%3.2f')])
    disp(['y2dBas = ',num2str(y2dBas,'%3.2f')])
    disp(['n1 = ',num2str(n1,'%d')])
    disp(['n2 = ',num2str(n2,'%d')])
    disp(['Ff = ',num2str(Ff,'%3.2f')])
    disp(['St = ',num2str(St,'%3.2f')])
    disp(['maxN = ',num2str(maxN,'%d')])
    disp(['dt = ',num2str(dt,'%1.1e')])
    disp(['dtSave = ',num2str(dtSave,'%1.1e')])
    
    % use a new function seperately to read vibration coefficients
    [r_c, dissipType,delta_r] = getDissip(caseRawDir);

    % determine the store path
    [storeDir] = makeDir4BubblePlus(rootDir, r_c, Ra);
    storeOrgDir = fullfile(storeDir, 'org');
    if exist(storeOrgDir, 'dir') == 7
        disp(['The aime Directory ', storeOrgDir, ' exist!'])
%         return;
    else
        mkdir(storeOrgDir);
    end

    % save and read the raw data
    transData( caseRawDir, storeDir);

end
