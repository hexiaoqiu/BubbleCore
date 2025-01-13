% **************************************************************************************************
% Aurthor: Xiaoqiu HE
% Date: 2020/08/19
% **************************************************************************************************
% Purpose : 
%   This function reads 2 or more cases which is stored in the <caseRawDirList> and store it to the 
%   <storeDir>. The <storeDir> is a subdir of <rootDir>. The appearance of <storeDir> is just like:
%       <storeDir> = <rootDir>\DeltaXX\RaXXRoXX -> XX indicates the value of Ra, Ro and Delta
% **************************************************************************************************
% Attention :
%   the cases in <caseRawDirList> should be sequenced 
% **************************************************************************************************
% Updates :
%    
%   
%   

function [storeDir] = transAndMergeCasesFromBin(caseRawDirList, rootDir)
    

    % obtain the raw cases' coefficients and numbers
    disp('Obtaining the infor of the raw case list')
    numCase = numel(caseRawDirList);
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(caseRawDirList{1});
    [r_c, dissipType,delta_r] = getDissip(caseRawDirList{1});

    numTimeStepList = zeros(numCase,1);
    numTimeStepList(1) = maxN;
    timeList = zeros(numCase,1);

    for idxCase = 2:numCase
        [Ra_2, Pr_2, St_2, R0_2, Ff_2, Delta_2, x2dGauche_2, x2dDroit_2, y2dBas_2, y2dHaut_2, n1_2, n2_2, maxN_2,dt_2,dtSave_2] ...,
        = getCoefs(caseRawDirList{idxCase});
        [r_c_2, dissipType_2,delta_r_2] = getDissip(caseRawDirList{idxCase});

        consistency = (Ra == Ra_2)&&(R0 == R0_2)&&(Pr == Pr_2)&&(Delta == Delta_2)&&(x2dGauche == x2dGauche_2) ...,
                    &&(x2dDroit == x2dDroit_2)&&(y2dBas == y2dBas_2)&&(y2dHaut == y2dHaut_2)&&(n1 == n1_2)&&(n2 == n2_2) ...,
                    &&(dt == dt_2)&&(dtSave == dtSave_2)&& ...,
                    (r_c == r_c_2)&&(dissipType == dissipType_2)&&(delta_r == delta_r_2)...
                    ... %&&(Ff == Ff_2)&&(St == St_2)...
                    ;
        if consistency == false
            disp('The cases are not consistent in the coefficients!')
            disp(['The inconsistent case is in the ',num2str(idxCase,'%d'),'th place'])
            storeDir = [];
            return
        else
            numTimeStepList(idxCase) = maxN_2;
        end
    end
    disp(['There are ',num2str(numCase,'%d'),' to merge']);

    % read and store the coeffcients
    totalN = sum(numTimeStepList);
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
    disp(['maxN = ',num2str(totalN,'%d')])
    

    % determine the store path
    disp('Determining the store path')
    [storeDir] = makeDir4BubblePlus(rootDir, r_c, Ra);
    storeOrgDir = fullfile(storeDir, 'org');
    if exist(storeOrgDir, 'dir') == 7
        disp(['The aime Directory ', storeOrgDir, ' exist!'])
        % return;
    else
        mkdir(storeOrgDir);
    end
    disp(['The store path is : ', storeDir])

    % save the coefficients
    disp('Saving the basic informations')
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
    disp('Reading the string')
    transString(caseRawDirList{1}, storeDir);

    % read r_c
    disp('Reading r_c')
    transDissip(caseRawDirList{1}, storeDir);

    % read fields
    disp('Start Reading the fields')
    for idxCase = 1:numCase
        if idxCase == 1
            shiftTimeStep = 0;
        else
            shiftTimeStep = shiftTimeStep + numTimeStepList(idxCase-1);
        end
        [time, realMaxN] = ...,
        transFieldsFromBin(caseRawDirList{idxCase}, storeOrgDir, n1, n2, numTimeStepList(idxCase), x2dGauche, x2dDroit, y2dBas, y2dHaut,shiftTimeStep,dtSave);
        numTimeStepList(idxCase) = realMaxN;
        timeList(idxCase) = time;
    end
    realTotalmaxN = sum(numTimeStepList);
    fileID = fopen(basicInforDir,'a');
    fwrite(fileID, realTotalmaxN, 'int');
    timeAllCase = sum(timeList,'all');
    fwrite(fileID, timeAllCase, 'double');
    fwrite(fileID, dt, 'double');
    fwrite(fileID, dtSave, 'double');

    % time = 1:1:realTotalmaxN;
    % fwrite(fileID, time, 'double');
    fclose(fileID);
    disp('field u v tmp prs -> Finished')

    % compute and store vorticity
    computeVorOrg(storeOrgDir, x2dGauche, x2dDroit, y2dBas, n1, n2, realTotalmaxN);
    disp('field vor -> Finish')

    % build and store mesh
    disp('Building mesh')
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
    disp('Reading the test information')
    timeTestList = cell(numCase,1);
    NRJList = cell(numCase,1);
    ENSList = cell(numCase,1);
    TENList = cell(numCase,1);
    ANGMList = cell(numCase,1);
    for idxCase = 1:numCase
        [timeTestList{idxCase}, NRJList{idxCase}, ENSList{idxCase}, TENList{idxCase}, ANGMList{idxCase}] ...,
        = getNsTest(caseRawDirList{idxCase});
    end
    nTest = 0;
    for idxCase = 1:numCase
        nTest = nTest + numel(timeTestList{idxCase});
    end
    nsTestBinDir = fullfile(storeOrgDir,'nsTest.bin');
    fileID = fopen(nsTestBinDir,'w');
    fwrite(fileID,nTest,'double');
    timeTestTotal = timeTestList{1}(1):timeTestList{1}(1):(nTest*timeTestList{1}(1));
    fwrite(fileID,timeTestTotal,'double');

    for idxCase = 1:numCase
        fwrite(fileID,NRJList{idxCase},'double');
    end
    for idxCase = 1:numCase
        fwrite(fileID,ENSList{idxCase},'double');
    end
    for idxCase = 1:numCase
        fwrite(fileID,TENList{idxCase},'double');
    end
    for idxCase = 1:numCase
        fwrite(fileID,ANGMList{idxCase},'double');
    end
    fclose(fileID);
    disp('nsTest Finished')

    % read and store the signal infor
    signal = cell(numCase,1);
    for idxCase = 1:numCase
        [signal{idxCase}] = getNsSignal(caseRawDirList{idxCase});
    end
    nSignal = 0;
    for idxCase = 1:numCase
        nSignal = nSignal + numel(signal{idxCase}.time);
    end
    nsSignalBinDir = fullfile(storeOrgDir,'nsSignal.bin');
    timeSignal = signal{1}.time(1):signal{1}.time(1):(signal{1}.time(1)*nSignal);

    fileID = fopen(nsSignalBinDir,'w');
    fwrite(fileID,nSignal,'double');
    fwrite(fileID,timeSignal,'double');

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P1,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P2,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P3,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P4,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P5,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.P6,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T1,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T2,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T3,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T4,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T5,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.T6,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U1,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U2,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U3,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U4,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U5,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.U6,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V1,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V2,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V3,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V4,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V5,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.V6,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W1,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W2,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W3,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W4,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W5,'double');
    end

    for idxCase = 1:numCase
        fwrite(fileID,signal{idxCase}.W6,'double');
    end

    fclose(fileID);
    disp('Signal Finished')

end