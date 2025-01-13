function [intervalEffect] = lscFilterIntervalVer2(varargin)
    narginchk(2,3)
    if nargin == 2
        interval = varargin{1};
        signal = varargin{2};
        relaxation = 0.5;
    elseif nargin == 3
        interval = varargin{1};
        signal = varargin{2};
        relaxation = varargin{3};
    end

    intervalEffect = interval(1);
    numInterval = numel(interval);
    positiveMean = relaxation*mean(signal(signal>0),"all");
    negativeMean = relaxation*mean(signal(signal<0),"all");
    
    idxEffect = 0;
    idxEffectToIdxInterval = zeros(1);
    cutPiece = cell(numInterval,1);
    for idxInterval = 1:numInterval
        cutPiece{idxInterval} = getCutPiece(interval(idxInterval),signal);
    end

    % find the intervals is very low
    for idxInterval = 1:numInterval
        if interval(idxInterval).positive == 1
            if max(cutPiece{idxInterval},[],"all") > positiveMean
                idxEffect = idxEffect + 1;
                intervalEffect(idxEffect) = interval(idxInterval);
                idxEffectToIdxInterval(idxEffect) = idxInterval;
            end
        else
            if min(cutPiece{idxInterval},[],"all") < negativeMean
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
            % disp(['interval ',num2str(idxInterval+1),' will be eaten!'])
            intervalEffect(idxInterval).rearIdx = intervalEffect(idxInterval+1).rearIdx;
            intervalEffect(idxInterval).rear = intervalEffect(idxInterval+1).rear;
            % delete the next interval
            intervalEffect(idxInterval+1) = [];
            numInterval = numel(intervalEffect);
            % disp(['Update the new interval array! number of interval: ',num2str(numInterval)]);
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
