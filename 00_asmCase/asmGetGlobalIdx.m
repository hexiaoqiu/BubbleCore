function [idxG] = asmGetGlobalIdx(asmCase,time)

    [idxSubCase] = asmGetSubCaseIdxByTime(asmCase,time);
    if isnan(idxSubCase)
        disp([num2str(time,'%g'),'is not found in this asmCase!'])
        idxG = nan;
        return
    end
    
    if idxSubCase == 1
        localTime = time;   
    else
        localTime = time - asmCase.endTime(idxSubCase-1);
    end
    localTimeStepIdx = floor(localTime / asmCase.dtSave(idxSubCase));
    
    if idxSubCase == 1
        idxG = localTimeStepIdx;
    else
        idxG = localTimeStepIdx + sum(asmCase.maxN(1:idxSubCase-1),'all');
    end
    
end