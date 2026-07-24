% 读取latestSolution中的流场数据
% destFolder：latestSolution所在文件夹路径
function [coef, flowSnapshot] = dnsReadLatestSoluBin(destFolder)

    % get the fid
    fid = fopen(fullfile(destFolder,'latestSolution.bin'));
    
    % detect the start of the flow field data for one time step
    coef.x2dGauche = fread(fid,1,"double","n");
    coef.x2dDroit = fread(fid,1,"double",'n');
    coef.y2dBas = fread(fid,1,"double",'n');
    coef.y2dHaut = fread(fid,1,"double",'n');
    coef.n1 = fread(fid,1,"int",'n');
    coef.n2 = fread(fid,1,"int",'n');
    
    % read tmpOrg Temperature Field
    flowSnapshot.tmpOrg = fread(fid,[coef.n1,coef.n2],"double")';

    % read the Velocity Field in x direction of the Computing 
    % Coordinate system
    flowSnapshot.u2dOrg = fread(fid,[coef.n1+1,coef.n2],"double")';

    % read the Velocity Field in y direction of the Computing 
    % Coordinate system
    flowSnapshot.v2dOrg = fread(fid,[coef.n1,coef.n2+1],"double")';

    % read Pressure field
    flowSnapshot.prsOrg = fread(fid,[coef.n1,coef.n2],"double")';
    
end

