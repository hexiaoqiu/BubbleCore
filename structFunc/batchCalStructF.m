function batchCalStructF(binPathTable,matFilePath,config,GoOn,varargin)

    timeStart = clock;
    logFileNameFull = [char( datetime(timeStart,'Format','yyyy-MM-dd_HH-mm-ss_') ), 'log'];
    logFileDirPath = './logFiles';
    logFilePath = fullfile(logFileDirPath,logFileNameFull);
    
    [logFile, errmsgLog]= fopen(logFilePath,'w');
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
    

    % configure the cell for the storage
    if GoOn == 0
        result = cell(size(binPathTable));
    elseif GoOn == 1
        result = varargin{1};
    end
    
    numCase = numel(binPathTable);
    t0 = clock;
    for counter = 1:numCase
        
        t1 = clock;
        fprintf(logFile, '%s \n',['Processing ',num2str(counter,'%d'),' / ',num2str(numCase,'%d')]);
        disp(['Processing ',num2str(counter,'%d'),' / ',num2str(numCase,'%d')]);
        
        if GoOn == 1
            if ~isempty(result{counter})
                fprintf(logFile, '%s \n','Already finished!');
                disp('Already finished!');
                continue;
            end
        end
        
        
        structF = initStructF(binPathTable{counter},config);
        structF.timeStep = 50:1:structF.maxN;
        % output infor to file
        outputInfor(logFile,structF);

        if structF.GPU == 1
            [success, structF_done] = calStructF_GPU2(structF, logFile);
        else
            [success, structF_done] = calStructF_CPU3(structF, logFile);
        end

        if success == true
            disp('Job well-done!');
            fprintf(logFile, '%s \n','Job well-done!');
        else
            disp('Error!');
            fprintf(logFile, '%s \n','***********---> Error ! <---***********');
            fprintf(logFile, '%s \n','Error in the case: ');
            outputInfor(logFile,structF);
            fprintf(logFile, '%s \n','***********--->End of Error ! <---***********');
        end

        result{counter} = structF_done;
        save(matFilePath,'result');

        t2 = clock;
        fprintf(logFile, '%s\n', timeInfor(t0,t1,t2,counter,numCase) );
        disp(timeInfor(t0,t1,t2,counter,numCase) );
        

    end

    disp('Congratulations! The job is successfully done!')
    fprintf(logFile,'%s\n','Congratulations! The job is successfully done!');
    fclose(logFile);
end