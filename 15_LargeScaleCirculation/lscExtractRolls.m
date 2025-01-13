function [cLSC,aLSC,numLSC] = lscExtractRolls(uPhi)
    [nTheta,nPhi] = size(uPhi);
    Ux = flipud(uPhi);
    x = linspace(0,1,nPhi);
    idxMiddle = round(nTheta/2);
    UxHotSide = mean(Ux(1:idxMiddle,:),1);
    UxHotSide = UxHotSide./max(UxHotSide,[],'all');
    UxColdSide = mean(Ux(idxMiddle:end,:),1);
    UxColdSide = UxColdSide./max(UxColdSide,[],'all');
    [cLSC,aLSC,numLSC] = lscGetAllLSCVer5(x,UxColdSide,UxHotSide);
end