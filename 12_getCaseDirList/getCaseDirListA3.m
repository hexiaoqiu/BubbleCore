function [configList] = getCaseDirListA3(rootPath)
    n = 1;
    folderName = 'Ra3e6';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_256/');
    
    n = n + 1;
    folderName = 'Ra1e7';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_512/');
    configList(n).caseDir{3} = ...
        fullfile(folderName,'1_3_512/');    
    
    for idxConfig = 1:numel(configList)
        for idxSubCase = 1:numel(configList(idxConfig).caseDir)
            configList(idxConfig).caseDir{idxSubCase} = ...
                fullfile(rootPath,configList(idxConfig).caseDir{idxSubCase});
        end
    end

end

