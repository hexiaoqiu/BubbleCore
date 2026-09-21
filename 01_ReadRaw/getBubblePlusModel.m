function model = getBubblePlusModel(caseRawDir)
%GETBUBBLEPLUSMODEL Read and describe the Bubble+ physical model.
%   MODEL = GETBUBBLEPLUSMODEL(CASERAWDIR) reads TYPOBS from nsread.dat.
%   TYPOBS is the authoritative discriminator for model-specific inputs such
%   as dissip.dat.

    caseRawDir = normalizeCaseDirectory(caseRawDir);
    nsreadFile = fullfile(caseRawDir,'nsread.dat');
    if ~isfile(nsreadFile)
        error('getBubblePlusModel:NsreadNotFound', ...
            'nsread.dat does not exist: %s.',nsreadFile);
    end

    fileId = fopen(nsreadFile,'r');
    if fileId < 0
        error('getBubblePlusModel:OpenFailed', ...
            'Unable to open nsread.dat: %s.',nsreadFile);
    end
    cleanupObject = onCleanup(@() fclose(fileId));
    content = textscan(fileId,'%s','Delimiter','\n','Whitespace','');
    lines = content{1};
    clear cleanupObject

    idxTypobs = find(contains(lines,'TYPOBS','IgnoreCase',true));
    if isempty(idxTypobs)
        error('getBubblePlusModel:TypobsNotFound', ...
            'No TYPOBS entry was found in %s.',nsreadFile);
    end
    if numel(idxTypobs) > 1
        error('getBubblePlusModel:AmbiguousTypobs', ...
            'Multiple TYPOBS entries were found in %s.',nsreadFile);
    end

    token = regexp(lines{idxTypobs},'^\s*([-+]?\d+)','tokens','once');
    if isempty(token)
        error('getBubblePlusModel:InvalidTypobs', ...
            'Unable to read the TYPOBS value from: %s.',lines{idxTypobs});
    end
    typobs = str2double(token{1});

    model = describeModel(typobs);
    model.nsreadFile = nsreadFile;
end

function model = describeModel(typobs)
    model = struct();
    model.typobs = typobs;
    model.isFTB = typobs == 6;
    model.hasSpots = ismember(typobs,[7,10,12,13,14,15]);
    model.isVibrating = typobs == 8;
    model.isOriginalBubble = typobs == 9;
    model.hasNonlinearRayleighFriction = ismember(typobs,10:15);
    model.requiresDissipFile = model.isFTB || ...
        model.hasNonlinearRayleighFriction;

    switch typobs
        case 6
            model.key = 'frozenTopBubble';
            model.name = 'Frozen Top Bubble';
        case 7
            model.key = 'spots';
            model.name = 'Spots';
        case 8
            model.key = 'vibratingBubble';
            model.name = 'Vibrating Bubble';
        case 9
            model.key = 'originalBubble';
            model.name = 'Original Bubble';
        case 10
            model.key = 'spotsNonlinearRayleigh';
            model.name = 'Spots Nonlinear Rayleigh Friction';
        case 11
            model.key = 'cleanBubbleNonlinearRayleigh';
            model.name = 'Clean Bubble Nonlinear Rayleigh Friction';
        case 12
            model.key = 'spotsPolewardNonlinearRayleigh';
            model.name = 'Spots Poleward Nonlinear Rayleigh Friction';
        case 13
            model.key = 'spotsEquatorwardNonlinearRayleigh';
            model.name = 'Spots Equatorward Nonlinear Rayleigh Friction';
        case 14
            model.key = 'largerSpotsNonlinearRayleigh';
            model.name = 'Larger Spots Nonlinear Rayleigh Friction';
        case 15
            model.key = 'smallerSpotsNonlinearRayleigh';
            model.name = 'Smaller Spots Nonlinear Rayleigh Friction';
        otherwise
            error('getBubblePlusModel:UnsupportedTypobs', ...
                'Unsupported Bubble+ physical-model identifier TYPOBS=%g.', ...
                typobs);
    end
end

function directory = normalizeCaseDirectory(directory)
    if ~((ischar(directory) && isrow(directory)) || ...
            (isstring(directory) && isscalar(directory) && ~ismissing(directory)))
        error('getBubblePlusModel:InvalidDirectory', ...
            'caseRawDir must be a text scalar.');
    end
    directory = char(directory);
    if ~isfolder(directory)
        error('getBubblePlusModel:DirectoryNotFound', ...
            'Case directory does not exist: %s.',directory);
    end
end
