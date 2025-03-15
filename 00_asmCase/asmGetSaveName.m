function [caseName] = asmGetSaveName(asmCase)

    RaStr = num2str(asmCase.realRa,'%3.2E');
    PrStr = num2str(asmCase.Pr,'%g');
    invRoStr = num2str(asmCase.invRo,'%g');
    AStr = num2str(asmCase.A,'%3.2f');
    OmegaStr = num2str(asmCase.Omega_vib,'%g');

    if ~isnan(asmCase.A)
        caseName = ...,
            append('Ra_',RaStr,'_Pr_',PrStr,'_A_',AStr);
    elseif ~isnan(asmCase.Omega_vib)
        caseName = ...,
            append('Ra_',RaStr,'_Pr_',PrStr,'_invRo_',invRoStr,'_omega_',OmegaStr);
    else
        caseName = ...,
            append('Ra_',RaStr,'_Pr_',PrStr,'_invRo_',invRoStr);
    end

end

