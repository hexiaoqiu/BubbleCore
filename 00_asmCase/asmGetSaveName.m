function [caseName] = asmGetSaveName(asmCase)

    RaStr = num2str(asmCase.realRa,'%3.2E');
    PrStr = num2str(asmCase.Pr,'%g');
    AStr = num2str(asmCase.A,'%3.2f');
    
    caseName = ...,
        append('Ra_',RaStr,'_A_',AStr,'_Pr_',PrStr);

end

