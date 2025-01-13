function [AStr] = asmGetLatexA(asmCase)

    AStr = ['$A=',num2str(asmCase.A,'%3.2f'),'$'];

end
