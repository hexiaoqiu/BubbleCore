function [idxEffectArray] = asmCaseArrayEffectIdx(asmCase)
    counterEffect = 0;
    idxEffectArray = zeros(1);
    for idxPar = 1:numel(asmCase)
        if isempty(asmCase(idxPar).subCaseDir)
            continue
        else
            counterEffect = counterEffect + 1;
            idxEffectArray(counterEffect) = idxPar;
        end
    end
end