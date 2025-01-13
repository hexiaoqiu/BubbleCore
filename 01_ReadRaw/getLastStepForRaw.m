function [tmpOrgLast, u2dOrgLast, v2dOrgLast, prsOrgLast] = getLastStepForRaw(rawCaseDir)
%GETLASTSTEPFORRESTARTRAW Summary of this function goes here
%   Detailed explanation goes here
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(rawCaseDir);
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

    % locate original data file
    nssaveDir = fullfile(rawCaseDir,'nssave.bin');
    % open file
    fid = fopen(nssaveDir, 'r','n');
    
    for timeStep = 1:1:maxN

        % indicate the index to operate
        disp(['Go through time step = ',num2str(timeStep,'%d')])
        headIntegrity = false;
        tmpIntegrity = false;
        u2dIntegrity = false;
        v2dIntegrity = false;
        prsIntegrity = false;

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
            disp(['Time step ',num2str(timeStep,'%d'),': header is empty!'])
        else
            headCorrect = ...,
            (FirstDouble == x2dGauche) && ...,
            (SecondDouble == x2dDroit) && ...,
            (ThirdDouble == y2dBas) && ...,
            (FourthDouble == y2dHaut) && ...,
            (FirstInt == n1) && ...,
            (SecondInt == n2);
            if headCorrect == false
                disp(['Time step ',num2str(timeStep,'%d'),': header is not correct!'])
            else
                headIntegrity = true;
            end
        end

        

        % read tmpOrg Temperature Field
        tmpOrgFortran = fread(fid,[n1,n2],"double");
        if numel(tmpOrgFortran)~=(n1*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': temperature field broken!'])
            disp('The left fields (u2d, v2d, prs) are lost for sure!')
        else
            tmpIntegrity = true;
        end

        % read the Velocity Field in x direction of the Computing 
        % Coordinate system
        u2dOrgFortran = fread(fid,[n1+1,n2],"double");
        if numel(u2dOrgFortran)~=((n1+1)*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': u2d field broken!'])
            disp('The left fields (v2d, prs) are lost for sure!')
        else
            u2dIntegrity = true;
        end

        % read the Velocity Field in y direction of the Computing 
        % Coordinate system
        v2dOrgFortran = fread(fid,[n1,n2+1],"double");
        if numel(v2dOrgFortran)~=(n1*(n2+1))
            disp(['Time step ',num2str(timeStep,'%d'),': v2d field broken!'])
            disp('The left fields (prs) are lost for sure!')
        else
            v2dIntegrity = true;
        end

        % read Pressure field
        prsOrgFortran = fread(fid,[n1,n2],"double");
        if numel(prsOrgFortran)~=(n1*n2)
            disp(['Time step ',num2str(timeStep,'%d'),': prs field broken!'])
        else
            prsIntegrity = true;
        end

        if (headIntegrity == true)&&(tmpIntegrity == true)&&(u2dIntegrity == true) ...
           &&(v2dIntegrity == true)&&(prsIntegrity == true)
%             disp(['Time step ',num2str(timeStep,'%d'),': data is integrate!'])
            tmpOrgLast = tmpOrgFortran';
            u2dOrgLast = u2dOrgFortran';
            v2dOrgLast = v2dOrgFortran';
            prsOrgLast = prsOrgFortran';
            if timeStep < maxN
%                 disp('Maybe there is next step data!')
                  continue
            else
                disp('Reach the last time step data!')
                successfulReachLastStep = true;
            end
        else
            disp(['Time step ',num2str(timeStep,'%d'),': data is not integrate!'])
            if timeStep-1 > 0
                disp(['Time step ',num2str(timeStep-1,'%d'),': data is the last integrate!'])
                successfulReachLastStep = true;
                break
            else
                disp('No time step data is integrate!')
                successfulReachLastStep = false;
                break
            end
        end
    end

    if successfulReachLastStep == false
        tmpOrgLast = NaN;
        u2dOrgLast = NaN;
        v2dOrgLast = NaN;
        prsOrgLast = NaN;
    end
    fclose(fid);
end

