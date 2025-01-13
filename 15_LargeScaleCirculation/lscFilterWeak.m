function [cLSC,aLSC,numCLSC,numALSC] = lscFilterWeak(x,cLSC,aLSC)
    LSC = [cLSC,aLSC];
    numLSC = numel(LSC);
    width = zeros(numLSC,1);
    for i = 1:numLSC
        width(i) = getLSCWidth(x,LSC(i));
    end
    widthMean = round(mean(width,"all"));
    widthSigma = round(std(width,1,"all"));
    smallest = widthMean - 2*widthSigma;
    
    counter = 0;
    deleteIdxArray = zeros(1);
    for i = 1:numel(cLSC)
        widthThis = getLSCWidth(x,cLSC(i));
        if widthThis < smallest
            counter = counter + 1;
            deleteIdxArray(counter) = i;
        end
    end
    if sum(deleteIdxArray,"all") ~= 0
        cLSC(deleteIdxArray) = [];
    end

    counter = 0;
    deleteIdxArray = zeros(1);
    for i = 1:numel(aLSC)
        widthThis = getLSCWidth(x,aLSC(i));
        if widthThis < smallest
            counter = counter + 1;
            deleteIdxArray(counter) = i;
        end
    end
    if sum(deleteIdxArray,"all") ~= 0
        aLSC(deleteIdxArray) = [];
    end

    numCLSC = numel(cLSC);
    numALSC = numel(aLSC);

end

function [width] = getLSCWidth(x,LSC)
    length = numel(x);
    if LSC.headIdx <= LSC.rearIdx
        width = LSC.rearIdx - LSC.headIdx + 1;
    else
        width = LSC.rearIdx + length - LSC.headIdx;
    end
end