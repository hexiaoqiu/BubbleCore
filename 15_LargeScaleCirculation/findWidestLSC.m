function [LSC_1] = findWidestLSC(x,LSC)
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
    
    [~,maxIdx] = max(width,[],"all");

    LSC_1 = LSC(maxIdx);
end