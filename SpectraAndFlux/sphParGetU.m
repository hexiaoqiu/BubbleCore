function [u] = sphParGetU(n1,n2,iTime,rootFileNameU,caseDir)
    
    uFileName = [rootFileNameU,num2str(iTime,'%d'),'.bin'];
    uFilePath = fullfile(caseDir,'org',uFileName);
    uFile = fopen(uFilePath,'r');

    u = fread(uFile, [n2,n1+1], 'double');
    fclose(uFile);

end


