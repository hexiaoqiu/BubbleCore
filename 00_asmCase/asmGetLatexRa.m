function [RaStr] = asmGetLatexRa(asmCase)
    
    exp = floor(log10(asmCase.realRa));
    expStr = num2str(exp,'%d');
    real = asmCase.realRa/(10^(exp));
    realStr = sprintf('%.2f', real);
    realStr = regexprep(realStr, '\.?0+$', '');
    RaStr = ['$Ra=',realStr,'\times 10^{',expStr,'}$'];
    
end