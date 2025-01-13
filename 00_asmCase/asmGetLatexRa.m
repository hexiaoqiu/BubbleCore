function [RaStr] = asmGetLatexRa(asmCase)
    
    exp = floor(log10(asmCase.realRa));
    expStr = num2str(exp,'%d');
    real = asmCase.realRa/(10^(exp));
    realStr = num2str(real,'%3.2f');
    RaStr = ['$Ra=',realStr,'\times 10^{',expStr,'}$'];
    
end