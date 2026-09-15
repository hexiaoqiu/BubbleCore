function [asmCase, tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmInitRead(asmCase,startTime)
    
    [~,idxGlobalFrame] = getClosestTimeStep(asmCase,startTime);
    idxSelectedSubCase = asmCase.globalFrameSubCase(idxGlobalFrame);
    
    if startTime < asmCase.time(1) || startTime > asmCase.time(end)
        error('asmInitRead:TimeOutsideDNS', ...
            'Start time %g is outside the DNS range [%g, %g].', ...
            startTime,asmCase.time(1),asmCase.time(end));
    else
        asmCase.readNowSubCaseIdx = idxSelectedSubCase;
        localTimeStepIdx = asmCase.globalFrameLocal(idxGlobalFrame);
        nssaveDir = fullfile(asmCase.subCaseDir{asmCase.readNowSubCaseIdx},asmCase.dataFileName{asmCase.readNowSubCaseIdx});
        asmCase.lastReadGlobalFrame = idxGlobalFrame;
        asmCase.lastReadTime = asmCase.time(idxGlobalFrame);

        if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
            [numSkipByte] = getNumSkipByte(asmCase,localTimeStepIdx);
            asmCase.readNowFileID = fopen(nssaveDir, 'r','n');
            [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepBin(asmCase,numSkipByte);
        elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
            % [numSkipLine] = getNumSkipLine(asmCase,localTimeStepIdx);
            asmCase.readNowFileID = fopen(nssaveDir, 'r','n','UTF-8');
            % [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepTxt(asmCase,numSkipLine);
            [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadToSpecifiedStepTxt(asmCase,localTimeStepIdx);
        end

        

        asmCase.nextReadGlobalFrame = idxGlobalFrame + 1;
        if asmCase.nextReadGlobalFrame <= asmCase.totalN
            asmCase.nextReadTime = asmCase.time(asmCase.nextReadGlobalFrame);
        else
            asmCase.nextReadTime = NaN;
        end
        asmCase.readCounter = asmCase.readCounter + 1;
    end
end

