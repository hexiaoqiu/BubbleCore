function [intervalEffect] = lscIntervalReConnect(x,intervalEffect)
    length = numel(x);
    numInterval = numel(intervalEffect);
    for idxInterval = 1:numInterval
        thisInterval = intervalEffect(idxInterval);
        if idxInterval == numInterval
            nextInterval = intervalEffect(1);
        else
            nextInterval = intervalEffect(idxInterval + 1);
        end

        if isConnected(length,thisInterval.rearIdx,nextInterval.headIdx)
            continue
        else
            [thisInterval,nextInterval] = connectInterval(x,thisInterval,nextInterval);
            intervalEffect(idxInterval) = thisInterval;
            if idxInterval == numInterval
                intervalEffect(1) = nextInterval;
            else
                intervalEffect(idxInterval + 1) = nextInterval;
            end
        end
    end
    
end

function [out] = isConnected(length,rearIdx,headIdx)
    if rearIdx == length
        if headIdx == 1
            out = true;
        else
            out = false;
        end
    else
        if headIdx == rearIdx + 1
            out = true;
        else
            out = false;
        end
    end
end

function [thisInterval,nextInterval] = connectInterval(x,thisInterval,nextInterval)
    length = numel(x);
    if nextInterval.headIdx > thisInterval.rearIdx
        newRear = round( 0.5*(nextInterval.headIdx + thisInterval.rearIdx) );
        newHead = newRear + 1;
        thisInterval.rearIdx = newRear;
        nextInterval.headIdx = newHead;
        thisInterval.rear = x(thisInterval.rearIdx);
        nextInterval.head = x(nextInterval.headIdx);
    else
        pesudoHeadIdx = nextInterval.rearIdx + length;
        newRear = round( 0.5*(pesudoHeadIdx + thisInterval.rearIdx) );
        newHead = newRear + 1;
        if newRear > length
            newRear = newRear - length;
        end
        if newHead > length
            newHead = newHead - length;
        end
        
        nextInterval.headIdx = newHead;
        nextInterval.head = x(nextInterval.headIdx);
        thisInterval.rearIdx = newRear;
        thisInterval.rear = x(thisInterval.rearIdx);
        
    end
end



