function [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadToSpecifiedStepTxt(asmCase,localTimeStepIdx)
    
    numTimeStepToSkip = localTimeStepIdx - 1;
    
    % get the fid
    fid = asmCase.readNowFileID;
    n1 = asmCase.n1(asmCase.readNowSubCaseIdx);
    n2 = asmCase.n2(asmCase.readNowSubCaseIdx);
    
    % original mesh
    x2dS = asmCase.x2dS{asmCase.readNowSubCaseIdx};
    y2dS = asmCase.y2dS{asmCase.readNowSubCaseIdx};
    x2dU = asmCase.x2dU{asmCase.readNowSubCaseIdx};
    y2dU = asmCase.y2dU{asmCase.readNowSubCaseIdx};
    x2dV = asmCase.x2dV{asmCase.readNowSubCaseIdx};
    y2dV = asmCase.y2dV{asmCase.readNowSubCaseIdx};


    % allocate field of one time step  
    tmpOrg = zeros(n2, n1);
    u2dOrg = zeros(n2, n1 + 1);
    v2dOrg = zeros(n2 + 1, n1);
    prsOrg = zeros(n2, n1);
    % calculate the quntity of numbers in one timeStep
    % tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
    % n1*n2         n2*(n1+1)               (n2+1)*n1               n1*n2;
    numFloatInOneTimeStep = n1 * n2 + (n1 + 1) * n2 + n1 * (n2 + 1) + n1 * n2;

    % initial read contol parameters
    readIdx = 0;
    numSkipLine = 5;
    % skip fields
    while readIdx < numTimeStepToSkip
        readIdx = readIdx + 1;
        if readIdx > 1
            numSkipLine = 6;
        end
        cache = textscan(fid, '%f', numFloatInOneTimeStep, 'headerlines', numSkipLine);
        if numel(cache{1}) ~= numFloatInOneTimeStep
            disp(['Fatal Fault! subCase: ',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}])
            disp(['In the local time step idx: ',num2str(readIdx,'%g')])
            disp('Data broken! Not enought floats in one step data!')
        else
            disp(['In subCase: ',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}])
            disp(['skipping the time step ',num2str(readIdx,'%d')])
        end
    end

    disp(['Reaching the local idx ',num2str(localTimeStepIdx,'%d')])
    cache = textscan(fid, '%f', numFloatInOneTimeStep, 'headerlines', numSkipLine);
    if numel(cache{1}) ~= numFloatInOneTimeStep
        disp(['Fatal Fault! subCase: ',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}])
        disp(['In the time step: ',num2str(asmCase.lastReadTime,'%g')])
        disp('Data broken! Not enought floats in one step data!')
        tmpOrg = [];
        u2dOrg = []; 
        v2dOrg = [];
        prsOrg = [];
    else
        headIndex = 1;
        % load tmpOrg Temperature
        for j = 1:n2
            y = y2dS(j);
            for i = 1:n1
                x = x2dS(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    tmpOrg(j, i) = cache{1}(headIndex);    
                else
                    tmpOrg(j, i) = 1;
                end
                headIndex = headIndex + 1;
            end
        end
    
        % load u2dOrg
        for j = 1:n2
            y = y2dU(j);
            for i = 1:(n1 + 1)
                x = x2dU(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    u2dOrg(j, i) = cache{1}(headIndex);
                else
                    u2dOrg(j, i) = 0;
                end
                headIndex = headIndex + 1;
            end
        end
    
        % load v2dOrg
        for j = 1:(n2 + 1)
            y = y2dV(j);
            for i = 1:n1
                x = x2dV(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    v2dOrg(j, i) = cache{1}(headIndex);
                else
                    v2dOrg(j,i) = 0;
                end
                headIndex = headIndex + 1;
            end
        end
    
        % load prsOrg
        for j = 1:n1
            for i = 1:n2
                prsOrg(j, i) = cache{1}(headIndex);
                headIndex = headIndex + 1;
            end
        end
    end
end

