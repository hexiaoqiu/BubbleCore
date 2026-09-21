function dissip = getDissipParameters(caseRawDir,model)
%GETDISSIPPARAMETERS Read dissip.dat according to the Bubble+ model.
%   DISSIP = GETDISSIPPARAMETERS(CASERAWDIR,MODEL) uses MODEL.typobs to
%   distinguish the legacy Frozen Top Bubble format from the labeled
%   nonlinear-Rayleigh format. Models that do not use dissip.dat return a
%   structure with type 'none'.

    narginchk(2,2);
    caseRawDir = normalizeCaseDirectory(caseRawDir);
    validateModel(model);

    dissipFile = fullfile(caseRawDir,'dissip.dat');
    dissip = emptyDissipParameters(dissipFile);

    if model.isFTB
        dissip = readFrozenTopParameters(dissipFile,dissip);
    elseif model.hasNonlinearRayleighFriction
        dissip = readNonlinearRayleighParameters(dissipFile,dissip);
    else
        dissip.fileFound = isfile(dissipFile);
    end
end

function dissip = emptyDissipParameters(dissipFile)
    dissip = struct();
    dissip.type = 'none';
    dissip.filePath = dissipFile;
    dissip.fileRequired = false;
    dissip.fileFound = isfile(dissipFile);
    dissip.dissipType = NaN;
    dissip.r_c = NaN;
    dissip.delta_r = NaN;
    dissip.velocityThreshold = NaN;
    dissip.activationRate = NaN;
end

function dissip = readFrozenTopParameters(dissipFile,dissip)
    requireDissipFile(dissipFile);
    lines = readFileLines(dissipFile);
    numericValues = zeros(numel(lines),1);
    numNumericValues = 0;
    numericPattern = [ ...
        '^\s*[-+]?(?:\d+\.?\d*|\.\d+)' ...
        '(?:[EeDd][-+]?\d+)?\s*$'];
    for idxLine = 1:numel(lines)
        line = strtrim(lines{idxLine});
        if ~isempty(regexp(line,numericPattern,'once'))
            numNumericValues = numNumericValues+1;
            numericValues(numNumericValues) = str2double( ...
                regexprep(line,'[dD]','E'));
        end
    end
    numericValues = numericValues(1:numNumericValues);

    if numel(numericValues) < 2
        error('getDissipParameters:InvalidFrozenTopFormat', ...
            ['Frozen Top Bubble dissip.dat must contain dissipType and ' ...
             'r_c values: %s.'],dissipFile);
    end
    dissipType = numericValues(1);
    if ~isfinite(dissipType) || dissipType ~= round(dissipType)
        error('getDissipParameters:InvalidDissipType', ...
            'dissipType must be a finite integer in %s.',dissipFile);
    end
    r_c = numericValues(2);
    if ~isfinite(r_c)
        error('getDissipParameters:InvalidCriticalRadius', ...
            'r_c must be finite in %s.',dissipFile);
    end
    if dissipType == 1
        if numel(numericValues) < 3 || ~isfinite(numericValues(3))
            error('getDissipParameters:MissingDeltaRadius', ...
                'dissipType=1 requires a finite delta_r in %s.',dissipFile);
        end
        delta_r = numericValues(3);
    else
        delta_r = 0;
    end

    dissip.type = 'frozenTop';
    dissip.fileRequired = true;
    dissip.fileFound = true;
    dissip.dissipType = dissipType;
    dissip.r_c = r_c;
    dissip.delta_r = delta_r;
end

function dissip = readNonlinearRayleighParameters(dissipFile,dissip)
    requireDissipFile(dissipFile);
    lines = readFileLines(dissipFile);
    while ~isempty(lines) && isempty(strtrim(lines{end}))
        lines(end) = [];
    end
    if numel(lines) < 4 || ...
            ~strcmp(strtrim(lines{1}),'Velocity Threshold') || ...
            ~strcmp(strtrim(lines{3}),'Activation Rate')
        error('getDissipParameters:InvalidNonlinearRayleighFormat', ...
            ['Nonlinear-Rayleigh dissip.dat must contain the exact labels ' ...
             '''Velocity Threshold'' and ''Activation Rate'': %s.'], ...
            dissipFile);
    end

    velocityThreshold = parseScalar(lines{2},'Velocity Threshold',dissipFile);
    activationRate = parseScalar(lines{4},'Activation Rate',dissipFile);
    if velocityThreshold < 0
        error('getDissipParameters:InvalidVelocityThreshold', ...
            'Velocity Threshold must be greater than or equal to zero.');
    end
    if activationRate <= 0
        error('getDissipParameters:InvalidActivationRate', ...
            'Activation Rate must be greater than zero.');
    end

    dissip.type = 'nonlinearRayleigh';
    dissip.fileRequired = true;
    dissip.fileFound = true;
    dissip.velocityThreshold = velocityThreshold;
    dissip.activationRate = activationRate;
end

function value = parseScalar(line,label,dissipFile)
    value = str2double(regexprep(strtrim(line),'[dD]','E'));
    if ~isscalar(value) || ~isfinite(value)
        error('getDissipParameters:InvalidNumericValue', ...
            '%s must be a finite scalar in %s.',label,dissipFile);
    end
end

function lines = readFileLines(fileName)
    fileId = fopen(fileName,'r');
    if fileId < 0
        error('getDissipParameters:OpenFailed', ...
            'Unable to open dissip.dat: %s.',fileName);
    end
    cleanupObject = onCleanup(@() fclose(fileId));
    content = textscan(fileId,'%s','Delimiter','\n','Whitespace','');
    lines = content{1};
    clear cleanupObject
end

function requireDissipFile(fileName)
    if ~isfile(fileName)
        error('getDissipParameters:DissipFileNotFound', ...
            'The selected Bubble+ model requires dissip.dat: %s.',fileName);
    end
end

function validateModel(model)
    requiredFields = {'typobs','isFTB','hasNonlinearRayleighFriction'};
    if ~isstruct(model) || ~isscalar(model) || ...
            ~all(isfield(model,requiredFields))
        error('getDissipParameters:InvalidModel', ...
            'model must be a scalar structure returned by getBubblePlusModel.');
    end
end

function directory = normalizeCaseDirectory(directory)
    if ~((ischar(directory) && isrow(directory)) || ...
            (isstring(directory) && isscalar(directory) && ~ismissing(directory)))
        error('getDissipParameters:InvalidDirectory', ...
            'caseRawDir must be a text scalar.');
    end
    directory = char(directory);
    if ~isfolder(directory)
        error('getDissipParameters:DirectoryNotFound', ...
            'Case directory does not exist: %s.',directory);
    end
end
