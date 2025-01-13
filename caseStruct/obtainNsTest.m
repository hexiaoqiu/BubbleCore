function  [timeTest,NRJ,ENS,TEN,ANGM] = obtainNsTest(lightCase)

    nsTestDir = fullfile(lightCase.path,'org','nsTest.bin');
    fileID = fopen(nsTestDir,'r');
    if fileID > 2
        nTest = fread(fileID,1,'double');
        timeTest = fread(fileID,[nTest,1],'double');
        NRJ = fread(fileID,[nTest,1],'double');
        ENS = fread(fileID,[nTest,1],'double');
        TEN = fread(fileID,[nTest,1],'double');
        ANGM = fread(fileID,[nTest,1],'double');
        fclose(fileID);
    end
    
end