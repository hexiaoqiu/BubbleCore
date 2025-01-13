function [idxSubCase] = asmGetSubCaseIdxByTime(asmCase,time)
    for idxSubCase = 1:asmCase.numSubCase
        if time <= asmCase.endTime(idxSubCase)
            return
        else
            continue
        end
    end
    disp([num2str(time,'%g'),'is not found in this asmCase!'])
    idxSubCase = nan;
end

