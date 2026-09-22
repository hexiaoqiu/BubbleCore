function [realMaxN, snapshotInfo] = asmGetRealMaxNBin(rawCaseDir)
%ASMGETREALMAXNBIN Count usable snapshots in a fixed-record nssave.bin file.
%   The binary format stores every snapshot with the same number of bytes.
%   Therefore, the number of complete records can be obtained directly from
%   the file size without reading every flow-field array.
%
%   REALMAXN is limited by maxN from the subcase parameter file. This keeps
%   legacy time-averaged records appended after the planned instantaneous
%   snapshots out of the DNS time series.

    [~, ~, ~, ~, ~, ~, ...
     x2dGauche, x2dDroit, y2dBas, y2dHaut, ...
     n1, n2, maxNPlan, ~, ~] = getCoefs(rawCaseDir);

    validateattributes(n1,{'numeric'},{'scalar','integer','positive'});
    validateattributes(n2,{'numeric'},{'scalar','integer','positive'});
    validateattributes(maxNPlan,{'numeric'}, ...
        {'scalar','integer','nonnegative'});

    nssaveFile = fullfile(rawCaseDir,'nssave.bin');
    fileInfo = dir(nssaveFile);
    if isempty(fileInfo)
        error('asmGetRealMaxNBin:FileNotFound', ...
            'Cannot find binary DNS data file: %s',nssaveFile);
    end

    headerBytes = 4*8 + 2*4;
    numFieldValues = ...
        n1*n2 + ...
        (n1+1)*n2 + ...
        n1*(n2+1) + ...
        n1*n2;
    snapshotBytes = headerBytes + 8*numFieldValues;

    fileBytes = fileInfo.bytes;
    numStoredSnapshots = floor(fileBytes/snapshotBytes);
    trailingBytes = mod(fileBytes,snapshotBytes);
    realMaxN = min(numStoredSnapshots,maxNPlan);

    snapshotInfo = struct();
    snapshotInfo.filePath = nssaveFile;
    snapshotInfo.fileBytes = fileBytes;
    snapshotInfo.snapshotBytes = snapshotBytes;
    snapshotInfo.numStoredSnapshots = numStoredSnapshots;
    snapshotInfo.numUsableSnapshots = realMaxN;
    snapshotInfo.numPlannedSnapshots = maxNPlan;
    snapshotInfo.numIgnoredSnapshots = ...
        max(0,numStoredSnapshots-maxNPlan);
    snapshotInfo.trailingBytes = trailingBytes;
    snapshotInfo.isFileSizeAligned = trailingBytes == 0;
    snapshotInfo.isHeaderValidated = false;

    if trailingBytes ~= 0
        warning('asmGetRealMaxNBin:IncompleteTrailingRecord', ...
            ['%s contains %d complete snapshots followed by %d extra ' ...
             'bytes. Only complete snapshots will be used.'], ...
            nssaveFile,numStoredSnapshots,trailingBytes);
    end

    if numStoredSnapshots > maxNPlan
        fprintf(['Ignoring %d record(s) after the %d planned ' ...
                 'instantaneous snapshots in %s.\n'], ...
            numStoredSnapshots-maxNPlan,maxNPlan,nssaveFile);
    end

    if realMaxN == 0
        return
    end

    % Only inspect the first and last usable headers. This catches an
    % incorrect grid or record stride without loading any flow-field array.
    fileID = fopen(nssaveFile,'r','n');
    if fileID < 0
        error('asmGetRealMaxNBin:CannotOpenFile', ...
            'Cannot open binary DNS data file: %s',nssaveFile);
    end
    cleanupObject = onCleanup(@() fclose(fileID));

    frameIndices = unique([1,realMaxN]);
    for idxFrame = frameIndices
        byteOffset = (idxFrame-1)*snapshotBytes;
        seekStatus = fseek(fileID,byteOffset,'bof');
        if seekStatus ~= 0
            error('asmGetRealMaxNBin:SeekFailed', ...
                'Cannot seek to snapshot %d in %s.',idxFrame,nssaveFile);
        end

        boundaryValues = fread(fileID,4,'double=>double');
        gridSize = fread(fileID,2,'int32=>double');

        headerIsComplete = ...
            numel(boundaryValues) == 4 && numel(gridSize) == 2;
        headerIsCorrect = headerIsComplete && ...
            isequal(boundaryValues(:), ...
                [x2dGauche;x2dDroit;y2dBas;y2dHaut]) && ...
            isequal(gridSize(:),[n1;n2]);

        if ~headerIsCorrect
            error('asmGetRealMaxNBin:InvalidSnapshotHeader', ...
                ['Snapshot %d in %s has an invalid header. The file ' ...
                 'size alone cannot be trusted for this subcase.'], ...
                idxFrame,nssaveFile);
        end
    end

    snapshotInfo.isHeaderValidated = true;
end
