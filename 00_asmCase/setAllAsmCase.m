function [asmCaseEmpty] = setAllAsmCase(configList)
    [asmCaseEmpty] = setAsmCaseEmpty();
    for idxA = 1:numel(configList)
        for idxRa = 1:numel(configList{idxA})
            asmCaseEmpty(idxA,idxRa) = asmCaseEmpty(1);
        end
    end
    for idxA = 1:numel(configList)
        for idxRa = 1:numel(configList{idxA})
            asmCaseEmpty(idxA,idxRa) = ...
                setAsmCase(configList{idxA}(idxRa).caseDir,asmCaseEmpty(idxA,idxRa));
        end
    end
end