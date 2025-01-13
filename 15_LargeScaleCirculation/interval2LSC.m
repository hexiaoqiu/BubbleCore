function [cLSC,aLSC] = interval2LSC(interval,UxColdSide,UxHotSide)
    
    cLSC = struct(...
        'head',0, ...
        'rear',0, ...
        'headIdx',0, ...
        'rearIdx',0 ...
        ...% 'tmpCut',0, ...
        ...% 'tmpScale',0, ...
        ...% 'uPhiCut',0, ...
        ...% 'uPhiScale',0, ...
        ...% 'vThetaCut',0, ...
        ...% 'vThetaScale',0 ...
        );
    aLSC = cLSC;

    counterCLSC = 0;
    counterALSC = 0;

    for i = 1:numel(interval)
        cutUxHot = getCut(interval(i),UxHotSide);
        cutUxCold = getCut(interval(i),UxColdSide);
        clockWise = (mean(cutUxCold,"all") > 0)&&(mean(cutUxHot,"all") < 0);
        aClockWise = (mean(cutUxCold,"all") < 0)&&(mean(cutUxHot,"all") > 0);

        if clockWise == true
            counterCLSC = counterCLSC + 1;
            cLSC(counterCLSC).head = interval(i).head;
            cLSC(counterCLSC).rear = interval(i).rear;
            cLSC(counterCLSC).headIdx = interval(i).headIdx;
            cLSC(counterCLSC).rearIdx = interval(i).rearIdx;
        elseif aClockWise == true
            counterALSC = counterALSC + 1;
            aLSC(counterALSC).head = interval(i).head;
            aLSC(counterALSC).rear = interval(i).rear;
            aLSC(counterALSC).headIdx = interval(i).headIdx;
            aLSC(counterALSC).rearIdx = interval(i).rearIdx;
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
