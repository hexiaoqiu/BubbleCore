function [time,numIter] = asmGetNumIter(varargin)
    minArgs = 1;
    maxArgs = 3;
    narginchk(minArgs,maxArgs);
    if nargin == 3
        ns = varargin{1};
        idxSubCaseStart = varargin{2};
        idxSubCaseEnd = varargin{3};
    elseif nargin == 1
        ns = varargin{1};
        idxSubCaseStart = 1;
        idxSubCaseEnd = ns.numSubCase;
    else
        disp('Wrong Input!')
        time = NaN;
        numIter = NaN;
        return
    end
    timeAll = cell(1,idxSubCaseEnd-idxSubCaseStart+1);
    numIterAll = cell(1,idxSubCaseEnd-idxSubCaseStart+1);
    
    counterCase = 0;
    for idxSubCase = idxSubCaseStart:1:idxSubCaseEnd

        counterCase = counterCase + 1;
        % locate data file
        nsprintDir = fullfile(ns.subCaseDir{idxSubCase},'nsprint.dat');
        disp(['recording iteration time in ', nsprintDir]);

        % start tracking
        fid = fopen(nsprintDir, 'r','n');
        
        counter = 0;
        numIterSub = zeros(1,1);
        dtPrintFound = false;
        while ~feof(fid)
           line = fgetl(fid);
           if ~isempty(line)
               cache = textscan(line,'%s',1);
               firstChar = cache{1}{1};
               if strcmp(firstChar,'MONO')
                   cache2 = textscan(line(6:end),'%f');
                   if isempty(cache2{1})
                        break
                   else
                        counter = counter + 1;
                        numIterSub(counter) = cache2{1}(2);
                        % disp(['Step=',num2str(counter,'%g'),' IterNum=',num2str(numIter(counter),'%g')])
                   end
               end
               if dtPrintFound == false
                   cache2 = textscan(line,'%s%s%s%s%f');
                   badForm = (isempty(cache2{1}))||(isempty(cache2{2}))||...
                       (isempty(cache2{3}))||(isempty(cache2{4}))||...
                       (isempty(cache2{5}));
                   if badForm == false
                       firstChar = cache2{1}{1};
                       secondChar = cache2{2}{1};
                       thirdChar = cache2{3}{1};
                       fourthChar = cache2{4}{1};
                       goodHeadString = strcmp(firstChar,'NSMGEV')&&...
                           strcmp(secondChar,'TEMPS')&&...
                           strcmp(thirdChar,'ATTEINT')&&...
                           strcmp(fourthChar,':');
                       if goodHeadString 
                            dtPrint = cache2{5};
                            dtPrintFound = true;
                       end
                   end
               end
           end
        end
        disp('Stop Tracking! ')
        fclose(fid);

        timeAll{counterCase} = (1:1:counter)'*dtPrint;
        numIterAll{counterCase} = numIterSub';
    end

    disp('connet all time and number of iteration!')
    numStep = zeros(counterCase,1);
    for idxSubCase = 1:counterCase
        numStep(idxSubCase) = numel(timeAll{idxSubCase});
        timeShift = ns.startTime(idxSubCaseStart+idxSubCase-1);
        timeAll{idxSubCase} = timeAll{idxSubCase} + timeShift;
    end
    time = zeros(sum(numStep,1),1);
    numIter = zeros(sum(numStep,1),1);
    for idxSubCase = 1:counterCase
        if idxSubCase == 1
            idxHead = 1;
        else
            idxHead = sum(numStep(1:idxSubCase-1),1) + 1;
        end
        idxRear = sum(numStep(1:idxSubCase),1);
        time(idxHead:idxRear) = timeAll{idxSubCase};
        numIter(idxHead:idxRear) = numIterAll{idxSubCase};
    end


end

