function [intervalEffectGood] = lscFilterInterval(interval,vThetaMeanInTheta)
    intervalEffect = interval(1);
    numInterval = numel(interval);
    positiveMean = 0.5*mean(vThetaMeanInTheta(vThetaMeanInTheta>0),"all");
    negativeMean = 0.5*mean(vThetaMeanInTheta(vThetaMeanInTheta<0),"all");
    
    idxEffect = 0;
    idxEffectToIdxInterval = zeros(1);
    cutPiece = cell(numInterval,1);
    for idxInterval = 1:numInterval
        if idxInterval == 1
            cutPiece{idxInterval} = [vThetaMeanInTheta(interval(idxInterval).headIdx:end), vThetaMeanInTheta(1:interval(idxInterval).rearIdx)];
        else
            cutPiece{idxInterval} = vThetaMeanInTheta(interval(idxInterval).headIdx:interval(idxInterval).rearIdx);
        end
    end
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
    problemSection = cell(1);
    problemCounter = 0;
    problemSize = 2;
    signalFlag = intervalEffect(1).positive;
    for idxEffect = 2:numel(intervalEffect)  
        if signalFlag == intervalEffect(idxEffect).positive
            if problemSize == 2
                problemCounter = problemCounter + 1;
                problemSection{problemCounter}(problemSize-1) = idxEffect-1;
                problemSection{problemCounter}(problemSize) = idxEffect;
            else
                problemSize = problemSize + 1;
                problemSection{problemCounter}(problemSize) = idxEffect;
            end
        else
            signalFlag = intervalEffect(idxEffect).positive;
            problemSize = 2;
        end
    end
    numProblem = problemCounter;
    
    if numProblem == 0
        disp('No problem is found!');
        intervalEffectGood = intervalEffect;

    else
        intervalEffectGood = intervalEffect;

        % scan the problem to correspond problem idx to good effect
        % interval idx
        shiftValue = 0;
        idxProbToGoodEffect = zeros(numProblem,1);
        for idxProblem = 1:numProblem
            idxProbToGoodEffect(idxProblem) = ...
                problemSection{idxProblem}(1) - shiftValue;
            shiftValue = shiftValue + numel(problemSection{idxProblem}) -1;
        end
        % find the interval idx bad to delete
        numBadInterval = 0;
        for idxProblem = 1:numProblem
            numBadInterval = numBadInterval + numel(problemSection{idxProblem});
        end
        listIdxIntervalToDelete = zeros(1,numBadInterval-numProblem);
        idxDeleteCounter = 0;
        for idxProblem = 1:numProblem
            numIntervalThisProblem = numel(problemSection{idxProblem});
            for i = 2:numIntervalThisProblem
                idxDeleteCounter = idxDeleteCounter + 1;
                listIdxIntervalToDelete(idxDeleteCounter) = problemSection{idxProblem}(i);
            end
        end
        intervalEffectGood(listIdxIntervalToDelete) = [];
    
        for idxProblem = 1:numel(problemSection)
            numCut = numel(problemSection{idxProblem});
            cutPieceProblem = cell(numCut,1);
            for idxCut = 1:numCut
                idxIntervalEffect = problemSection{idxProblem}(idxCut);
                idxInterval = idxEffectToIdxInterval(idxIntervalEffect);
                cutPieceProblem{idxCut} = cutPiece{idxInterval};
            end
            idxFirstInterval = problemSection{idxProblem}(1);
            if intervalEffect(idxFirstInterval).positive == true
                peak = zeros(numCut,1);
                for idxCut = 1:numCut
                    peak(idxCut) = max(cutPieceProblem{idxCut},[],'all');
                end
                [~,idxCutMax] = max(peak,[],'all');
                idxIntervalEffectGood = idxProbToGoodEffect(idxProblem);
                idxIntervalEffect = problemSection{idxProblem}(idxCutMax);
                intervalEffectGood(idxIntervalEffectGood) = intervalEffect(idxIntervalEffect);
            else
                bottom = zeros(numCut,1);
                for idxCut = 1:numCut
                    bottom(idxCut) = min(cutPieceProblem{idxCut},[],'all');
                end
                [~,idxCutMin] = min(bottom,[],'all');
                idxIntervalEffectGood = idxProbToGoodEffect(idxProblem);
                idxIntervalEffect = problemSection{idxProblem}(idxCutMin);
                intervalEffectGood(idxIntervalEffectGood) = intervalEffect(idxIntervalEffect);
            end
        end
    end
    
    % check head and rear
    idxEffectRear = numel(intervalEffectGood);
    idxEffectHead = 1;
    if intervalEffectGood(idxEffectRear).positive == intervalEffectGood(idxEffectHead).positive
        % the head and rear must be delete one
        % find the cut piece
        if intervalEffectGood(idxEffectHead).headIdx < intervalEffectGood(idxEffectHead).rearIdx
            cutPieceHead = vThetaMeanInTheta(intervalEffectGood(idxEffectHead).headIdx:intervalEffectGood(idxEffectHead).rearIdx);
        else
            cutPieceHead = [vThetaMeanInTheta(intervalEffectGood(idxEffectHead).headIdx:end), vThetaMeanInTheta(1:intervalEffectGood(idxEffectHead).rearIdx)];
        end
        if intervalEffectGood(idxEffectRear).headIdx < intervalEffectGood(idxEffectRear).rearIdx
            cutPieceRear = vThetaMeanInTheta(intervalEffectGood(idxEffectRear).headIdx:intervalEffectGood(idxEffectRear).rearIdx);
        else
            cutPieceRear = [vThetaMeanInTheta(intervalEffectGood(idxEffectRear).headIdx:end), vThetaMeanInTheta(1:intervalEffectGood(idxEffectRear).rearIdx)];
        end
        % compare to ditermine which to be deleted
        if intervalEffectGood(idxEffectRear).positive == 1
            peak = zeros(2,1);
            peak(1) = max(cutPieceHead,[],"all");
            peak(2) = max(cutPieceRear,[],"all");
            [~,idx] = max(peak,[],'all');
        else
            bottom = zeros(2,1);
            bottom(1) = min(cutPieceHead,[],"all");
            bottom(2) = min(cutPieceRear,[],"all");
            [~,idx] = min(bottom,[],'all');
        end
        if idx == 1
            intervalEffectGood(end) = [];
        else
            intervalEffectGood(1) = [];
        end
    end
end

