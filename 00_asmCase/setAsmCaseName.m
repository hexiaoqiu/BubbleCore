function [caseName] = setAsmCaseName(Ra,Pr,invRo,Delta,W)
    RaStr = num2str(Ra,'%g');
    PrStr = num2str(Pr,'%g');
    invRoStr = num2str(invRo,'%g');
    DeltaStr = num2str(Delta,'%g');
    WStr = num2str(W,'%g');
    caseName = append('Ra_',RaStr,'_Pr_',PrStr,'_invRo_',invRoStr,'_Delta_',DeltaStr,'_W_',WStr);
end

