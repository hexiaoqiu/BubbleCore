function [tmp] = sphParGetTmp(n1,n2,iTime,rootFileNameTmp,caseDir)
    
    tmpFileName = [rootFileNameTmp,num2str(iTime,'%d'),'.bin'];
    tmpFilePath = fullfile(caseDir,'org',tmpFileName);
    tmpFile = fopen(tmpFilePath,'r');

    tmp = fread(tmpFile, [n2,n1], 'double');
    fclose(tmpFile);

end

