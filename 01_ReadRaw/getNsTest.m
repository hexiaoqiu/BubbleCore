function [time, NRJ, ENS, TEN, ANGM] = getNsTest(caseRawDir)

    fileName = 'nstest.dat';
    % enter the folder contains the case's data
    fileLocation = fullfile(caseRawDir,fileName);
    % Open File
    fid = fopen(fileLocation);
    % Compute Line number
    row=0;
    while ~feof(fid) % 
        [~]=fgets(fid); % 
        row=row+1; % 
    end
    fclose(fid); % 
    % disp(['The nstest have ', num2str(row), ' lines ~!']);

    % allocate the quantity
    capacity = row - 3;
    % read the head line
    fid = fopen(fileLocation);
    data = textscan(fid, '%f', capacity*5, 'HeaderLines', 3);
    fclose(fid);

    time = data{1}(1:5:end-5+1);
    NRJ = data{1}(2:5:end-5+2);
    ENS = data{1}(3:5:end-5+3);
    TEN = data{1}(4:5:end-5+4);
    ANGM = data{1}(5:5:end-5+5);
    
end
