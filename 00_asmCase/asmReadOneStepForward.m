function [asmCase,tmpOrg,u2dOrg,v2dOrg,prsOrg] = ...
        asmReadOneStepForward(asmCase)
%ASMREADONESTEPFORWARD Read the next snapshot using its integer frame index.

    idxGlobalFrame = asmCase.nextReadGlobalFrame;
    if idxGlobalFrame > asmCase.totalN
        disp('All the subCases have been gone through! No more data to read!')
        tmpOrg = [];
        u2dOrg = [];
        v2dOrg = [];
        prsOrg = [];
        asmCase.nextReadTime = NaN;
        return
    end

    idxTargetSubCase = asmCase.globalFrameSubCase(idxGlobalFrame);
    if idxTargetSubCase ~= asmCase.readNowSubCaseIdx
        disp(['The subCase ', ...
            asmCase.subCaseDir{asmCase.readNowSubCaseIdx}, ...
            ' have been gone through!'])
        fclose(asmCase.readNowFileID);
        disp(['Move to the next subCase: ', ...
            asmCase.subCaseDir{idxTargetSubCase}])
        asmCase.readNowSubCaseIdx = idxTargetSubCase;
        nssaveDir = fullfile(asmCase.subCaseDir{idxTargetSubCase}, ...
            asmCase.dataFileName{idxTargetSubCase});
        if strcmp(asmCase.type{idxTargetSubCase},'txt')
            asmCase.readNowFileID = fopen(nssaveDir,'r','n','UTF-8');
            numSkipLine = 5;
        elseif strcmp(asmCase.type{idxTargetSubCase},'bin')
            asmCase.readNowFileID = fopen(nssaveDir,'r','n');
            numSkipByte = 0;
        end
    else
        if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
            numSkipByte = 0;
        elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
            numSkipLine = 6;
        end
    end

    asmCase.lastReadGlobalFrame = idxGlobalFrame;
    asmCase.lastReadTime = asmCase.time(idxGlobalFrame);
    asmCase.nextReadGlobalFrame = idxGlobalFrame + 1;
    if asmCase.nextReadGlobalFrame <= asmCase.totalN
        asmCase.nextReadTime = asmCase.time(asmCase.nextReadGlobalFrame);
    else
        asmCase.nextReadTime = NaN;
    end
    asmCase.readCounter = asmCase.readCounter + 1;

    if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
        [tmpOrg,u2dOrg,v2dOrg,prsOrg] = ...
            asmReadOneStepBin(asmCase,numSkipByte);
    elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
        [tmpOrg,u2dOrg,v2dOrg,prsOrg] = ...
            asmReadOneStepTxt(asmCase,numSkipLine);
    end
end
