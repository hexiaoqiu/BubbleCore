function [head,rear] = lscFindHearRearVer2(x,intervalEffect,signal)
    numInterval = numel(intervalEffect);
    numHead = numInterval/2;
    numRear = numHead;
    length = numel(x);
    head(numHead) = struct('idxPosition',0,'position',0);
    rear(numRear) = struct('idxPosition',0,'position',0);

    % find peak and bottom
    headCounter = 0;
    rearCounter = 0;
    for idxInterval = 1:numInterval
        if intervalEffect(idxInterval).positive == true
            headCounter = headCounter + 1;
            localIdx = getPeakIdx(intervalEffect(idxInterval),signal);
            head(headCounter).idxPosition = intervalEffect(idxInterval).headIdx + localIdx -1;
            if head(headCounter).idxPosition > length
                head(headCounter).idxPosition = head(headCounter).idxPosition - length;
            end
            head(headCounter).position = x(head(headCounter).idxPosition);
        else
            rearCounter = rearCounter + 1;
            localIdx = getBottomIdx(intervalEffect(idxInterval),signal);
            rear(rearCounter).idxPosition = intervalEffect(idxInterval).headIdx + localIdx -1;
            if rear(rearCounter).idxPosition > length
                rear(rearCounter).idxPosition = rear(rearCounter).idxPosition - length;
            end
            rear(rearCounter).position = x(rear(rearCounter).idxPosition);
        end
    end

    % sort head and rear
    [head] = sortByIdxPosition(head);
    [rear] = sortByIdxPosition(rear);
end

function localIdx = getPeakIdx(interval,signal)
    if interval.headIdx < interval.rearIdx
        piece = signal(interval.headIdx : interval.rearIdx);
    else
        piece = [signal(interval.headIdx:end), signal(1:interval.rearIdx)];
    end
    [~,localIdx] = max(piece,[],'all');
end

function localIdx = getBottomIdx(interval,signal)
    if interval.headIdx < interval.rearIdx
        piece = signal(interval.headIdx : interval.rearIdx);
    else
        piece = [signal(interval.headIdx:end), signal(1:interval.rearIdx)];
    end
    [~,localIdx] = min(piece,[],'all');
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