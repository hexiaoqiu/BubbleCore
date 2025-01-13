function [signal] = obtainNsSignal(lightCase)
    nsSignalDir = fullfile(lightCase.path,'org','nsSignal.bin');
    fileID = fopen(nsSignalDir,'r');
    if fileID > 2
        nSignal = fread(fileID,1,'double');
        signal.time = fread(fileID,[nSignal,1],'double');
        signal.P1 = fread(fileID,[nSignal,1],'double');
        signal.P2 = fread(fileID,[nSignal,1],'double');
        signal.P3 = fread(fileID,[nSignal,1],'double');
        signal.P4 = fread(fileID,[nSignal,1],'double');
        signal.P5 = fread(fileID,[nSignal,1],'double');
        signal.P6 = fread(fileID,[nSignal,1],'double');
        signal.T1 = fread(fileID,[nSignal,1],'double');
        signal.T2 = fread(fileID,[nSignal,1],'double');
        signal.T3 = fread(fileID,[nSignal,1],'double');
        signal.T4 = fread(fileID,[nSignal,1],'double');
        signal.T5 = fread(fileID,[nSignal,1],'double');
        signal.T6 = fread(fileID,[nSignal,1],'double');
        signal.U1 = fread(fileID,[nSignal,1],'double');
        signal.U2 = fread(fileID,[nSignal,1],'double');
        signal.U3 = fread(fileID,[nSignal,1],'double');
        signal.U4 = fread(fileID,[nSignal,1],'double');
        signal.U5 = fread(fileID,[nSignal,1],'double');
        signal.U6 = fread(fileID,[nSignal,1],'double');
        signal.V1 = fread(fileID,[nSignal,1],'double');
        signal.V2 = fread(fileID,[nSignal,1],'double');
        signal.V3 = fread(fileID,[nSignal,1],'double');
        signal.V4 = fread(fileID,[nSignal,1],'double');
        signal.V5 = fread(fileID,[nSignal,1],'double');
        signal.V6 = fread(fileID,[nSignal,1],'double');
        signal.W1 = fread(fileID,[nSignal,1],'double');
        signal.W2 = fread(fileID,[nSignal,1],'double');
        signal.W3 = fread(fileID,[nSignal,1],'double');
        signal.W4 = fread(fileID,[nSignal,1],'double');
        signal.W5 = fread(fileID,[nSignal,1],'double');
        signal.W6 = fread(fileID,[nSignal,1],'double');
        fclose(fileID);
    end
end