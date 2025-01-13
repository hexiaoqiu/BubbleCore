function [peak,bottom] = lscFindByPeakBottomSmoothing(phi,vThetaMeanInTheta,intervalEffect)
    
    length = numel(vThetaMeanInTheta);
    numInterval = numel(intervalEffect);
    numPeak = numInterval/2;
    numBottom = numPeak;
    peak(numPeak) = struct('idxPosition',0,'position',0);
    bottom(numBottom) = struct('idxPosition',0,'position',0);
    
    % find peak and bottom
    peakCounter = 0;
    bottomCounter = 0;
    for idxInterval = 1:numInterval
        if intervalEffect(idxInterval).positive == true
            peakCounter = peakCounter + 1;
            cutPiece = getCutPiece(intervalEffect(idxInterval),vThetaMeanInTheta);
            nWin = 1;
            [~,locs] = findpeaks(cutPiece);
            while numel(locs) ~= 1
                nWin = nWin + 1; 
                [cutPieceSmoothed] = lscSmoothing(cutPiece,nWin);
                [~,locs] = findpeaks(cutPieceSmoothed);
            end
            peak(peakCounter).idxPosition = intervalEffect(idxInterval).headIdx + locs - 1;
            if peak(peakCounter).idxPosition > length
                peak(peakCounter).idxPosition = peak(peakCounter).idxPosition - length;
            end
            peak(peakCounter).position = phi(peak(peakCounter).idxPosition);
        else
            bottomCounter = bottomCounter + 1;
            cutPiece = getCutPiece(intervalEffect(idxInterval),vThetaMeanInTheta);
            cutPieceInv = cutPiece*(-1);
            nWin = 1;
            [~,locs] = findpeaks(cutPieceInv);
            while numel(locs) ~= 1
                nWin = nWin + 1; 
                [cutPieceInvSmoothed] = lscSmoothing(cutPieceInv,nWin);
                [~,locs] = findpeaks(cutPieceInvSmoothed);
            end
            bottom(bottomCounter).idxPosition = intervalEffect(idxInterval).headIdx + locs - 1;
            if bottom(bottomCounter).idxPosition > length
                bottom(bottomCounter).idxPosition = bottom(bottomCounter).idxPosition - length;
            end
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
