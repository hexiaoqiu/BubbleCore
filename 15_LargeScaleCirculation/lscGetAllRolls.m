function [cLSC,aLSC,numLSC] = lscGetAllRolls(uPhi)
    
    Ux = flipud(uPhi);
    [nTheta,nPhi] = size(uPhi);
    x = linspace(0,1,nPhi);
    idxMiddle = round(nTheta/2);
    UxHotSide = mean(Ux(1:idxMiddle,:),1);
    UxHotSide = UxHotSide./max(abs(UxHotSide),[],'all');
    UxColdSide = mean(Ux(idxMiddle:end,:),1);
    UxColdSide = UxColdSide./max(abs(UxColdSide),[],'all');
    [cLSC,aLSC,numLSC] = lscGetAllLSCRelease(x,UxColdSide,UxHotSide);

end
