function result = convertNssaveDatToBin(subCaseDir,options)
%CONVERTNSSAVEDATTOBIN Convert one legacy text subcase to nssave.bin.
%   RESULT = CONVERTNSSAVEDATTOBIN(SUBCASEDIR,OPTIONS) preserves the
%   original nssave.dat, writes through a temporary file, and publishes
%   nssave.bin only after the complete snapshots pass validation.

%   OPTIONS fields:
%       overwriteExistingBin  Replace an existing nssave.bin (false).
%       validateAfterConversion  Compare first/middle/last fields (true).
%       batchSize             Number of snapshots read per batch (16).
%       verbose               Print progress information (true).

    narginchk(1,2);
    if nargin < 2 || isempty(options)
        options = struct();
    end
    options = normalizeOptions(options);
    subCaseDir = normalizeDirectory(subCaseDir);
    sourceFile = fullfile(subCaseDir,'nssave.dat');
    outputFile = fullfile(subCaseDir,'nssave.bin');
    if ~isfile(sourceFile)
        error('convertNssaveDatToBin:SourceNotFound', ...
            'Legacy source file does not exist: %s.',sourceFile);
    end
    if isfile(outputFile) && ~options.overwriteExistingBin
        error('convertNssaveDatToBin:OutputExists', ...
            ['Output already exists: %s. Set overwriteExistingBin=true ' ...
             'only after confirming that replacement is intended.'],outputFile);
    end

    startClock = tic;
    sourceInfo = dir(sourceFile);
    dns = buildTextDns(subCaseDir);
    numSnapshots = dns.totalN;
    if numSnapshots < 1
        error('convertNssaveDatToBin:NoCompleteSnapshots', ...
            'No complete instantaneous snapshot was found in %s.',sourceFile);
    end
    bytesPerSnapshot = getBytesPerSnapshot(dns.n1(1),dns.n2(1));
    sampleIndices = unique([1,ceil(numSnapshots/2),numSnapshots]);
    expectedSamples = cell(numel(sampleIndices),1);

    temporaryFile = [tempname(subCaseDir),'.nssave.bin.converting'];
    cleanupObject = onCleanup(@() cleanupTemporaryFile(temporaryFile));
    outputId = fopen(temporaryFile,'w','n');
    if outputId < 0
        error('convertNssaveDatToBin:OpenOutputFailed', ...
            'Unable to create temporary output in %s.',subCaseDir);
    end
    closeOutput = onCleanup(@() closeIfOpen(outputId));

    nextFrame = 1;
    try
        while nextFrame <= numSnapshots
            numThisBatch = min(options.batchSize,numSnapshots-nextFrame+1);
            [dns,batch] = asmReadFieldBatch(dns,dns.time(1),dns.time(end), ...
                numThisBatch,{'tmp','u2d','v2d','prs'});
            if batch.numSteps == 0
                error('convertNssaveDatToBin:UnexpectedEndOfSource', ...
                    'Text reader stopped after %d of %d snapshots.', ...
                    nextFrame-1,numSnapshots);
            end
            for idxBatch = 1:batch.numSteps
                idxGlobal = batch.idxGlobal(idxBatch);
                writeSnapshot(outputId,dns,batch,idxBatch);
                idxSample = find(sampleIndices==idxGlobal,1);
                if ~isempty(idxSample)
                    expectedSamples{idxSample} = getBatchFields(batch,idxBatch);
                end
            end
            nextFrame = nextFrame + batch.numSteps;
        end
        dns = asmFinishRead(dns);
    catch exception
        if dns.readNowSubCaseIdx ~= -1
            dns = asmFinishRead(dns); %#ok<NASGU>
        end
        rethrow(exception)
    end

    fclose(outputId);
    clear closeOutput
    temporaryInfo = dir(temporaryFile);
    expectedBytes = numSnapshots*bytesPerSnapshot;
    if temporaryInfo.bytes ~= expectedBytes
        error('convertNssaveDatToBin:UnexpectedFileSize', ...
            'Expected %d bytes but wrote %d bytes.', ...
            expectedBytes,temporaryInfo.bytes);
    end

    validationPassed = true;
    if options.validateAfterConversion
        validationPassed = validateSamples(temporaryFile,dns,sampleIndices, ...
            expectedSamples,bytesPerSnapshot);
        if ~validationPassed
            error('convertNssaveDatToBin:ValidationFailed', ...
                'Converted binary snapshots differ from the text source.');
        end
    end

    publishOutput(temporaryFile,outputFile,options.overwriteExistingBin);
    clear cleanupObject
    outputInfo = dir(outputFile);

    result = struct();
    result.success = true;
    result.subCaseDir = subCaseDir;
    result.sourceFile = sourceFile;
    result.outputFile = outputFile;
    result.numSnapshotsConverted = numSnapshots;
    result.numSnapshotsPlanned = dns.maxNPlan(1);
    result.sourceBytes = sourceInfo.bytes;
    result.outputBytes = outputInfo.bytes;
    result.bytesPerSnapshot = bytesPerSnapshot;
    result.validationPassed = validationPassed;
    result.sampleIndicesValidated = sampleIndices;
    result.originalSourcePreserved = isfile(sourceFile);
    result.elapsedTime = toc(startClock);
    result.createdAt = datetime('now');
    if options.verbose
        fprintf('Converted %d snapshots: %s -> %s\n', ...
            numSnapshots,sourceFile,outputFile);
        fprintf('Validation passed: %d; elapsed time: %.3f s\n', ...
            validationPassed,result.elapsedTime);
    end
end

function dns = buildTextDns(subCaseDir)
    [Ra,~,~,~,~,~,xLeft,xRight,yBottom,yTop,n1,n2,maxNPlan,~,dtSave] = ...
        getCoefs(subCaseDir);
    numSnapshots = asmGetRealMaxNTxt(subCaseDir);
    [x2dS,y2dS,x2dU,y2dU,x2dV,y2dV] = ...
        buildMeshOrg(xLeft,xRight,yTop,yBottom,n1,n2);
    dns = struct();
    dns.A = (xRight-xLeft)/(yTop-yBottom);
    dns.realRa = Ra;
    dns.x2dGauche = xLeft;
    dns.x2dDroit = xRight;
    dns.y2dBas = yBottom;
    dns.y2dHaut = yTop;
    dns.n1 = n1;
    dns.n2 = n2;
    dns.maxNPlan = maxNPlan;
    dns.dtSave = dtSave;
    dns.numSubCase = 1;
    dns.subCaseDir = {subCaseDir};
    dns.x2dS = {x2dS};
    dns.y2dS = {y2dS};
    dns.x2dU = {x2dU};
    dns.y2dU = {y2dU};
    dns.x2dV = {x2dV};
    dns.y2dV = {y2dV};
    dns.type = {'txt'};
    dns.dataFileName = {'nssave.dat'};
    dns.maxN = numSnapshots;
    dns.totalN = numSnapshots;
    dns.globalFrameStart = 1;
    dns.globalFrameEnd = numSnapshots;
    dns.globalFrameRange = {1:numSnapshots};
    dns.globalFrameSubCase = ones(numSnapshots,1);
    dns.globalFrameLocal = (1:numSnapshots)';
    dns.timeLocal = {dns.dtSave(1)*(1:numSnapshots)'};
    dns.time = dns.timeLocal{1};
    dns.startTime = dns.time(1);
    dns.endTime = dns.time(end);
    dns.dnsBeginTime = dns.time(1);
    dns.dnsStopTime = dns.time(end);
    dns.lastReadTime = -1;
    dns.nextReadTime = -1;
    dns.lastReadGlobalFrame = 0;
    dns.nextReadGlobalFrame = 1;
    dns.readNowSubCaseIdx = -1;
    dns.readNowFileID = -1;
    dns.readCounter = 0;
end

function writeSnapshot(fileId,dns,batch,idxBatch)
    fwriteChecked(fileId,[dns.x2dGauche,dns.x2dDroit, ...
        dns.y2dBas,dns.y2dHaut],'double',4);
    fwriteChecked(fileId,[batch.n1(idxBatch),batch.n2(idxBatch)],'int32',2);
    fwriteChecked(fileId,batch.tmpOrg{idxBatch}.','double',numel(batch.tmpOrg{idxBatch}));
    fwriteChecked(fileId,batch.u2dOrg{idxBatch}.','double',numel(batch.u2dOrg{idxBatch}));
    fwriteChecked(fileId,batch.v2dOrg{idxBatch}.','double',numel(batch.v2dOrg{idxBatch}));
    fwriteChecked(fileId,batch.prsOrg{idxBatch}.','double',numel(batch.prsOrg{idxBatch}));
end

function fwriteChecked(fileId,value,precision,expectedCount)
    count = fwrite(fileId,value,precision);
    if count ~= expectedCount
        error('convertNssaveDatToBin:WriteFailed', ...
            'Expected to write %d values but wrote %d.',expectedCount,count);
    end
end

function fields = getBatchFields(batch,idxBatch)
    fields = {batch.tmpOrg{idxBatch},batch.u2dOrg{idxBatch}, ...
        batch.v2dOrg{idxBatch},batch.prsOrg{idxBatch}};
end

function passed = validateSamples(fileName,dns,sampleIndices, ...
        expectedSamples,bytesPerSnapshot)
    fileId = fopen(fileName,'r','n');
    if fileId < 0
        error('convertNssaveDatToBin:ValidationOpenFailed', ...
            'Unable to open temporary output for validation.');
    end
    cleanupObject = onCleanup(@() fclose(fileId));
    passed = true;
    for idxSample = 1:numel(sampleIndices)
        offset = (sampleIndices(idxSample)-1)*bytesPerSnapshot;
        if fseek(fileId,offset,'bof') ~= 0
            passed = false;
            break
        end
        actual = readSnapshot(fileId,dns);
        expected = expectedSamples{idxSample};
        passed = passed && all(cellfun(@isequal,actual,expected));
        if ~passed
            break
        end
    end
    clear cleanupObject
end

function fields = readSnapshot(fileId,dns)
    headerDouble = fread(fileId,4,'double')';
    headerInt = fread(fileId,2,'int32')';
    expectedDouble = [dns.x2dGauche,dns.x2dDroit,dns.y2dBas,dns.y2dHaut];
    if ~isequal(headerDouble,expectedDouble) || ...
            ~isequal(headerInt,double([dns.n1(1),dns.n2(1)]))
        error('convertNssaveDatToBin:InvalidHeader', ...
            'A converted snapshot header is invalid.');
    end
    n1 = dns.n1(1);
    n2 = dns.n2(1);
    fields = cell(1,4);
    fields{1} = fread(fileId,[n1,n2],'double')';
    fields{2} = fread(fileId,[n1+1,n2],'double')';
    fields{3} = fread(fileId,[n1,n2+1],'double')';
    fields{4} = fread(fileId,[n1,n2],'double')';
end

function bytes = getBytesPerSnapshot(n1,n2)
    numValues = n1*n2+(n1+1)*n2+n1*(n2+1)+n1*n2;
    bytes = 4*8+2*4+numValues*8;
end

function options = normalizeOptions(options)
    if ~isstruct(options) || ~isscalar(options)
        error('convertNssaveDatToBin:InvalidOptions', ...
            'options must be a scalar structure.');
    end
    defaults = struct('overwriteExistingBin',false, ...
        'validateAfterConversion',true,'batchSize',16,'verbose',true);
    names = fieldnames(options);
    unknown = setdiff(names,fieldnames(defaults));
    if ~isempty(unknown)
        error('convertNssaveDatToBin:UnknownOption', ...
            'Unknown option: %s.',unknown{1});
    end
    defaultNames = fieldnames(defaults);
    for idx = 1:numel(defaultNames)
        name = defaultNames{idx};
        if ~isfield(options,name)
            options.(name) = defaults.(name);
        end
    end
    validateattributes(options.overwriteExistingBin,{'logical'}, ...
        {'scalar'},mfilename,'options.overwriteExistingBin');
    validateattributes(options.validateAfterConversion,{'logical'}, ...
        {'scalar'},mfilename,'options.validateAfterConversion');
    validateattributes(options.batchSize,{'numeric'}, ...
        {'scalar','integer','positive','finite'},mfilename,'options.batchSize');
    validateattributes(options.verbose,{'logical'}, ...
        {'scalar'},mfilename,'options.verbose');
end

function directory = normalizeDirectory(directory)
    if ~((ischar(directory) && isrow(directory)) || ...
            (isstring(directory) && isscalar(directory) && ~ismissing(directory)))
        error('convertNssaveDatToBin:InvalidDirectory', ...
            'subCaseDir must be a text scalar.');
    end
    directory = char(directory);
    if ~isfolder(directory)
        error('convertNssaveDatToBin:DirectoryNotFound', ...
            'Subcase directory does not exist: %s.',directory);
    end
end

function cleanupTemporaryFile(fileName)
    if isfile(fileName)
        delete(fileName);
    end
end

function publishOutput(temporaryFile,outputFile,overwriteExisting)
    backupFile = '';
    if isfile(outputFile)
        if ~overwriteExisting
            error('convertNssaveDatToBin:OutputExists', ...
                'Output appeared during conversion: %s.',outputFile);
        end
        backupFile = [tempname(fileparts(outputFile)),'.nssave.bin.backup'];
        [backupSucceeded,message] = movefile(outputFile,backupFile);
        if ~backupSucceeded
            error('convertNssaveDatToBin:BackupFailed', ...
                'Unable to protect the existing output: %s.',message);
        end
    end
    [moveSucceeded,message] = movefile(temporaryFile,outputFile);
    if ~moveSucceeded
        if ~isempty(backupFile) && isfile(backupFile)
            movefile(backupFile,outputFile);
        end
        error('convertNssaveDatToBin:PublishFailed', ...
            'Unable to publish nssave.bin: %s.',message);
    end
    if ~isempty(backupFile) && isfile(backupFile)
        delete(backupFile);
    end
end

function closeIfOpen(fileId)
    try
        fclose(fileId);
    catch
        % The file was already closed explicitly after a successful write.
    end
end
