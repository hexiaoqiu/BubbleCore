function [cLSC,aLSC,numLSC] = lscGetAllLSCVer5(x,UxColdSide,UxHotSide)
    % ver5 take the zonal flow into consideration
    windCold = mean(UxColdSide,"all");
    windHot = mean(UxHotSide,"all");
    UxColdSide = UxColdSide - windCold;
    UxHotSide = UxHotSide - windHot;

    signal = UxColdSide - UxHotSide;
    [interval] = lscFindInterval(x,signal);
    [interval] = lscEvictPertubation(interval,UxColdSide,UxHotSide);
    [interval] = lscReGroup(interval,UxColdSide,UxHotSide);
    [cLSC,aLSC] = interval2LSC(interval,UxColdSide,UxHotSide);
    if numel(cLSC) == numel(aLSC)
        numLSC = numel(cLSC);
    else
        disp('Fatal Error! Orgininal LSCs are not in pair')
        numLSC = NaN;
    end

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
    if interval.headIdx <= interval.rearIdx
        cut = y(interval.headIdx:interval.rearIdx);
    else
        cut = [y(interval.headIdx:end),y(1:interval.rearIdx)];
    end
end

function [interval] = lscReGroup(interval,UxColdSide,UxHotSide)
    numInterval = numel(interval);
    for i = 1:numInterval
        cutUxHot = getCut(interval(i),UxHotSide);
        cutUxCold = getCut(interval(i),UxColdSide);
        clockWise = (mean(cutUxCold,"all") > 0)&&(mean(cutUxHot,"all") < 0);
        aClockWise = (mean(cutUxCold,"all") < 0)&&(mean(cutUxHot,"all") > 0);
        if clockWise == true
            interval(i).clockWise = true;
        elseif aClockWise == true
            interval(i).clockWise = false;
        else
            disp('Fatal error! Still have interval neiher clockwise nor anti-clockwise!')
        end
    end
    
    i = 1;
    while i <= numInterval
        if i <= numInterval-1
            if interval(i).clockWise*interval(i+1).clockWise == 0
                i = i + 1;
            else
                disp(['interval ',num2str(i+1,'%d'),' will be eaten!'])
                interval(i).rearIdx = interval(i+1).rearIdx;
                interval(i).rear = interval(i+1).rear;
                interval(i+1) = [];
                numInterval = numel(interval);
            end
        end

        if i == numInterval
            if interval(i).clockWise*interval(1).clockWise == 0
                i = i + 1;
            else
                 disp(['interval ',num2str(i,'%d'),' will be eaten!'])
                interval(1).headIdx = interval(i).headIdx;
                interval(1).head = interval(i).head;
                interval(i) = [];
                numInterval = numel(interval);
            end
        end
    end

end