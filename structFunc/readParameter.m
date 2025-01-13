function [binPathTable,matFilePath,parobj] = readParameter(parameterFilePath,config)

    [parameterFile, errmsgParameter] = fopen(parameterFilePath,'r','n','UTF-8');
    if isempty(errmsgParameter) == false
        Warning = ['Error of Openning Config File: ',errmsgParameter]; 
        binPathTable = Warning;
        matFilePath = Warning;
        parobj = Warning;
        return
    end

    % read the data path
    cache = textscan(parameterFile,'%s',1,'HeaderLines',1,'Delimiter','\n');
    rootDir = cache{1}{1};
    disp(['Read the root dir =',rootDir]);

    % read the Ra 
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    RaList = cache2{1};
    RaInfor = ['Read Ra List = ',cache{1}{1}];
    disp(RaInfor);

    % read the RZero
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    RZeroList = cache2{1};
    RZeroInfor = ['Read 1/Ro List = ',cache{1}{1}];
    disp(RZeroInfor);

    % read the Delta
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    DeltaList = cache2{1};
    Deltainfor = ['Read Delta List = ',cache{1}{1}];
    disp(Deltainfor)

    % read the cluster
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%d');
    cluster = cache2{1};
    Clusterinfor = ['On the cluster = ',cache{1}{1}];
    disp(Clusterinfor)

    % read the parallel core number
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    numParallelCores = cache2{1};
    Coresinfor = ['Number of Cores = ',cache{1}{1}];
    disp(Coresinfor);

    % read the storage file path
    cache = textscan(parameterFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    storagePath = cache{1}{1};
    Fileinfor = ['the result is stored in ',cache{1}{1}];
    disp(Fileinfor);

    fclose(parameterFile);
    
    % get the bin dir table
    binPathTable = getBinPathTable(RaList, DeltaList);

    
    % determinate the store path
    storeDir = fullfile(storagePath,'mat');
    if ~exist(storeDir,'dir')
        mkdir(storeDir);
    end
    matFileNameShort_0 = ['Ra-',num2str(RaList(1),'%g'),'-',num2str(RaList(end),'%g'),'_'];
    matFileNameShort_1 = ['Delta-',num2str(DeltaList(1),'%g'),'-',num2str(DeltaList(end),'%g'),'_'];
    matFileNameShort_2 = ['RZero-',num2str(RZeroList(1),'%g'),'-',num2str(RZeroList(end),'%g'),'_'];
    matFileNameShort_3 = [config.type,'_thetaMax_',num2str(config.scanWin(4),'%d'),'_res_',num2str(config.resolution(2),'%d')];
    matFileName = [char( datetime(clock,'Format','yyyy-MM-dd_HH-mm_') ), matFileNameShort_0,matFileNameShort_1,matFileNameShort_3];
    matFilePath = fullfile(storeDir,matFileName);
    
    % handle the paral pool
    if cluster == 1
        parobj = gcp('nocreate');
        if isempty(parobj)
            parobj = parpool('local',numParallelCores);
        end
    else
        parobj = 'No Auto Parallel Pool';
    end
    

end