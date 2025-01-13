function [cLSC,aLSC,numLSC] = lscGetAllLSCVer3(x,UxColdSide,UxHotSide)

    signal = UxColdSide - UxHotSide;
    [interval] = lscFindInterval(x,signal);
    [interval] = lscEvictPertubation(interval,UxColdSide,UxHotSide);
    [cLSC,aLSC] = interval2LSC(interval,UxColdSide,UxHotSide);
    numLSC = numel(cLSC);
    
end

function [interval] = lscEvictPertubation(interval,UxColdSide,UxHotSide)
    numInterval = numel(interval);
    i = 1;
    while i <= numInterval
        cutUxHot = getCut(interval(i),UxHotSide);
        cutUxCold = getCut(interval(i),UxColdSide);
        clockWise = (mean(cutUxCold,"all") > 0)&&(mean(cutUxHot,"all") < 0);
        aClockWise = (mean(cutUxCold,"all") < 0)&&(mean(cutUxHot,"all") > 0);

        if (clockWise == false)&&(aClockWise == false)
            disp(['Find Pertubation! Evict interval no. ',num2str(i,'%d')])
            if i == 1
                interval(2).headIdx = interval(numInterval).headIdx;
                interval(2).head = interval(numInterval).head;
                interval(numInterval) = [];
                interval(1) = [];
                numInterval = numel(interval);
                i = 1;
            elseif i == numInterval
                interval(numInterval-1).rearIdx = interval(1).rearIdx;
                interval(numInterval-1).rear = interval(1).rear;
                interval(numInterval) = [];
                interval(1) = [];
                numInterval = numel(interval);
                i = numInterval;
            else
                interval(i-1).rearIdx = interval(i+1).rearIdx;
                interval(i-1).rear = interval(i+1).rear;
                interval(i+1) = [];
                interval(i) = [];
                numInterval = numel(interval);
                i = i -1;
            end
        else
            i = i + 1;
        end
    end 
end

function [cut] = getCut(interval,y)
    if interval.headIdx < interval.rearIdx
        cut = y(interval.headIdx:interval.rearIdx);
    else
        cut = [y(interval.headIdx:end),y(1:interval.rearIdx)];
    end
end