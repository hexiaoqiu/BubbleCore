function [asmCase] = asmCheckConnection(asmCase)

    for idx_1 = 1:asmCase.numSubCase
        lastData = cell(1);
        [asmCase,lastData{1},lastData{2},lastData{3},lastData{4}] = asmInitRead(asmCase,asmCase.endTime(idx_1));
        asmFinishRead(asmCase);
        for idx_2 = 1:asmCase.numSubCase
            if idx_1 == idx_2
                continue
            else
                % check if asmCase_1's last data is the ini data of asmCase_2
                iniData = cell(1);
                [iniData{1},iniData{2},iniData{3},iniData{4}] = asmGetIniCondt(asmCase,idx_2);
                
                maxErr = -1;
                for i = 1:4
                    if (i == 1)||(i == 4)
                        x2d = asmCase.x2dS{idx_2};
                        y2d = asmCase.y2dS{idx_2};
                    elseif i == 2
                        x2d = asmCase.x2dU{idx_2};
                        y2d = asmCase.y2dU{idx_2};
                    elseif i == 3
                        x2d = asmCase.x2dV{idx_2};
                        y2d = asmCase.y2dV{idx_2};
                    end
                    r = sqrt(x2d.^2 + y2d.^2);
                    lastDataInBubble = lastData{i}(r < 1);
                    iniDataInBubble = iniData{i}(r < 1);

                    diff = abs((lastDataInBubble - iniDataInBubble)./iniDataInBubble);
                    err = max(diff, [], "all");
                    maxErr = max(maxErr,err);
                end
            
                if maxErr < 1e-6
                    output = [ ...
                        'The head is the case in dir ', ...
                        asmCase.subCaseDir{idx_1}, ...
                        ' \n '
                        'The rear is the case in dir ', ...
                        asmCase.subCaseDir{idx_2} ...
                    ];
                    asmCase.rear(idx_1) = idx_2;
                    asmCase.head(idx_2) = idx_1;
                else
                    output = 'No connection is found!';
                end
                disp(output)
            end
        end
    end
end

