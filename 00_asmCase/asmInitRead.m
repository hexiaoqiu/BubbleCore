function [asmCase, tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmInitRead(asmCase,startTime)
    
    % figure out startTime is in which sub case
    for idxSubCase = 1:asmCase.numSubCase
        if startTime <= asmCase.endTime(idxSubCase)
            idxSelectedSubCase = idxSubCase;
            break
        else
            idxSelectedSubCase = -1;
        end
    end
    
    if idxSelectedSubCase == -1
        disp(['Start Time ',num2str(startTime,'%g'),' is not in the assemble cases''time range!'])
        tmpOrg = [];
        u2dOrg = [];
        v2dOrg = [];
        prsOrg = [];
        asmCase.lastReadTime = NaN;
    else
        %calculate the local time in the sub case
        asmCase.readNowSubCaseIdx = idxSelectedSubCase;
        if asmCase.readNowSubCaseIdx == 1
            localTime = startTime;
        else
            localTime = startTime - asmCase.endTime(idxSelectedSubCase-1);
        end
        localTimeStepIdx = round(localTime / asmCase.dtSave(asmCase.readNowSubCaseIdx),0);
        nssaveDir = fullfile(asmCase.subCaseDir{asmCase.readNowSubCaseIdx},asmCase.dataFileName{asmCase.readNowSubCaseIdx});
        
        if asmCase.readNowSubCaseIdx == 1
            asmCase.lastReadTime = localTimeStepIdx*asmCase.dtSave(asmCase.readNowSubCaseIdx);
        else
            asmCase.lastReadTime = asmCase.endTime(asmCase.readNowSubCaseIdx-1) + ...,
                localTimeStepIdx*asmCase.dtSave(asmCase.readNowSubCaseIdx);
        end

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

        

        % 计算下一次读取的时间步
        % 先按照下一次读取不会跳case计算
        asmCase.nextReadTime = asmCase.lastReadTime + asmCase.dtSave(asmCase.readNowSubCaseIdx);
        asmCase.nextReadTime = round(asmCase.nextReadTime, asmCase.timePrecision);
        % 注意！不需要考虑是否下一次读取的时间步由于dtSave的不同而大于下一个case的结束时间！
        % 例如：case1 dtSave = 1 case2 dtSave = 0.1 case2只计算了5步
        % 那么当读取到case1的最后一步时t1，此时计算得到的下一次读取时间步为t1+1,肯定大于case2的
        % 终止时间，但是不要紧，因为下一次读取时只检查nextReadTime是否大于case1的终止时间
        % 不会检查case2的终止时间！
        asmCase.readCounter = asmCase.readCounter + 1;
    end
end

