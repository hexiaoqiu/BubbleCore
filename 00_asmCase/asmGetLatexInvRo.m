function [invRoStr] = asmGetLatexInvRo(asmCase)
    
    invRo = num2str(asmCase.invRo,'%g');
    invRoStr = ['$1/Ro=',invRo,'$'];
    
end