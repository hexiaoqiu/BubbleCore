function [interval] = lscFindInterval(x,signal)
    interval = struct('head',0,'rear',0,'headIdx',0,'rearIdx',0,'positive','true');
    length = numel(x);
    listIdxChangePoint = zeros(1);
    numChangePoint = 0;

    for idx = 1:length
        if idx == length
            indicator = signal(idx)*signal(1);
        else
            indicator = signal(idx)*signal(idx+1);
        end
        if indicator > 0
            continue
        else
            numChangePoint = numChangePoint + 1;
            listIdxChangePoint(numChangePoint) = idx;
        end
    end

    numInterval = numChangePoint;
    for idxInterval = 1:numInterval
        if idxInterval == 1
            if listIdxChangePoint(end) == length
                interval(1).headIdx = 1;
            else
                interval(1).headIdx = listIdxChangePoint(end) + 1;
            end
            interval(1).rearIdx = listIdxChangePoint(1);
        else
            interval(idxInterval).headIdx = listIdxChangePoint(idxInterval-1) + 1;
            interval(idxInterval).rearIdx = listIdxChangePoint(idxInterval);
        end
        interval(idxInterval).head = x(interval(idxInterval).headIdx);
        interval(idxInterval).rear = x(interval(idxInterval).rearIdx);
    end

    for idxInterval = 1:numInterval
        if idxInterval == 1
            cutPiece = [signal(interval(idxInterval).headIdx:end), signal(1:interval(idxInterval).rearIdx)];
        else
            cutPiece = signal(interval(idxInterval).headIdx:interval(idxInterval).rearIdx);
        end
        if max(cutPiece,[],"all") < 0
            interval(idxInterval).positive = false;
        elseif min(cutPiece,[],"all") > 0
            interval(idxInterval).positive = true;
        end
    end

end

