function [v] = sphParGetV(n1,n2,iTime,rootFileNameV,caseDir)

    vFileName = [rootFileNameV,num2str(iTime,'%d'),'.bin'];
    vFilePath = fullfile(caseDir,'org',vFileName);
    vFile = fopen(vFilePath,'r');

    v = fread(vFile, [n2+1,n1], 'double');
    fclose(vFile);

end
