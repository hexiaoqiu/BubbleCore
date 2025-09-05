function [invRoText] = asmGetInvRoText(asmCase)
    invRoStr = num2str(asmCase.invRo,'%g');
    invRoText = ...,
            append('invRo_',invRoStr);
end

