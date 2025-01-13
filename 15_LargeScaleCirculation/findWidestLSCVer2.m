function [LSC_1] = findWidestLSCVer2(x,LSC,numSelect)
    numLSC = numel(LSC);
    length = numel(x);

    width = zeros(numLSC,1);
    for idx = 1:numLSC
        if LSC(idx).headIdx < LSC(idx).rearIdx
            width(idx) = LSC(idx).rearIdx - LSC(idx).headIdx;
        else
            width(idx) = length + LSC(idx).rearIdx - LSC(idx).headIdx;
        end
    end
    
    [~,idxSorted] = sort(width,"descend");

    LSC_1 = LSC(idxSorted);
    LSC_1(numSelect+1:numLSC) = []; 
end