function runComputeStructFunc(configFilePath,d,order,algorithm,scanWin,resolution,itpMethod,GPU,timeStep0,matFilePath)
    %%
    [logFile, errmsgLog]= fopen('logStructFunc','w');
    if isempty(errmsgLog) == false
        errFile = fopen('errFatal','w');
        fprintf(errFile, errmsgLog,'%s\n');
        fclose(errFile);
        return
    end
    timeStart = datetime;
    timeInforChar = ['Task begins at ',char(timeStart)];
    disp(timeInforChar);
    fprintf(logFile,'%s \n',timeInforChar);

    % open config
    [configFile, errmsgConfig] = fopen(configFilePath,'r','n','UTF-8');
    if isempty(errmsgConfig) == false
        fprintf(logFile,'%s \n',['Error of Openning Config File: ',errmsgConfig]);
        timeStart = datetime;
        timeInforChar = ['Task ends at ',char(timeStart)];
        fprintf(logFile,'%s \n',timeInforChar);
        fclose(logFile);
        return
    end

    % read the data path
    cache = textscan(configFile,'%s',1,'HeaderLines',1,'Delimiter','\n');
    rootDir = cache{1}{1};
    fprintf(logFile, '%s \n', ['Read the root dir =',rootDir]);
    disp(['Read the root dir =',rootDir]);

    % read the field
    cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    field = cache{1}{1};
    fprintf(logFile, '%s \n', ['Compute the field ',field]);
    disp(['Compute the field ',field]);

    % read the Ra 
    cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    RaList = cache2{1};
    RaInfor = ['Read Ra List = ',cache{1}{1}];
    fprintf(logFile, '%s \n', RaInfor);
    disp(RaInfor);

    % read the RZero
    cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    RZeroList = cache2{1};
    RZeroInfor = ['Read 1/Ro List = ',cache{1}{1}];
    fprintf(logFile, '%s \n', RZeroInfor);
    disp(RZeroInfor);

    % read the Delta
    cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    DeltaList = cache2{1};
    Deltainfor = ['Read Delta List = ',cache{1}{1}];
    fprintf(logFile, '%s \n', Deltainfor);
    disp(Deltainfor)

    % read the parallel core number
    cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    cache2 = textscan( cache{1}{1},'%f');
    numCores = cache2{1};
    Coresinfor = ['Number of Cores = ',cache{1}{1}];
    fprintf(logFile, '%s \n', Coresinfor);
    disp(Coresinfor);

    % read the storage file path
    % cache = textscan(configFile,'%s',1,'Delimiter','\n','HeaderLines',1);
    % matFilePath = cache{1}{1};
    % Fileinfor = ['the result is stored in ',cache{1}{1}];
    % fprintf(logFile, '%s \n', Fileinfor);
    % disp(Fileinfor);

    fclose(configFile);


    % configure the case paht
    n = numel(RaList);
    m = numel(RZeroList);
    k = numel(DeltaList);
    binPath = cell(n,m,k);
    counter_case = 0;
    for idx_Delta = 1:k
        for idx_Ra = 1:n
            for idx_RZero = 1:m
                counter_case = counter_case + 1;
                [binPath{counter_case}] = makeDir(rootDir, RaList(idx_Ra), RZeroList(idx_RZero), DeltaList(idx_Delta));
            end
        end
    end
    binPath = squeeze(binPath);

    % configure the parallel computing 
    % fprintf(logFile,'%s\n','Begin to make parpool');
    % parobj = gcp('nocreate');
    % if isempty(parobj)
    %     parobj = parpool('local',numCores);
    % end
    % fprintf(logFile,'%s\n',['The number of threads is ',num2str(parobj.NumWorkers,'%d')]);

    % configure the cell for the storage
    result = cell(size(binPath));
    
    %%
    numCase = numel(binPath);
    t0 = clock;
    for counter = 1:numCase

        t1 = clock;

        StFn = configStructFunc(binPath{counter},order,d);
        StFn.resolution = resolution;
        StFn.timeStepList = (timeStep0:1:StFn.maxN)';
        StFn.algorithm = algorithm;
        StFn.dVelMethod = 'l';
        StFn.itpMethod = itpMethod;
        StFn.scanWindow = scanWin;

        % output infor to file
        fprintf(logFile, '%s \n',['***********--->Processing ',num2str(counter,'%d'),' / ',num2str(numCase,'%d'),'<---***********']);
        disp(['***********--->Processing ',num2str(counter,'%d'),' / ',num2str(numCase,'%d'),'<---***********']);
        caseInfor = obtainInfor(StFn);
        for iWrite = 1:numel(caseInfor)
            fprintf(logFile, '%s \n', caseInfor{iWrite});
            disp(caseInfor{iWrite});
        end



        [success,StructFunc] = obtainStructFuncPhi(StFn,field,GPU,logFile);
        if success == true
            disp('Job well-done!');
            fprintf(logFile, '%s \n','Job well-done!');
        else
            disp('Error!');
            fprintf(logFile, '%s \n','***********---> Error ! <---***********');
            fprintf(logFile, '%s \n','Error in the case: ');
            caseInfor = obtainInfor(StFn);
            for iWrite = 1:numel(caseInfor)
                fprintf(logFile, '%s \n', caseInfor{iWrite});
            end
            fprintf(logFile, '%s \n','***********---> end of Error <---***********');
            % return
        end

        result{counter} = StructFunc;
        save(matFilePath,'result');
        clear StFn StructFunc
        t2 = clock;
        fprintf(logFile, '%s\n', timeInfor(t0,t1,t2,counter,numCase) );
        disp(timeInfor(t0,t1,t2,counter,numCase) );
        

    end
    
    disp('Congratulations! The job is successfully done!')
    fprintf(logFile,'%s\n','Congratulations! The job is successfully done!');
    fclose(logFile);
end