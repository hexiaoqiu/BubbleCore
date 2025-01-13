function [head,rear] = lscFindHearRearVer3(x,interval,UxMean)
    numInterval = numel(interval);
    numHead = numInterval/2;
    numRear = numHead;
    length = numel(x);
    head(numHead) = struct('idxPosition',0,'position',0);
    rear(numRear) = struct('idxPosition',0,'position',0);

    % find peak and bottom
    headCounter = 0;
    rearCounter = 0;
    for idx = 1:numInterval
        if interval(idx).positive == true
            headCounter = headCounter + 1;
            [cut] = getCutPiece(interval(idx),UxMean);
            [~,idxLocal] = min(cut,[],"all");
            head(headCounter).idxPosition = idxLocal2Global(interval(idx),idxLocal,length);
            head(headCounter).position = x(head(headCounter).idxPosition);
        else
            rearCounter = rearCounter + 1;
            [cut] = getCutPiece(interval(idx),UxMean);
            [~,idxLocal] = min(cut,[],"all");
            rear(rearCounter).idxPosition = idxLocal2Global(interval(idx),idxLocal,length);
            rear(rearCounter).position = x(rear(rearCounter).idxPosition);
        end
    end

    % sort head and rear
    [head] = sortByIdxPosition(head);
    [rear] = sortByIdxPosition(rear);
end

function [cut] = getCutPiece(interval,UxMean)
    if interval.headIdx < interval.rearIdx
        cut = UxMean(interval.headIdx: interval.rearIdx);
    else
        cut = [UxMean(interval.headIdx:end),UxMean(1:interval.rearIdx)];
    end
end

function [globalIdx] = idxLocal2Global(interval,idxLocal,length)
    globalIdx = interval.headIdx + idxLocal -1;
    if globalIdx > length
        globalIdx = globalIdx - length;
    end
end

function [head] = sortByIdxPosition(head)
    numHead = numel(head);
    idxHeadPosition = zeros(numHead,1);
    for idxHead = 1:numHead
        idxHeadPosition(idxHead) = head(idxHead).idxPosition;
    end
    [~,idxTrans] = sort(idxHeadPosition,'ascend');
    headOld = head;
    head(1:end) = headOld(idxTrans(1:end));
end