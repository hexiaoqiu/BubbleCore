function [intervalEffect] = lscFilterIntervalVer6(interval,vThetaMeanInTheta,relaxation)
    intervalEffect = interval(1);
    numInterval = numel(interval);

    cutPiece = cell(numInterval,1);
    for idxInterval = 1:numInterval
        cutPiece{idxInterval} = getCutPiece(interval(idxInterval),vThetaMeanInTheta);
    end
    
    numPeak = 0;
    numBottom = 0;
    peak = zeros(1);
    bottom = zeros(1);
    for idxInterval = 1:numInterval
        if interval(idxInterval).positive == 1
            numPeak = numPeak + 1;
            peak(numPeak) = max(cutPiece{idxInterval},[],'all');
        else
            numBottom = numBottom + 1;
            bottom(numBottom) = min(cutPiece{idxInterval},[],'all');
        end
    end
    peakMean = mean(peak,"all");
    bottomMean = mean(bottom,"all");
    peakSigma = std(peak,1);
    bottomSigma = std(bottom,1);
    
    idxEffect = 0;
    idxEffectToIdxInterval = zeros(1);
    % find the intervals is very low
    for idxInterval = 1:numInterval
        if interval(idxInterval).positive == 1
            if max(cutPiece{idxInterval},[],"all") > peakMean - relaxation*peakSigma
                idxEffect = idxEffect + 1;
                intervalEffect(idxEffect) = interval(idxInterval);
                idxEffectToIdxInterval(idxEffect) = idxInterval;
            end
        else
            if min(cutPiece{idxInterval},[],"all") < bottomMean + relaxation*bottomSigma
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
