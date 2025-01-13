function [intervalEffect] = lscFilterIntervalVer5(interval,vThetaMeanInTheta,relaxation)
    intervalEffect = interval(1);
    numInterval = numel(interval);

    cutPiece = cell(numInterval,1);
    for idxInterval = 1:numInterval
        cutPiece{idxInterval} = getCutPiece(interval(idxInterval),vThetaMeanInTheta);
    end
    
    positiveCounter = 0;
    negativeCounter = 0;
    positiveThreshold = 0;
    negativeThreshold = 0;
    for idxInterval = 1:numInterval
        if interval(idxInterval).positive == 1
            positiveCounter = positiveCounter + 1;
            positiveThreshold = positiveThreshold + ...
                max(cutPiece{idxInterval},[],'all');
        else
            negativeCounter = negativeCounter + 1;
            negativeThreshold = negativeThreshold + ...
                min(cutPiece{idxInterval},[],'all');
        end
    end
    positiveThreshold = relaxation*positiveThreshold/positiveCounter;
    negativeThreshold = relaxation*negativeThreshold/negativeCounter;
    
    idxEffect = 0;
    idxEffectToIdxInterval = zeros(1);
    % find the intervals is very low
    for idxInterval = 1:numInterval
        if interval(idxInterval).positive == 1
            if max(cutPiece{idxInterval},[],"all") > positiveThreshold
                idxEffect = idxEffect + 1;
                intervalEffect(idxEffect) = interval(idxInterval);
                idxEffectToIdxInterval(idxEffect) = idxInterval;
            end
        else
            if min(cutPiece{idxInterval},[],"all") < negativeThreshold
                idxEffect = idxEffect + 1;
                intervalEffect(idxEffect) = interval(idxInterval);
                idxEffectToIdxInterval(idxEffect) = idxInterval;
            end
        end
    end

    % check intervalEffect is in good rhythm
    numInterval = numel(intervalEffect);
    idxInterval = 1;
    while idxInterval <= numInterval - 1
        if intervalEffect(idxInterval).positive == intervalEffect(idxInterval+1).positive
            disp(['interval ',num2str(idxInterval+1),' will be eaten!'])
            intervalEffect(idxInterval).rearIdx = intervalEffect(idxInterval+1).rearIdx;
            intervalEffect(idxInterval).rear = intervalEffect(idxInterval+1).rear;
            % delete the next interval
            intervalEffect(idxInterval+1) = [];
            numInterval = numel(intervalEffect);
            disp(['Update the new interval array! number of interval: ',num2str(numInterval)]);
        else
            idxInterval = idxInterval + 1;
        end
    end

    % check intervalEffect first and last interval is different sign
    if intervalEffect(1).positive == intervalEffect(end).positive
        intervalEffect(1).head = intervalEffect(end).head;
        intervalEffect(1).headIdx = intervalEffect(end).headIdx;
        intervalEffect(end) = [];
    end

end


function [cutPiece] = getCutPiece(interval,vThetaMeanInTheta)
    headIdx = interval.headIdx;
    rearIdx = interval.rearIdx;
    if headIdx > rearIdx
         cutPiece = ...
         [vThetaMeanInTheta(headIdx:end),vThetaMeanInTheta(1:rearIdx)];
    else
        cutPiece = vThetaMeanInTheta(headIdx:rearIdx);
    end
end
