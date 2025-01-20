function [configList] = getCaseDirListRc01_2(rootPath)

    n = 1;
    folderName = '1_Ra9e2';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_512/');

    n = n + 1;
    folderName = '2_Ra3e3';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'00_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'00_2_512/');
        'Ra3e3_r_c_0.1/00_2_512/';

    n = n + 1;
    folderName = '3_Ra9e3';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_512/');
    
    n = n + 1;
    folderName = '4_Ra3e4';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'00_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'00_2_512/');

    n = n + 1;
    folderName = '5_Ra9e4';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_512/');
    
    n = n + 1;
    folderName = '6_Ra3e5';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'00_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'00_2_512/');
    configList(n).caseDir{3} = ...
        fullfile(folderName,'00_3_1024/');

    n = n + 1;
    folderName = '7_Ra9e5';
    configList(n).caseDir{1} = ...
        fullfile(folderName,'1_1_256/');
    configList(n).caseDir{2} = ...
        fullfile(folderName,'1_2_512/');
    configList(n).caseDir{3} = ...
        fullfile(folderName,'1_3_1024/');
    configList(n).caseDir{4} = ...
        fullfile(folderName,'1_4_1024/');
    
    % configList(4).caseDir{1} = ...
    % 'Ra3e6_r_c_0.1/02_1_initTmp0_1024/';
    % configList(4).caseDir{2} = ...
    % 'Ra3e6_r_c_0.1/02_2_initTmp0_1024/';
    % 
    % configList(5).caseDir{1} = ...
    % 'Ra3e7_r_c_0.1/04_1_iniTmp0_1024/';
    % 
    % configList(6).caseDir{1} = ...
    % 'Ra3e8_r_c_0.1/05_1_iniTmp0_1024/';
    % 
    % configList(7).caseDir{1} = ...
    % 'Ra3e9_r_c_0.1/46_1_iniTmp0_1536/';
    
    
    for idxConfig = 1:numel(configList)
        for idxSubCase = 1:numel(configList(idxConfig).caseDir)
            configList(idxConfig).caseDir{idxSubCase} = ...
                fullfile(rootPath,configList(idxConfig).caseDir{idxSubCase});
        end
    end
end

