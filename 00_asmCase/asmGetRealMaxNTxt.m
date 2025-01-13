function [realMaxN] = asmGetRealMaxNTxt(rawCaseDir)

    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(rawCaseDir);

    % start the read loop
    % calculate the quntity of numbers in one timeStep
    % tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
    % n1*n2         n2*(n1+1)               (n2+1)*n1               n1*n2;
    numFloatInOneTimeStep = n1 * n2 + (n1 + 1) * n2 + n1 * (n2 + 1) + n1 * n2;
%     numLine = ceil(numFloatInOneTimeStep / 5) + 1;
    halt = 0; % stop sign
    timeStep = 0; % time step indicator
    % open file
    nssaveDir = fullfile(rawCaseDir,'nssave.dat');
    fid = fopen(nssaveDir, 'r','n','UTF-8');
    % startReading = false;
    

    while halt == 0
        % indicate the index to operate
        timeStep = timeStep + 1;
        disp(['Check time step = ',num2str(timeStep,'%d')])
        if timeStep == maxN
            halt = 1;
        end

        if timeStep == 1
            % This is first time to read
            % Skip all the timeSteps before
            numLineSkip = 5;
        else
            % this is not the first time to read
            % only to skile the head line and the last read line
            numLineSkip = 6;
        end

        % read fields
        cache = textscan(fid, '%f', numFloatInOneTimeStep, 'headerlines', numLineSkip);
        % compare the number of float number in the buffer
        numFloat = numel(cache{1});
        if numFloat ~= numFloatInOneTimeStep
            % if the number of float is less than normal
            % means that this step is broken
            timeStep = timeStep - 1;
            disp('One or More time step data is corrupted');
            disp(['The last good time step is stored is ',num2str(timeStep,'%d')])
            break
        end

        if feof(fid) == true
            break;
        end
        

    end
    realMaxN = timeStep;
    fclose(fid);
end

