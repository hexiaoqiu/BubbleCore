function [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepBin(asmCase,numSkipByte)

    % get the fid
    fid = asmCase.readNowFileID;
    n1 = asmCase.n1(asmCase.readNowSubCaseIdx);
    n2 = asmCase.n2(asmCase.readNowSubCaseIdx);

    % detect the start of the flow field data for one time step
    FirstDouble = fread(fid,1,"double",numSkipByte,"n");
    SecondDouble = fread(fid,1,"double",'n');
    ThirdDouble = fread(fid,1,"double",'n');
    FourthDouble = fread(fid,1,"double",'n');
    FirstInt = fread(fid,1,"int",'n');
    SecondInt = fread(fid,1,"int",'n');
    
    headCorrect = ...,
    (FirstDouble == asmCase.x2dGauche) && ...,
    (SecondDouble == asmCase.x2dDroit) && ...,
    (ThirdDouble == asmCase.y2dBas) && ...,
    (FourthDouble == asmCase.y2dHaut) && ...,
    (FirstInt == asmCase.n1(asmCase.readNowSubCaseIdx)) && ...,
    (SecondInt == asmCase.n2(asmCase.readNowSubCaseIdx));
    if headCorrect == true
        % read tmpOrg Temperature Field
        tmpOrg = fread(fid,[n1,n2],"double");
        tmpOrg = tmpOrg';

        % read the Velocity Field in x direction of the Computing 
        % Coordinate system
        u2dOrg = fread(fid,[n1+1,n2],"double");
        u2dOrg = u2dOrg';

        % read the Velocity Field in y direction of the Computing 
        % Coordinate system
        v2dOrg = fread(fid,[n1,n2+1],"double");
        v2dOrg = v2dOrg';

        % read Pressure field
        prsOrg = fread(fid,[n1,n2],"double");
        prsOrg = prsOrg';
        
    else
        disp(['Time step ',num2str(asmCase.lastReadTime,'%d'),': header is not correct! The data position is bad']);
        tmpOrg = [];
        u2dOrg = [];
        v2dOrg = [];
        prsOrg = [];
    end
end

