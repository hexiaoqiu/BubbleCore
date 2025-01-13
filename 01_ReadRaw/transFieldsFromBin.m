% **************************************************************************************************
% Aurthor: Xiaoqiu HE
% Date: 2019/12/23
% **************************************************************************************************
% Purpose : 
%   This function reads the field of velocity, pressure and temperature stored in the form of strings
%   and in a integral file. Then to store them in the form of binary and in the separate files.
% **************************************************************************************************
% Attention :
%   the field is written in the sequency of lines, so the fileds is read by lines too.
% **************************************************************************************************
% Updates :
%   2020/08/19 : the function is modified in order to merge the multiple original string cases into 
%   one binary case. The variable <shiftTimeStep> is added in order to yield a correct time step index
%   in the merged binary case

function [time, realMaxN] = transFieldsFromBin(caseRawDir,caseOrgDir, n1, n2, maxN, x2dGauche, x2dDroit, y2dBas, y2dHaut, shiftTimeStep,dtSave)
    
    % build the coordinate vector
    h1 = (x2dDroit - x2dGauche) / n1;
    h2 = (y2dHaut - y2dBas) / n2;
    x2dS = x2dGauche+h1/2:h1:x2dDroit-h1/2;
    y2dS = y2dBas+h2/2:h2:y2dHaut-h2/2;
    x2dU = x2dGauche:h1:x2dDroit;
    y2dU = y2dS;
    x2dV = x2dS;
    y2dV = y2dBas:h2:y2dHaut;

    % locate original data file
    nssaveDir = fullfile(caseRawDir,'nssave.bin');

    % locate binary file to store data
    rootFileNameU = 'u_';
    rootFileNameV = 'v_';
    rootFileNameTmp = 'tmp_';
    rootFileNamePrs = 'prs_';

    % start the read loop
%     LastStepDataIntegrity = true; 
    timeStep = 0; % time step indicator
    % open file
    fid = fopen(nssaveDir, 'r','n');
    % startReading = false;

    for stepIdx = 1:maxN+1
        
        % indicate the index to operate
        timeStep = timeStep + 1;
        disp(['Time step = ',num2str(timeStep,'%d')])

        % detect the start of the flow field data for one time step
        FirstDouble = fread(fid,1,"double",'n');
        SecondDouble = fread(fid,1,"double",'n');
        ThirdDouble = fread(fid,1,"double",'n');
        FourthDouble = fread(fid,1,"double",'n');
        FirstInt = fread(fid,1,"int",'n');
        SecondInt = fread(fid,1,"int",'n');
        headExist = (~isempty(FirstDouble))&&(~isempty(SecondDouble))&&(~isempty(ThirdDouble))&&(~isempty(FourthDouble)) ...
            &&(~isempty(FirstInt))&&(~isempty(SecondInt));

        if headExist == false
            disp(['Time step ',num2str(timeStep,'%d'),': header broken'])
            timeStep = timeStep - 1;
            break;
        end

        headCorrect = ...,
            (FirstDouble == x2dGauche) && ...,
            (SecondDouble == x2dDroit) && ...,
            (ThirdDouble == y2dBas) && ...,
            (FourthDouble == y2dHaut) && ...,
            (FirstInt == n1) && ...,
            (SecondInt == n2);
        if headCorrect == false
            disp(['Time step ',num2str(timeStep,'%d'),': header is not correct!'])
            timeStep = timeStep - 1;
            break
        end

        
% Begin to read the flow field for one time step
% attention:
% in the Fortran code(SPHCG), the convention of the data arrangement in the
% matrix is:
%       1) the line direction(first index) corresponds to x direction
%       2) the row direction(second index) correspond to y direction, 
% so the matrix size of the flow field are as following:
% tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
% line*row      line*row                line*row                line*row
% n1*n2         (n1+1)*n2               n1*(n2+1)               n1*n2;
% It is not intuitive for the interpretation.
% In addition, the matrix are written into the binary field in the sequence
% of line which is the first index.
% In contrast,
% for the post-process system, we adopt the convention of the 
% correspondence between spatial direction and data arrangement as:
%       1) the line direction corresponds to y direction
%       2) the row direction correspond to x direction, 
% so the matrix size of the flow field are as following:
% tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
% line*row      line*row                line*row                line*row
% n2*n1         n2*(n1+1)               (n2+1)*n1               n2*n1;
% which is more intuitive when drawing the cloud pictures for the flow 
% fields 

        % read tmpOrg Temperature Field
        tmpOrgFortran = fread(fid,[n1,n2],"double");
        if numel(tmpOrgFortran)~=(n1*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': temperature field broken!'])
            disp('The left fields (u2d, v2d, prs) are lost for sure!')
            timeStep = timeStep - 1;
            break
        end
        % raw processing Temperature Field
        tmpOrg = tmpOrgFortran';
        for j = 1:n2
            y = y2dS(j);
            for i = 1:n1
                x = x2dS(i);
                r = sqrt(x^2+y^2);
                if r >= 1
                    tmpOrg(j, i) = 1;
                end
            end
        end
        
        
        % read the Velocity Field in x direction of the Computing 
        % Coordinate system
        u2dOrgFortran = fread(fid,[n1+1,n2],"double");
        if numel(u2dOrgFortran)~=((n1+1)*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': u2d field broken!'])
            disp('The left fields (v2d, prs) are lost for sure!')
            timeStep = timeStep - 1;
            break
        end
        % raw processing
        u2dOrg = u2dOrgFortran';
        for j = 1:n2
            y = y2dU(j);
            for i = 1:(n1 + 1)
                x = x2dU(i);
                r = sqrt(x^2+y^2);
                if r >= 1
                    u2dOrg(j, i) = 0;
                end
            end
        end
        

        % read the Velocity Field in y direction of the Computing 
        % Coordinate system
        v2dOrgFortran = fread(fid,[n1,n2+1],"double");
        if numel(v2dOrgFortran)~=(n1*(n2+1))
            disp(['Time step ',num2str(timeStep,'%d'),': v2d field broken!'])
            disp('The left fields (prs) are lost for sure!')
            timeStep = timeStep - 1;
            break
        end
        %raw processing
        v2dOrg = v2dOrgFortran';
        for j = 1:(n2 + 1)
            y = y2dV(j);
            for i = 1:n1
                x = x2dV(i);
                r = sqrt(x^2+y^2);
                if r >= 1
                    v2dOrg(j,i) = 0;
                end
            end
        end

        % read Pressure field
        prsOrgFortran = fread(fid,[n1,n2],"double");
        if numel(prsOrgFortran)~=(n1*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': prs field broken!'])
            timeStep = timeStep - 1;
            break
        end
        prsOrg = prsOrgFortran';
        
        
        % check if it is the last time step
        if (timeStep==maxN+1)
            disp(['Time step = ',num2str(timeStep,'%d'),' is the last data slice!'])
            disp('The flow data of this step is the over all time average!')
            tmpFileName = [rootFileNameTmp,'_Mean_.bin'];
            uFileName = [rootFileNameU,'_Mean_.bin'];
            vFileName = [rootFileNameV,'_Mean_.bin'];
            prsFileName = [rootFileNamePrs,'_Mean_.bin'];
            timeStep = timeStep - 1;
        else
            tmpFileName = [rootFileNameTmp,num2str(shiftTimeStep+timeStep,'%d'),'.bin'];
            uFileName = [rootFileNameU,num2str(shiftTimeStep+timeStep,'%d'),'.bin'];
            vFileName = [rootFileNameV,num2str(shiftTimeStep+timeStep,'%d'),'.bin'];
            prsFileName = [rootFileNamePrs,num2str(shiftTimeStep+timeStep,'%d'),'.bin'];
        end
        % writes Temperature Field
        tmpOrgDir = fullfile(caseOrgDir,tmpFileName);
        tmpOrgFile = fopen(tmpOrgDir, 'w');
        fwrite(tmpOrgFile, tmpOrg, 'double');
        fclose(tmpOrgFile);
        % writes U2d Field
        u2dOrgDir = fullfile(caseOrgDir,uFileName);
        u2dOrgFile = fopen(u2dOrgDir,'w');
        fwrite(u2dOrgFile,u2dOrg,'double');
        fclose(u2dOrgFile);
        % writes V2d Field
        v2dOrgDir = fullfile(caseOrgDir,vFileName);
        v2dOrgFile = fopen(v2dOrgDir,'w');
        fwrite(v2dOrgFile, v2dOrg, 'double');
        fclose(v2dOrgFile);
        % writes Pressure Field
        prsOrgDir = fullfile(caseOrgDir,prsFileName);
        prsOrgFile = fopen(prsOrgDir,'w');
        fwrite(prsOrgFile, prsOrg, 'double');
        fclose(prsOrgFile);
    end

    fclose(fid);

    realMaxN = timeStep;
    time = realMaxN*dtSave;
    
end