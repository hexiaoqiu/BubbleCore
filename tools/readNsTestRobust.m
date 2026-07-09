function [time, NRJ, ENS, TEN, ANGM] = readNsTestRobust(subCaseDir)
%READNSTESTROBUST Robustly read nstest file from one subcase directory.
%
% The file is read line by line.
%
% Valid row:
%   at least five numeric values:
%       time NRJ ENS TEN ANGM
%
% Invalid row:
%   empty line
%   comment line
%   fewer than five numeric values
%   NaN / Inf values in the first five columns
%
% This function is designed to tolerate:
%   1. empty files caused by missing flush
%   2. incomplete last line caused by killed process
%   3. partially corrupted lines

    time = [];
    NRJ  = [];
    ENS  = [];
    TEN  = [];
    ANGM = [];

    nsTestFile = findNsTestFile(subCaseDir);

    if isempty(nsTestFile)
        warning('readNsTestRobust:FileNotFound', ...
            'No nstest file found in directory: %s', subCaseDir);
        return;
    end

    fileInfo = dir(nsTestFile);

    if isempty(fileInfo) || fileInfo.bytes == 0
        return;
    end

    fid = fopen(nsTestFile, 'r');

    if fid < 0
        warning('readNsTestRobust:OpenFailed', ...
            'Failed to open nstest file: %s', nsTestFile);
        return;
    end

    dataCell = cell(1024, 1);
    numValidRow = 0;
    numSkippedRow = 0;

    cleanupObj = onCleanup(@() fclose(fid));

    while true
        line = fgetl(fid);

        if ~ischar(line)
            break;
        end

        line = strtrim(line);

        if isempty(line)
            numSkippedRow = numSkippedRow + 1;
            continue;
        end

        if startsWith(line, '#') || startsWith(line, '%')
            numSkippedRow = numSkippedRow + 1;
            continue;
        end

        values = sscanf(line, '%f');

        if numel(values) < 5
            numSkippedRow = numSkippedRow + 1;
            continue;
        end

        values = values(1:5);

        if any(~isfinite(values))
            numSkippedRow = numSkippedRow + 1;
            continue;
        end

        numValidRow = numValidRow + 1;

        if numValidRow > numel(dataCell)
            dataCell = [dataCell; cell(numel(dataCell), 1)]; %#ok<AGROW>
        end

        dataCell{numValidRow} = values(:).';
    end

    if numValidRow == 0
        return;
    end

    data = cell2mat(dataCell(1:numValidRow));

    time = data(:, 1);
    NRJ  = data(:, 2);
    ENS  = data(:, 3);
    TEN  = data(:, 4);
    ANGM = data(:, 5);

    if numSkippedRow > 0
        warning('readNsTestRobust:SkippedRows', ...
            'Skipped %d invalid nstest rows in file: %s', ...
            numSkippedRow, nsTestFile);
    end

end

function nsTestFile = findNsTestFile(subCaseDir)
%FINDNSTESTFILE Find nstest file in a subcase directory.
%
% Add candidate names here if your code uses another exact filename.

    nsTestFile = '';

    candidateNames = { ...
        'nstest', ...
        'nstest.dat', ...
        'nsTest', ...
        'nsTest.dat', ...
        'NsTest', ...
        'NsTest.dat', ...
        'NSTEST', ...
        'NSTEST.dat'};

    for i = 1:numel(candidateNames)
        thisFile = fullfile(subCaseDir, candidateNames{i});

        if exist(thisFile, 'file') == 2
            nsTestFile = thisFile;
            return;
        end
    end

    % Fallback: search any file name containing "nstest", case-insensitive.
    fileList = dir(subCaseDir);

    for i = 1:numel(fileList)
        if fileList(i).isdir
            continue;
        end

        fileNameLower = lower(fileList(i).name);

        if contains(fileNameLower, 'nstest')
            nsTestFile = fullfile(fileList(i).folder, fileList(i).name);
            return;
        end
    end

end

