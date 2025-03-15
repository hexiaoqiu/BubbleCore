function [numSteps] = asmGetNumSteps(asmCase)
    numSteps = sum(asmCase.maxN,'all');
end

