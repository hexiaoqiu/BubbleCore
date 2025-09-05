function [textRaPr] = asmGetRaPrText(asmCase)
    RaStr = num2str(asmCase.realRa,'%3.2E');
    PrStr = num2str(asmCase.Pr,'%g');
    textRaPr = ...,
            append('Ra',RaStr,'_Pr',PrStr);
end

