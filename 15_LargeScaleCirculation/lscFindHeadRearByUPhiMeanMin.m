function [head,rear] = lscFindHeadRearByUPhiMeanMin(x,intervalEffect,uPhiNormMeanInTheta)
    numInterval = numel(intervalEffect);
    length = numel(x);
    numHead = numInterval/2;
    numRear = numHead;
    head(numHead) = struct('idxPosition',0,'position',0);
    rear(numRear) = struct('idxPosition',0,'position',0);

    % find peak and bottom
    headCounter = 0;
    rearCounter = 0;
    for idxInterval = 1:numInterval
        if intervalEffect(idxInterval).positive == true
            headCounter = headCounter + 1;
            cutPiece = getCutPiece(intervalEffect(idxInterval),uPhiNormMeanInTheta);
            [~,idxLocal] = min(cutPiece,[],'all');
            head(headCounter).idxPosition = intervalEffect(idxInterval).headIdx + idxLocal -1;
            if head(headCounter).idxPosition > length
                head(headCounter).idxPosition = head(headCounter).idxPosition - length;
            end
            head(headCounter).position = x(head(headCounter).idxPosition);
        else
            rearCounter = rearCounter + 1;
            cutPiece = getCutPiece(intervalEffect(idxInterval),uPhiNormMeanInTheta);
            [~,idxLocal] = min(cutPiece,[],'all');
            rear(rearCounter).idxPosition = intervalEffect(idxInterval).headIdx + idxLocal -1;
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

function [cutPiece] = getCutPiece(interval,array)
    if interval.headIdx < interval.rearIdx
        cutPiece = array(interval.headIdx:interval.rearIdx);
    else
        cutPiece = [array(interval.headIdx:end),array(1:interval.rearIdx)];
    end
end

% function [center] = getIntervalCenter(length,interval)
%     if interval.headIdx < interval.rearIdx
%         center = 0.5*(interval.head + interval.rear);
%     else
%         center = 0.5*(interval.head + length + interval.rear);
%         if center > length
%             center = center - length;
%         end
%     end
% end

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