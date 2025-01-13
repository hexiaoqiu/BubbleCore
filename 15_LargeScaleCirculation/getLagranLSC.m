function [lagrandLSC] = getLagranLSC(cLSC,aLSC)
    numLSC = numel(cLSC);
    lagrandLSC(2*numLSC,1) = struct('head',0,'rear',0,'headIdx',0,'rearIdx',0,'direction','a','idxEulerLSC',0);
    if cLSC(1).headIdx < aLSC(1).headIdx
        lscCounter = 0;
        for i = 1:numLSC
            lscCounter = lscCounter + 1;
            lagrandLSC(lscCounter).head = cLSC(i).head;
            lagrandLSC(lscCounter).headIdx = cLSC(i).headIdx;
            lagrandLSC(lscCounter).rear = cLSC(i).rear;
            lagrandLSC(lscCounter).rearIdx = cLSC(i).rearIdx;
            lagrandLSC(lscCounter).direction = 'c';
            lagrandLSC(lscCounter).idxEulerLSC = i;
            lscCounter = lscCounter + 1;
            lagrandLSC(lscCounter).head = aLSC(i).head;
            lagrandLSC(lscCounter).headIdx = aLSC(i).headIdx;
            lagrandLSC(lscCounter).rear = aLSC(i).rear;
            lagrandLSC(lscCounter).rearIdx = aLSC(i).rearIdx;
            lagrandLSC(lscCounter).direction = 'a';
            lagrandLSC(lscCounter).idxEulerLSC = i;
        end
    else
        lscCounter = 0;
        for i = 1:numLSC
            lscCounter = lscCounter + 1;
            lagrandLSC(lscCounter).head = aLSC(i).head;
            lagrandLSC(lscCounter).headIdx = aLSC(i).headIdx;
            lagrandLSC(lscCounter).rear = aLSC(i).rear;
            lagrandLSC(lscCounter).rearIdx = aLSC(i).rearIdx;
            lagrandLSC(lscCounter).direction = 'a';
            lagrandLSC(lscCounter).idxEulerLSC = i;
            lscCounter = lscCounter + 1;
            lagrandLSC(lscCounter).head = cLSC(i).head;
            lagrandLSC(lscCounter).headIdx = cLSC(i).headIdx;
            lagrandLSC(lscCounter).rear = cLSC(i).rear;
            lagrandLSC(lscCounter).rearIdx = cLSC(i).rearIdx;
            lagrandLSC(lscCounter).direction = 'c';
            lagrandLSC(lscCounter).idxEulerLSC = i;
        end
    end
end

