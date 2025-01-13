function transData( caseRawDir, storeDir)

    % read the coefficients
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(caseRawDir);

    % save the coefficients
    basicInforDir = fullfile(storeDir,'basicInformation.bin');
    fileID = fopen(basicInforDir,'w');
    fwrite(fileID, x2dGauche, 'double');
    fwrite(fileID, x2dDroit, 'double');
    fwrite(fileID, y2dHaut, 'double');
    fwrite(fileID, y2dBas, 'double');
    fwrite(fileID, n1, 'double');
    fwrite(fileID, n2, 'double');
    fwrite(fileID, Ra, 'double');
    fwrite(fileID, R0, 'double');
    fwrite(fileID, Pr, 'double');
    fwrite(fileID, St, 'double');
    fwrite(fileID, Ff, 'double');
    fwrite(fileID, Delta, 'double');
    fclose(fileID);
    disp('Basic Infor Finish')

    % read strings
    transString(caseRawDir, storeDir);

    % read r_c
    transDissip(caseRawDir, storeDir);
    

    % get the store path for fields data
    storeOrgDir = fullfile(storeDir, 'org');
    if exist(storeOrgDir, 'dir') ~= 7
        mkdir(storeOrgDir);
    end
    
    % transform fields
    shiftTimeStep = 0;
    [time, maxN] = ...,
    transFields(caseRawDir, storeOrgDir, n1, n2, maxN, x2dGauche, x2dDroit, y2dBas, y2dHaut,shiftTimeStep);
    fileID = fopen(basicInforDir,'a');
    fwrite(fileID, maxN, 'int');
    fwrite(fileID, time, 'double');
    fwrite(fileID, dt, 'double');
    fwrite(fileID, dtSave, 'double');
    fclose(fileID);
    disp('u v tmp prs Finish')

    % compute and store vorticity
    computeVorOrg(storeOrgDir, x2dGauche, x2dDroit, y2dBas, n1, n2, maxN);
    disp('vor Finish')
    
    % build and store mesh
    [x2dS, y2dS, x2dU, y2dU, x2dV, y2dV] ...,
    = buildMeshOrg(x2dGauche, x2dDroit, y2dHaut, y2dBas, n1, n2);

    x2dSDir = fullfile(storeOrgDir,'x2dS.bin');
    fileID = fopen(x2dSDir,'w');
    fwrite(fileID,x2dS,'double');
    fclose(fileID);

    y2dSDir = fullfile(storeOrgDir,'y2dS.bin');
    fileID = fopen(y2dSDir,'w');
    fwrite(fileID,y2dS,'double');
    fclose(fileID);
    
    x2dUDir = fullfile(storeOrgDir,'x2dU.bin');
    fileID = fopen(x2dUDir,'w');
    fwrite(fileID,x2dU,'double');
    fclose(fileID);

    y2dUDir = fullfile(storeOrgDir,'y2dU.bin');
    fileID = fopen(y2dUDir,'w');
    fwrite(fileID,y2dU,'double');
    fclose(fileID);

    x2dVDir = fullfile(storeOrgDir,'x2dV.bin');
    fileID = fopen(x2dVDir,'w');
    fwrite(fileID,x2dV,'double');
    fclose(fileID);

    y2dVDir = fullfile(storeOrgDir,'y2dV.bin');
    fileID = fopen(y2dVDir,'w');
    fwrite(fileID,y2dV,'double');
    fclose(fileID);

    % read and store the test infor
    [timeTest, NRJ, ENS, TEN, ANGM] = getNsTest(caseRawDir);
    nTest = numel(timeTest);
    nsTestBinDir = fullfile(storeOrgDir,'nsTest.bin');
    fileID = fopen(nsTestBinDir,'w');
    fwrite(fileID,nTest,'double');
    fwrite(fileID,timeTest,'double');
    fwrite(fileID,NRJ,'double');
    fwrite(fileID,ENS,'double');
    fwrite(fileID,TEN,'double');
    fwrite(fileID,ANGM,'double');
    fclose(fileID);
    disp('nsTest Finished')

    % read and store the signal infor
    [signal] = getNsSignal(caseRawDir);
    nSignal = numel(signal.time);
    nsSignalBinDir = fullfile(storeOrgDir,'nsSignal.bin');
    fileID = fopen(nsSignalBinDir,'w');
    fwrite(fileID,nSignal,'double');
    fwrite(fileID,signal.time,'double');
    fwrite(fileID,signal.P1,'double');
    fwrite(fileID,signal.P2,'double');
    fwrite(fileID,signal.P3,'double');
    fwrite(fileID,signal.P4,'double');
    fwrite(fileID,signal.P5,'double');
    fwrite(fileID,signal.P6,'double');
    fwrite(fileID,signal.T1,'double');
    fwrite(fileID,signal.T2,'double');
    fwrite(fileID,signal.T3,'double');
    fwrite(fileID,signal.T4,'double');
    fwrite(fileID,signal.T5,'double');
    fwrite(fileID,signal.T6,'double');
    fwrite(fileID,signal.U1,'double');
    fwrite(fileID,signal.U2,'double');
    fwrite(fileID,signal.U3,'double');
    fwrite(fileID,signal.U4,'double');
    fwrite(fileID,signal.U5,'double');
    fwrite(fileID,signal.U6,'double');
    fwrite(fileID,signal.V1,'double');
    fwrite(fileID,signal.V2,'double');
    fwrite(fileID,signal.V3,'double');
    fwrite(fileID,signal.V4,'double');
    fwrite(fileID,signal.V5,'double');
    fwrite(fileID,signal.V6,'double');
    fwrite(fileID,signal.W1,'double');
    fwrite(fileID,signal.W2,'double');
    fwrite(fileID,signal.W3,'double');
    fwrite(fileID,signal.W4,'double');
    fwrite(fileID,signal.W5,'double');
    fwrite(fileID,signal.W6,'double');
    fclose(fileID);
    disp('Signal Finished')

end