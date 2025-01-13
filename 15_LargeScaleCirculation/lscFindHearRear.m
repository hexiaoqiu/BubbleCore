function [head,rear] = lscFindHearRear(x,intervalEffect)
    numInterval = numel(intervalEffect);
    numHead = numInterval/2;
    numRear = numHead;
    length = x(end);
    head(numHead) = struct('idxPosition',0,'position',0);
    rear(numRear) = struct('idxPosition',0,'position',0);

    % find peak and bottom
    headCounter = 0;
    rearCounter = 0;
    for idxInterval = 1:numInterval
        if intervalEffect(idxInterval).positive == true
            headCounter = headCounter + 1;
            center = getIntervalCenter(length,intervalEffect(idxInterval));
            [~,head(headCounter).idxPosition] = ...
                min(abs(x - center),[],'all');
            head(headCounter).position = x(head(headCounter).idxPosition);
        else
            rearCounter = rearCounter + 1;
            center = getIntervalCenter(length,intervalEffect(idxInterval));
            [~,rear(rearCounter).idxPosition] = ...
                min(abs(x - center),[],'all');
            rear(rearCounter).position = x(rear(rearCounter).idxPosition);
        end
    end

    % sort head and rear
    [head] = sortByIdxPosition(head);
    [rear] = sortByIdxPosition(rear);
end

function [center] = getIntervalCenter(length,interval)
    if interval.headIdx < interval.rearIdx
        center = 0.5*(interval.head + interval.rear);
    else
        center = 0.5*(interval.head + length + interval.rear);
        if center > length
            center = center - length;
        end
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