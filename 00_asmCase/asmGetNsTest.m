function [timeList,NRJList,ENSList,TENList,ANGMList] = asmGetNsTest(varargin)
    
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

    numCase = asmCase.numSubCase;

    timeList = cell(numCase,1);
    NRJList = cell(numCase,1);
    ENSList = cell(numCase,1);
    TENList = cell(numCase,1);
    ANGMList = cell(numCase,1);
    for idxSubCase = 1:numCase
        if onlySavedIdx == false
            [timeList{idxSubCase}, ...
             NRJList{idxSubCase}, ...
             ENSList{idxSubCase}, ...
             TENList{idxSubCase}, ...
             ANGMList{idxSubCase}] ...,
            = getNsTest(asmCase.subCaseDir{idxSubCase});
        else
            [time, ...
             NRJ, ...
             ENS, ...
             TEN, ...
             ANGM] ...,
            = getNsTest(asmCase.subCaseDir{idxSubCase});
            saveInterval = asmCase.dtSave(idxSubCase)/(asmCase.dt(idxSubCase)*2);
            saveIdx = saveInterval:saveInterval:numel(time);
            timeList{idxSubCase} = time(saveIdx);
            NRJList{idxSubCase} = NRJ(saveIdx);
            ENSList{idxSubCase} = ENS(saveIdx);
            TENList{idxSubCase} = TEN(saveIdx);
            ANGMList{idxSubCase} = ANGM(saveIdx);
        end
    end

end

