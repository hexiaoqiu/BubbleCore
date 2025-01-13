function [WStr] = asmGetLatexW(asmCase)
    
    WStr = ['$W=',num2str(asmCase.W,'%3.2f'),'$'];
    
end