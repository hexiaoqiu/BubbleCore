function [peak,bottom] = lscFindPeakBottom(phi,vThetaMeanInTheta,intervalEffect)
    
    numInterval = numel(intervalEffect);
    numPeak = numInterval/2;
    numBottom = numPeak;
    peak(numPeak) = struct('idxPosition',0,'position',0,'value',0);
    bottom(numBottom) = struct('idxPosition',0,'position',0,'value',0);

    cutPiece = cell(numInterval,1);
    for idxInterval = 1:numInterval
        headIdx = intervalEffect(idxInterval).headIdx;
        rearIdx = intervalEffect(idxInterval).rearIdx;
        if headIdx > rearIdx
             cutPiece{idxInterval} = ...
             [vThetaMeanInTheta(headIdx:end),vThetaMeanInTheta(1:rearIdx)];
        else
            cutPiece{idxInterval} = vThetaMeanInTheta(headIdx:rearIdx);
        end
    end
    
    % find peak and bottom
    peakCounter = 0;
    bottomCounter = 0;
    for idxInterval = 1:numInterval
        if intervalEffect(idxInterval).positive == true
            peakCounter = peakCounter + 1;
            peak(peakCounter).value = max(cutPiece{idxInterval},[],'all');
            [~,peak(peakCounter).idxPosition] = ...
                min(abs(vThetaMeanInTheta - peak(peakCounter).value),[],'all');
            peak(peakCounter).position = phi(peak(peakCounter).idxPosition);
        else
            bottomCounter = bottomCounter + 1;
            bottom(bottomCounter).value = min(cutPiece{idxInterval},[],'all');
            [~,bottom(bottomCounter).idxPosition] = ...
                min(abs(vThetaMeanInTheta - bottom(bottomCounter).value),[],'all');
            bottom(bottomCounter).position = phi(bottom(bottomCounter).idxPosition);
        end
    end

    % sort peak and bottom
    idxPeakPosition = zeros(numPeak,1);
    for idxPeak = 1:numPeak
        idxPeakPosition(idxPeak) = peak(idxPeak).idxPosition;
    end
    [~,idxTrans] = sort(idxPeakPosition,'ascend');
    peakOld = peak;
    peak(1:end) = peakOld(idxTrans(1:end));
    
    idxBottomPosition = zeros(numBottom,1);
    for idxBottom = 1:numBottom
        idxBottomPosition(idxBottom) = bottom(idxBottom).idxPosition;
    end
    [~,idxTrans] = sort(idxBottomPosition,'ascend');
    bottomOld = bottom;
    bottom(1:end) = bottomOld(idxTrans(1:end));
end

