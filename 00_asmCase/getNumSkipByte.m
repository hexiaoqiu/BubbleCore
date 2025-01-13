function [numSkipByte] = getNumSkipByte(asmCase,localTimeStepIdx)
    
    idxSelectedSubCase = asmCase.readNowSubCaseIdx;
    numTimeStepToSkip = localTimeStepIdx - 1;
    if numTimeStepToSkip == 0
        numSkipByte = 0;
    else
        % one step byte number = 
        %   header: 4 * double(8) + 2 * int(4)
        %   tmpOrg: n2*n1 double(8)
        %   u2dOrg: n2*(n1+1) double(8)
        %   v2dOrg: (n2+1)*n1 double(8)
        %   prsOrg: n2*n1 double(8)
        numByte4OneStepData = ...,
            4*8 + 2*4 + ...
            asmCase.n2(idxSelectedSubCase)*asmCase.n1(idxSelectedSubCase)*8 + ...
            asmCase.n2(idxSelectedSubCase)*(asmCase.n1(idxSelectedSubCase)+1)*8 + ...
            (asmCase.n2(idxSelectedSubCase)+1)*asmCase.n1(idxSelectedSubCase)*8 + ...
            asmCase.n2(idxSelectedSubCase)*asmCase.n1(idxSelectedSubCase)*8;
        numSkipByte = numByte4OneStepData*numTimeStepToSkip;
    end
end

