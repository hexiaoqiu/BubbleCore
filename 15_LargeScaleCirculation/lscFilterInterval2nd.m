function [intervalEffect] = lscFilterInterval2nd(x,intervalEffect)
    length = x(end);
    numInterval = numel(intervalEffect);
    for idxInterval = 1:numInterval
        thisInterval = intervalEffect(idxInterval);
        thisIdx = idxInterval;
        if idxInterval + 1 > numInterval
            nextInterval = intervalEffect(1);
            nextIdx = 1;
        else
            nextInterval = intervalEffect(idxInterval + 1);
            nextIdx = idxInterval + 1;
        end
        [widthThis] = getWidth(x,thisInterval);
        [widthNext] = getWidth(x,nextInterval);
        widthThisLSC = 0.5*(widthThis + widthNext);

        widthMeanAll = length/(numInterval);
        if widthThisLSC < 0.3*widthMeanAll
            intervalEffect([thisIdx,nextIdx]) = [];
            disp('Find the abnormal narrow LSC, eliminate it!')
            numInterval = numel(intervalEffect);
            disp(['Now the LSC number is ',num2str(numInterval/2,'%d')]);
            break
        end
    end
end

function [widthThis] = getWidth(x,thisInterval)
    length = x(end);
    if thisInterval.head < thisInterval.rear
        widthThis = thisInterval.rear - thisInterval.head;
    else
        widthThis = length + thisInterval.rear - thisInterval.head;
    end
end