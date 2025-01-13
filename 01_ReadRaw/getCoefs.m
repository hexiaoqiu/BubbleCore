% Aurthor: Xiaoqiu HE
% Date: 2019/12/23
% The purpose of the function: 
% "readCeofsMakeDir" means " read the coefficients and make the directory  "
% The function is to read the case's coefs and then making the directory name and path name basing on the coefs
% The data is stored in two levels directories:
%       \DeltaXX\RaXXRoXX -> XX indicates the coefs.

function [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] = getCoefs(caseRawDir)
    % locate the raw data file
    nsreadDir = fullfile(caseRawDir, 'nsread.dat');
    id = fopen(nsreadDir);

    % read the dtNumBetSave
    cache = textscan(id, '%f', 'HeaderLines', 8);
    coefs = cell2mat(cache);
    numDtBetSave = coefs(5);
   

    % read computational domain limits
    cache = textscan(id, '%f', 'HeaderLines', 2);
    coefs = cell2mat(cache);
    x2dGauche = coefs(1); % x1 gauche
    x2dDroit = coefs(2); % x1 droite
    y2dBas = coefs(3); % x2 bas
    y2dHaut = coefs(4); % x2 haut

    % read resolutions
    cache = textscan(id, '%f', 'HeaderLines', 6);
    coefs = cell2mat(cache);
    n1 = coefs(1);
    n2 = coefs(2);

    % read coefficients
    cache = textscan(id, '%f', 'HeaderLines', 5);
    coefs = cell2mat( cache );
    if numel(coefs) == 5
        Ra = coefs(1);
        Pr = coefs(2);
        St = coefs(3);
        R0 = coefs(4);
        Ff = coefs(5);
        Delta = 0;
    elseif numel(coefs) == 6
        Ra = coefs(1);
        Pr = coefs(2);
        St = coefs(3);
        R0 = coefs(4);
        Ff = coefs(5);
        Delta = round( rad2deg(coefs(6)) );
    else
        disp('Coefficients are wrongly set!')
    end

    % read the expected simulated time 
    cache = textscan(id, '%f', 'HeaderLines', 1);
    coefs = cell2mat( cache );
    dt = coefs(1);
    dtSave = numDtBetSave*dt;
    maxN = coefs(2);
    maxN = maxN/dtSave;

    % close the file
    fclose(id);

end