function report = convertDNSNssaveDatToBin(dns)
%CONVERTDNSNSSAVEDATTOBIN Convert all legacy text subcases in one DNS.
%   REPORT = CONVERTDNSNSSAVEDATTOBIN(DNS) inspects every subcase recorded
%   in DNS. Subcases currently identified as nssave.dat text data are
%   converted with CONVERTNSSAVEDATTOBIN and are always validated after
%   conversion. Existing binary subcases are left unchanged.
%
%   The source nssave.dat files are preserved. Rebuild DNS with GETDNS
%   after conversion so its type, file-name, and snapshot metadata describe
%   the newly created nssave.bin files.

    narginchk(1,1);
    validateDns(dns);

    startClock = tic;
    numSubCases = numel(dns.subCaseDir);
    emptyItem = struct('subCaseIndex',[], ...
        'subCaseDir','', ...
        'detectedType','', ...
        'dataFileName','', ...
        'status','', ...
        'message','', ...
        'conversionResult',[]);
    items = repmat(emptyItem,1,numSubCases);
    conversionOptions = struct('validateAfterConversion',true);

    numLegacyTextSubCases = 0;
    numConverted = 0;
    numSkipped = 0;

    for idxSubCase = 1:numSubCases
        subCaseDir = char(dns.subCaseDir{idxSubCase});
        detectedType = char(dns.type{idxSubCase});
        dataFileName = char(dns.dataFileName{idxSubCase});
        items(idxSubCase).subCaseIndex = idxSubCase;
        items(idxSubCase).subCaseDir = subCaseDir;
        items(idxSubCase).detectedType = detectedType;
        items(idxSubCase).dataFileName = dataFileName;

        isLegacyText = strcmpi(strtrim(detectedType),'txt') && ...
            strcmpi(strtrim(dataFileName),'nssave.dat');
        if ~isLegacyText
            items(idxSubCase).status = 'skipped';
            items(idxSubCase).message = ...
                'Subcase is not identified as legacy nssave.dat data.';
            numSkipped = numSkipped+1;
            continue
        end

        numLegacyTextSubCases = numLegacyTextSubCases+1;
        sourceFile = fullfile(subCaseDir,'nssave.dat');
        outputFile = fullfile(subCaseDir,'nssave.bin');
        if ~isfile(sourceFile)
            error('convertDNSNssaveDatToBin:MissingTextSource', ...
                ['DNS identifies subcase %d as text data, but the source ' ...
                 'file does not exist: %s.'],idxSubCase,sourceFile);
        end
        if isfile(outputFile)
            items(idxSubCase).status = 'skipped';
            items(idxSubCase).message = ...
                'nssave.bin already exists; no file was overwritten.';
            numSkipped = numSkipped+1;
            continue
        end

        fprintf('Converting legacy subcase %d of %d: %s\n', ...
            idxSubCase,numSubCases,subCaseDir);
        try
            conversionResult = convertNssaveDatToBin( ...
                subCaseDir,conversionOptions);
        catch exception
            conversionError = MException( ...
                'convertDNSNssaveDatToBin:SubCaseConversionFailed', ...
                'Conversion failed for subcase %d: %s.', ...
                idxSubCase,subCaseDir);
            conversionError = addCause(conversionError,exception);
            throw(conversionError)
        end
        items(idxSubCase).status = 'converted';
        items(idxSubCase).message = ...
            'Converted to nssave.bin and validated successfully.';
        items(idxSubCase).conversionResult = conversionResult;
        numConverted = numConverted+1;
    end

    report = struct();
    report.success = true;
    report.numSubCases = numSubCases;
    report.numLegacyTextSubCases = numLegacyTextSubCases;
    report.numConverted = numConverted;
    report.numSkipped = numSkipped;
    report.validationRequired = true;
    report.sourceFilesPreserved = true;
    report.requiresDnsRefresh = numConverted > 0;
    report.items = items;
    report.elapsedTime = toc(startClock);
    report.createdAt = datetime('now');

    fprintf(['DNS conversion complete: %d converted, %d skipped, ' ...
        '%d total subcases.\n'],numConverted,numSkipped,numSubCases);
    if report.requiresDnsRefresh
        fprintf('Rebuild dns with getDNS before reading the converted data.\n');
    end
end

function validateDns(dns)
    if ~isstruct(dns) || ~isscalar(dns)
        error('convertDNSNssaveDatToBin:InvalidDns', ...
            'dns must be a scalar structure.');
    end
    requiredFields = {'subCaseDir','type','dataFileName'};
    for idxField = 1:numel(requiredFields)
        fieldName = requiredFields{idxField};
        if ~isfield(dns,fieldName)
            error('convertDNSNssaveDatToBin:MissingDnsField', ...
                'dns is missing the required field: %s.',fieldName);
        end
        if ~iscell(dns.(fieldName))
            error('convertDNSNssaveDatToBin:InvalidDnsField', ...
                'dns.%s must be a cell array.',fieldName);
        end
    end

    numSubCases = numel(dns.subCaseDir);
    if numSubCases < 1
        error('convertDNSNssaveDatToBin:EmptyDns', ...
            'dns does not contain any subcase.');
    end
    if numel(dns.type) ~= numSubCases || ...
            numel(dns.dataFileName) ~= numSubCases
        error('convertDNSNssaveDatToBin:InconsistentDns', ...
            ['dns.subCaseDir, dns.type, and dns.dataFileName must contain ' ...
             'the same number of elements.']);
    end
    if isfield(dns,'numSubCase') && ...
            (~isscalar(dns.numSubCase) || dns.numSubCase ~= numSubCases)
        error('convertDNSNssaveDatToBin:InconsistentDns', ...
            'dns.numSubCase does not match dns.subCaseDir.');
    end

    for idxSubCase = 1:numSubCases
        validateTextScalar(dns.subCaseDir{idxSubCase}, ...
            sprintf('dns.subCaseDir{%d}',idxSubCase));
        validateTextScalar(dns.type{idxSubCase}, ...
            sprintf('dns.type{%d}',idxSubCase));
        validateTextScalar(dns.dataFileName{idxSubCase}, ...
            sprintf('dns.dataFileName{%d}',idxSubCase));
        if ~isfolder(char(dns.subCaseDir{idxSubCase}))
            error('convertDNSNssaveDatToBin:SubCaseDirectoryNotFound', ...
                'Subcase directory does not exist: %s.', ...
                char(dns.subCaseDir{idxSubCase}));
        end
    end
end

function validateTextScalar(value,valueName)
    isTextScalar = (ischar(value) && isrow(value)) || ...
        (isstring(value) && isscalar(value) && ~ismissing(value));
    if ~isTextScalar
        error('convertDNSNssaveDatToBin:InvalidDnsFieldValue', ...
            '%s must contain a text scalar.',valueName);
    end
end
