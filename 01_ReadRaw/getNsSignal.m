function [signal] = getNsSignal(caseRawDir)

    fileName = 'nssign.dat';
    % enter the folder contains the case's data
    fileLocation = fullfile(caseRawDir,fileName);
    % Open File
    fid = fopen(fileLocation);
    % Compute Line number
    row=0;
    while ~feof(fid) % òØÂê¶ËØªñà∞Êñá‰ª∂ÁìÂ∞?
        [~]=fgets(fid); % àñ?Öfgetl
        row=row+1; % Ë°åï∞Á¥Øä
    end
    fclose(fid); % äó∂ÂÖ≥Èó≠Êñá‰ª∂ÊòØ‰∏™Â•Ω‰°°É?

    capacity = (row-4)*31;
    fid = fopen(fileLocation);
    data = textscan(fid, '%f', capacity, 'HeaderLines', 4);
    fclose(fid);
    collectInterval = 32;

    signal.time = data{1}(1:collectInterval:end-collectInterval+1);
    signal.P1 = data{1}(2:collectInterval:end-collectInterval+2);
    signal.P2 = data{1}(3:collectInterval:end-collectInterval+3);
    signal.P3 = data{1}(4:collectInterval:end-collectInterval+4);
    signal.P4 = data{1}(5:collectInterval:end-collectInterval+5);
    signal.P5 = data{1}(6:collectInterval:end-collectInterval+6);
    signal.P6 = data{1}(7:collectInterval:end-collectInterval+7);
    signal.T1 = data{1}(8:collectInterval:end-collectInterval+8);
    signal.T2 = data{1}(9:collectInterval:end-collectInterval+9);
    signal.T3 = data{1}(10:collectInterval:end-collectInterval+10);
    signal.T4 = data{1}(11:collectInterval:end-collectInterval+11);
    signal.T5 = data{1}(12:collectInterval:end-collectInterval+12);
    signal.T6 = data{1}(13:collectInterval:end-collectInterval+13);
    signal.U1 = data{1}(14:collectInterval:end-collectInterval+14);
    signal.U2 = data{1}(15:collectInterval:end-collectInterval+15);
    signal.U3 = data{1}(16:collectInterval:end-collectInterval+16);
    signal.U4 = data{1}(17:collectInterval:end-collectInterval+17);
    signal.U5 = data{1}(18:collectInterval:end-collectInterval+18);
    signal.U6 = data{1}(19:collectInterval:end-collectInterval+19);
    signal.V1 = data{1}(20:collectInterval:end-collectInterval+20);
    signal.V2 = data{1}(21:collectInterval:end-collectInterval+21);
    signal.V3 = data{1}(22:collectInterval:end-collectInterval+22);
    signal.V4 = data{1}(23:collectInterval:end-collectInterval+23);
    signal.V5 = data{1}(24:collectInterval:end-collectInterval+24);
    signal.V6 = data{1}(25:collectInterval:end-collectInterval+25);
    signal.W1 = data{1}(26:collectInterval:end-collectInterval+26);
    signal.W2 = data{1}(27:collectInterval:end-collectInterval+27);
    signal.W3 = data{1}(28:collectInterval:end-collectInterval+28);
    signal.W4 = data{1}(29:collectInterval:end-collectInterval+29);
    signal.W5 = data{1}(30:collectInterval:end-collectInterval+30);
    signal.W6 = data{1}(31:collectInterval:end);

end