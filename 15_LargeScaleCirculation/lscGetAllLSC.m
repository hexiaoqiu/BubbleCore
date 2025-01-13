function [cLSC,aLSC,numLSC] = lscGetAllLSC(x,signal,UxMean,relaxation)

    [interval] = lscFindInterval(x,signal);
    [intervalEffect] = lscFilterIntervalVer2(interval,signal,relaxation);
    [intervalEffect] = lscIntervalReConnect(x,intervalEffect);
    [head,rear] = lscFindHearRearVer3(x,intervalEffect,UxMean);
    [cLSC,aLSC] = lscLocate(head,rear);
    numLSC = numel(cLSC);

end