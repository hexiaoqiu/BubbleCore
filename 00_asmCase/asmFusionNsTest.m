function [asmTime,asmNRJ,asmENS,asmTEN,asmANGM] = asmFusionNsTest(varargin)
    
    minArgs = 1;
    maxArgs = 2;
    narginchk(minArgs,maxArgs);
    if nargin == 2
        asmCase = varargin{1};
        onlySavedIdx = varargin{2};
    elseif nargin == 1
        asmCase = varargin{1};
        onlySavedIdx = false;
    end

    [timeList,NRJList,ENSList,TENList,ANGMList] = asmGetNsTest(asmCase,onlySavedIdx);

    totalNumSample = 0;
    numSampleNsTestList = zeros(asmCase.numSubCase,1);
    for idxSubCase = 1:asmCase.numSubCase
        numSampleNsTestList(idxSubCase) = numel(timeList{idxSubCase});
        totalNumSample = totalNumSample + numel(timeList{idxSubCase});
    end

    asmTime = zeros(totalNumSample,1);
    asmNRJ = zeros(totalNumSample,1);
    asmENS = zeros(totalNumSample,1);
    asmTEN = zeros(totalNumSample,1);
    asmANGM = zeros(totalNumSample,1);
    for idxSubCase = 1:asmCase.numSubCase
        if idxSubCase == 1
            startIdx = 1;
        else
            startIdx = sum(numSampleNsTestList(1:idxSubCase-1),"all") + 1;
        end
        endIdx = sum(numSampleNsTestList(1:idxSubCase),"all");
        
        if idxSubCase == 1
            asmTime(startIdx:endIdx) = timeList{idxSubCase};
        else
            asmTime(startIdx:endIdx) = asmTime(startIdx-1) + timeList{idxSubCase};
        end
        asmNRJ(startIdx:endIdx) = NRJList{idxSubCase};
        asmENS(startIdx:endIdx) = ENSList{idxSubCase};
        asmTEN(startIdx:endIdx) = TENList{idxSubCase};
        asmANGM(startIdx:endIdx) = ANGMList{idxSubCase};
    end
end