function [asmCase, tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepForward(asmCase)
    
    % 检查是否需要跳subCase
    if asmCase.nextReadTime > asmCase.endTime(asmCase.readNowSubCaseIdx)
        % 如果需要跳subCase
        disp(['The subCase ',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}, ' have been gone through!']);
        if asmCase.readNowSubCaseIdx + 1 <= asmCase.numSubCase
            % 关闭正在读取的子算例
            fclose(asmCase.readNowFileID);
            % 找到下个subCase的路径
            disp(['Move to the next subCase: ',asmCase.subCaseDir{asmCase.readNowSubCaseIdx+1}])
            % 更新正在读取的子算例的索引号码
            asmCase.readNowSubCaseIdx = asmCase.readNowSubCaseIdx + 1;
            % 打开要读取的子算例数据文件
            nssaveDir = fullfile(asmCase.subCaseDir{asmCase.readNowSubCaseIdx},asmCase.dataFileName{asmCase.readNowSubCaseIdx});
            % 根据要读取的子算例的类型选择读取函数
            if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
                % 如果是文本类型
                asmCase.readNowFileID = fopen(nssaveDir, 'r','n','UTF-8');
                % 第一次读取这个子算例，需要跳5行
                numSkipLine = 5;
            elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
                % 如果是二进制类型
                asmCase.readNowFileID = fopen(nssaveDir, 'r','n');
                % 不用跳过任何比特，因为是连续读取，而且不用跳过任何时间步的数据：
                % 跳过时间步的行为只可能发生在第一次读取
                numSkipByte = 0;
            end
            %计算下一次读取的时间步:
            %一旦跳case，读取时间自动设置为新case的起始时间，所以不必担心上一个case的dtSave和新case不一样
            %同时,dtSave也随着readNowSubCaseIdx更新而自动更新
            asmCase.lastReadTime = asmCase.startTime(asmCase.readNowSubCaseIdx);
            asmCase.nextReadTime = asmCase.lastReadTime + asmCase.dtSave(asmCase.readNowSubCaseIdx);
            asmCase.nextReadTime = round(asmCase.nextReadTime, asmCase.timePrecision);
            
        else
            disp('All the subCases have been gone through! No more data to read!')
            tmpOrg = [];
            u2dOrg = [];
            v2dOrg = [];
            prsOrg = [];
            asmCase.readNextTime = NaN;
            return
        end
    else  
        % 不需要跳subCase，在同一个subCase继续读取
        if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
            % 如果是在同一个bin类型SubCase中继续读取，则不需要跳过任何的字节
            numSkipByte = 0;
        elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
            % 如果是在同一个text类型的SubCase中继续读取，则需要跳过6行：
            % 上一次读取后，读取焦点在数据块的最后一行的末尾，下一个数据块有5行的header
            % 所以一共跳6行达到下一个数据块的首行
            numSkipLine = 6;
        end
        %计算下一次读取的时间步
        asmCase.lastReadTime = asmCase.nextReadTime;
        asmCase.nextReadTime = asmCase.lastReadTime + asmCase.dtSave(asmCase.readNowSubCaseIdx);
        asmCase.nextReadTime = round(asmCase.nextReadTime, asmCase.timePrecision);
    end
    
    % 读取计数器自增1
    asmCase.readCounter = asmCase.readCounter + 1;
    if strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'bin')
        [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepBin(asmCase,numSkipByte);
    elseif strcmp(asmCase.type{asmCase.readNowSubCaseIdx},'txt')
        [tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepTxt(asmCase,numSkipLine);
    end

end