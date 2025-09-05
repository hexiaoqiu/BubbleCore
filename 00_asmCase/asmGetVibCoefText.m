function [vibCoefText] = asmGetVibCoefText(asmCase)
    invRoStr = num2str(asmCase.invRo,'%g');
    OmegaStr = num2str(asmCase.Omega_vib,'%g');
    vibCoefText = ...,
            append('invRo',invRoStr,'_omega',OmegaStr);
end