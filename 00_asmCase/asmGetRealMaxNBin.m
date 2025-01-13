function [realMaxN] = asmGetRealMaxNBin(rawCaseDir)

    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(rawCaseDir);


    % locate original data file
    nssaveDir = fullfile(rawCaseDir,'nssave.bin');
    % open file
    fid = fopen(nssaveDir, 'r','n');
    
    for timeStep = 1:1:maxN

        % indicate the index to operate
%         disp(['Go through time step = ',num2str(timeStep,'%d')])
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
            disp('The left fields (tmp u2d, v2d, prs) are lost for sure!')
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
                disp('The left fields (tmp u2d, v2d, prs) are lost for sure!')
            else
                headIntegrity = true;
            end
        end

        
        if headIntegrity == true
            % read tmpOrg Temperature Field
            tmpOrgFortran = fread(fid,[n1,n2],"double");
            if numel(tmpOrgFortran)~=(n1*n2)
                disp(['Time step ',num2str(timeStep,'%d'),': temperature field broken!'])
                disp('The left fields (u2d, v2d, prs) are lost for sure!')
            else
                tmpIntegrity = true;
            end
        end
        
        % read the Velocity Field in x direction of the Computing 
        % Coordinate system
        if tmpIntegrity == true
            u2dOrgFortran = fread(fid,[n1+1,n2],"double");
            if numel(u2dOrgFortran)~=((n1+1)*n2)
                disp(['Time step ',num2str(timeStep,'%d'),': u2d field broken!'])
                disp('The left fields (v2d, prs) are lost for sure!')
            else
                u2dIntegrity = true;
            end
        end

        % read the Velocity Field in y direction of the Computing 
        % Coordinate system
        if u2dIntegrity == true
            v2dOrgFortran = fread(fid,[n1,n2+1],"double");
            if numel(v2dOrgFortran)~=(n1*(n2+1))
                disp(['Time step ',num2str(timeStep,'%d'),': v2d field broken!'])
                disp('The left fields (prs) are lost for sure!')
            else
                v2dIntegrity = true;
            end
        end

        % read Pressure field
        if v2dIntegrity == true
            prsOrgFortran = fread(fid,[n1,n2],"double");
            if numel(prsOrgFortran)~=(n1*n2)
                disp(['Time step ',num2str(timeStep,'%d'),': prs field broken!'])
            else
                prsIntegrity = true;
            end
        end

        if (headIntegrity == true)&&(tmpIntegrity == true)&&(u2dIntegrity == true) ...
           &&(v2dIntegrity == true)&&(prsIntegrity == true)
            if timeStep < maxN
                disp(['Time step ',num2str(timeStep,'%d'),': data is integral!'])
                continue
            else
                disp('Reach the last time step data!')
                realMaxN = maxN;
            end
        else
            disp(['Time step ',num2str(timeStep,'%d'),': data is not integrate!'])
            realMaxN = timeStep-1;
            disp(['Read Max Time step is ',num2str(realMaxN,'%d')])
            break
        end
    end
    fclose(fid);
end

