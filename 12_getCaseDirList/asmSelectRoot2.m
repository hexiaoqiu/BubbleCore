function [configList] = asmSelectRoot2(tag)
    configList = cell(1);
    switch tag
        case 'curta'
            root = '/scratch/xhe/0_Bubble+Raw';
            
            folderName = '01_A_50_Rc_0.01';
            path = fullfile(root,folderName);
            [configList{1}] = getCaseDirListRc001_2(path);
            
            folderName = '02_A_5_Rc_0.1';
            path = fullfile(root,folderName);
            [configList{2}] = getCaseDirListRc01_2(path);
            
            folderName = '03_A_4';
            path = fullfile(root,folderName);
            [configList{3}] = getCaseDirListA4(path);

            folderName = '04_A_3';
            path = fullfile(root,folderName);
            [configList{4}] = getCaseDirListA3(path);
            
            folderName = '05_A_1.82_Rc_0.3';
            path = fullfile(root,folderName);
            [configList{5}] = getCaseDirListRc03(path);

            folderName = '06_A_1.25_Rc_0.5';
            path = fullfile(root,folderName);
            [configList{6}] = getCaseDirListRc05(path);

            folderName = '07_A_1_Rc_0.9';
            path = fullfile(root,folderName);
            [configList{7}] = getCaseDirListRc09(path);

        case 'IMB'
            
            root = '/tmp/0_CurtaScratch/0_Bubble+Raw';
            
            folderName = '01_A_50_Rc_0.01';
            path = fullfile(root,folderName);
            [configList{1}] = getCaseDirListRc001_2(path);
            
            folderName = '02_A_5_Rc_0.1';
            path = fullfile(root,folderName);
            [configList{2}] = getCaseDirListRc01_2(path);
            
            folderName = '03_A_4';
            path = fullfile(root,folderName);
            [configList{3}] = getCaseDirListA4(path);

            folderName = '04_A_3';
            path = fullfile(root,folderName);
            [configList{4}] = getCaseDirListA3(path);
            
            folderName = '05_A_1.82_Rc_0.3';
            path = fullfile(root,folderName);
            [configList{5}] = getCaseDirListRc03(path);

            folderName = '06_A_1.25_Rc_0.5';
            path = fullfile(root,folderName);
            [configList{6}] = getCaseDirListRc05(path);

            folderName = '07_A_1_Rc_0.9';
            path = fullfile(root,folderName);
            [configList{7}] = getCaseDirListRc09(path);
            

        case 'MacMini'
            root = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection';
            
            folderName = '01_A_50_Rc_0.01';
            path = fullfile(root,folderName);
            [configList{1}] = getCaseDirListRc001_2(path);
            
            folderName = '02_A_5_Rc_0.1';
            path = fullfile(root,folderName);
            [configList{2}] = getCaseDirListRc01_2(path);
            
            folderName = '03_A_4';
            path = fullfile(root,folderName);
            [configList{3}] = getCaseDirListA4(path);

            folderName = '04_A_3';
            path = fullfile(root,folderName);
            [configList{4}] = getCaseDirListA3(path);
            
            folderName = '05_A_1.82_Rc_0.3';
            path = fullfile(root,folderName);
            [configList{5}] = getCaseDirListRc03(path);

            folderName = '06_A_1.25_Rc_0.5';
            path = fullfile(root,folderName);
            [configList{6}] = getCaseDirListRc05(path);

            folderName = '07_A_1_Rc_0.9';
            path = fullfile(root,folderName);
            [configList{7}] = getCaseDirListRc09(path);

        case 'NAS'
            path = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001(path);
            path = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/01_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01(path);
            path = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/02_A_0.55_Rc_0.3';
            [configList{3}] = getCaseDirListRc03(path);
            path = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/03_A_0.8_Rc_0.5';
            [configList{4}] = getCaseDirListRc05(path);
            path = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/04_A_0.99_Rc_0.9';
            [configList{5}] = getCaseDirListRc09(path);
        case 'HDD'
            path = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001(path);
            path = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/01_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01(path);
            path = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/02_A_0.55_Rc_0.3';
            [configList{3}] = getCaseDirListRc03(path);
            path = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/03_A_0.8_Rc_0.5';
            [configList{4}] = getCaseDirListRc05(path);
            path = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/04_A_0.99_Rc_0.9';
            [configList{5}] = getCaseDirListRc09(path);
        otherwise
            disp('The choice of tag is:')
            disp('HDD NAS curta')
    end



end

