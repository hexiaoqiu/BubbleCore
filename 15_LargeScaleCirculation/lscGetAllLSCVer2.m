function [cLSC,aLSC,numLSC] = lscGetAllLSCVer2(x,signal,relaxation)

    [interval] = lscFindInterval(x,signal);
    [intervalEffect] = lscFilterIntervalVer2(interval,signal,relaxation);
    [intervalEffect] = lscIntervalReConnect(x,intervalEffect);
    [head,rear] = lscFindHearRear(x,intervalEffect);
    [cLSC,aLSC] = lscLocate(head,rear);
    numLSC = numel(cLSC);

end