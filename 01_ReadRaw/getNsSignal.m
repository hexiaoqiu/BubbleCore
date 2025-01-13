function [signal] = getNsSignal(caseRawDir)

    fileName = 'nssign.dat';
    % enter the folder contains the case's data
    fileLocation = fullfile(caseRawDir,fileName);
    % Open File
    fid = fopen(fileLocation);
    % Compute Line number
    row=0;
    while ~feof(fid) % 是否读取到文件结�?
        [~]=fgets(fid); % 或�?�fgetl
        row=row+1; % 行数累加
    end
    fclose(fid); % 及时关闭文件是个好习�?

    capacity = (row-4)*31;
    fid = fopen(fileLocation);
    data = textscan(fid, '%f', capacity, 'HeaderLines', 4);
    fclose(fid);
    signal.time = data{1}(1:31:end-31+1);
    signal.P1 = data{1}(2:31:end-31+2);
    signal.P2 = data{1}(3:31:end-31+3);
    signal.P3 = data{1}(4:31:end-31+4);
    signal.P4 = data{1}(5:31:end-31+5);
    signal.P5 = data{1}(6:31:end-31+6);
    signal.P6 = data{1}(7:31:end-31+7);
    signal.T1 = data{1}(8:31:end-31+8);
    signal.T2 = data{1}(9:31:end-31+9);
    signal.T3 = data{1}(10:31:end-31+10);
    signal.T4 = data{1}(11:31:end-31+11);
    signal.T5 = data{1}(12:31:end-31+12);
    signal.T6 = data{1}(13:31:end-31+13);
    signal.U1 = data{1}(14:31:end-31+14);
    signal.U2 = data{1}(15:31:end-31+15);
    signal.U3 = data{1}(16:31:end-31+16);
    signal.U4 = data{1}(17:31:end-31+17);
    signal.U5 = data{1}(18:31:end-31+18);
    signal.U6 = data{1}(19:31:end-31+19);
    signal.V1 = data{1}(20:31:end-31+20);
    signal.V2 = data{1}(21:31:end-31+21);
    signal.V3 = data{1}(22:31:end-31+22);
    signal.V4 = data{1}(23:31:end-31+23);
    signal.V5 = data{1}(24:31:end-31+24);
    signal.V6 = data{1}(25:31:end-31+25);
    signal.W1 = data{1}(26:31:end-31+26);
    signal.W2 = data{1}(27:31:end-31+27);
    signal.W3 = data{1}(28:31:end-31+28);
    signal.W4 = data{1}(29:31:end-31+29);
    signal.W5 = data{1}(30:31:end-31+30);
    signal.W6 = data{1}(31:31:end-31+31);

end