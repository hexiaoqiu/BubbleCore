function [n1] = asmGetResForTime(asmCase,time)
    % figure out startTime is in which sub case
    for idxSubCase = 1:asmCase.numSubCase
        if time <= asmCase.endTime(idxSubCase)
            idxSelectedSubCase = idxSubCase;
            break
        else
            % disp('Time is invalid! Not in the case temporal scope!')
            idxSelectedSubCase = -1;
        end
    end

    if idxSelectedSubCase == -1
        n1 = NaN;
    else
        n1 = asmCase.n1(idxSelectedSubCase);
    end


end

