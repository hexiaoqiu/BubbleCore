function [numSteps] = asmGetNumSteps(asmCase)
    % numSteps = 0;
    % for idxCase = 1:asmCase.numSubCase
    %     Time = asmCase.endTime(idxCase) - asmCase.startTime(idxCase);
    %     dtSave = asmCase.dtSave(idxCase);
    %     numSteps = numSteps + round(Time/dtSave) + 1;
    % end
    
    numSteps = sum(asmCase.maxN,'all');
end

