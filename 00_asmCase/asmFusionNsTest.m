function [asmTime, asmNRJ, asmENS, asmTEN, asmANGM] = asmFusionNsTest(varargin)
%ASMFUSIONNSTEST Fuse nstest data from all valid subcases.
%
% Empty subcases are skipped.

    minArgs = 1;
    maxArgs = 2;
    narginchk(minArgs, maxArgs);

    if nargin == 2
        asmCase = varargin{1};
        onlySavedIdx = varargin{2};
    else
        asmCase = varargin{1};
        onlySavedIdx = false;
    end

    [timeList, NRJList, ENSList, TENList, ANGMList] = ...
        asmGetNsTest(asmCase, onlySavedIdx);

    numSubCase = asmCase.numSubCase;

    validSubCase = false(numSubCase, 1);
    numSampleNsTestList = zeros(numSubCase, 1);

    for idxSubCase = 1:numSubCase
        numSample = numel(timeList{idxSubCase});

        if numSample > 0
            validSubCase(idxSubCase) = true;
            numSampleNsTestList(idxSubCase) = numSample;
        end
    end

    totalNumSample = sum(numSampleNsTestList);

    if totalNumSample == 0
        asmTime = [];
        asmNRJ = [];
        asmENS = [];
        asmTEN = [];
        asmANGM = [];
        return;
    end

    asmTime = zeros(totalNumSample, 1);
    asmNRJ = zeros(totalNumSample, 1);
    asmENS = zeros(totalNumSample, 1);
    asmTEN = zeros(totalNumSample, 1);
    asmANGM = zeros(totalNumSample, 1);

    writeStartIdx = 1;
    lastGlobalTime = 0;
    hasPreviousValidSubCase = false;

    for idxSubCase = 1:numSubCase

        if validSubCase(idxSubCase) == false
            warning('asmFusionNsTest:SkipEmptySubCase', ...
                'Skip empty or invalid nstest data in subcase %d.', idxSubCase);
            continue;
        end

        localTime = timeList{idxSubCase};
        localNRJ  = NRJList{idxSubCase};
        localENS  = ENSList{idxSubCase};
        localTEN  = TENList{idxSubCase};
        localANGM = ANGMList{idxSubCase};

        numSample = numel(localTime);

        writeEndIdx = writeStartIdx + numSample - 1;

        if hasPreviousValidSubCase == false
            asmTime(writeStartIdx:writeEndIdx) = localTime;
            hasPreviousValidSubCase = true;
        else
            asmTime(writeStartIdx:writeEndIdx) = lastGlobalTime + localTime;
        end

        asmNRJ(writeStartIdx:writeEndIdx) = localNRJ;
        asmENS(writeStartIdx:writeEndIdx) = localENS;
        asmTEN(writeStartIdx:writeEndIdx) = localTEN;
        asmANGM(writeStartIdx:writeEndIdx) = localANGM;

        lastGlobalTime = asmTime(writeEndIdx);
        writeStartIdx = writeEndIdx + 1;

    end

end


