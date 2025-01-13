function [configList] = asmSelectRoot2(tag)
    configList = cell(1);
    switch tag
        case 'curta'
            rootPath = '/scratch/xhe/0_Bubble+Raw/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001_2(rootPath);
            
            rootPath = '/scratch/xhe/0_Bubble+Raw/02_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01_2(rootPath);

            rootPath = '/scratch/xhe/0_Bubble+Raw/09_A_4';
            [configList{3}] = getCaseDirListA4(rootPath);

            rootPath = '/scratch/xhe/0_Bubble+Raw/08_A_3';
            [configList{4}] = getCaseDirListA3(rootPath);

            rootPath = '/scratch/xhe/0_Bubble+Raw/04_A_0.55_Rc_0.3';
            [configList{5}] = getCaseDirListRc03(rootPath);

            rootPath = '/scratch/xhe/0_Bubble+Raw/06_A_0.8_Rc_0.5';
            [configList{6}] = getCaseDirListRc05(rootPath);

            rootPath = '/scratch/xhe/0_Bubble+Raw/07_A_0.99_Rc_0.9';
            [configList{7}] = getCaseDirListRc09(rootPath);

        case 'NAS'
            rootPath = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001(rootPath);
            rootPath = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/01_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01(rootPath);
            rootPath = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/02_A_0.55_Rc_0.3';
            [configList{3}] = getCaseDirListRc03(rootPath);
            rootPath = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/03_A_0.8_Rc_0.5';
            [configList{4}] = getCaseDirListRc05(rootPath);
            rootPath = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection/04_A_0.99_Rc_0.9';
            [configList{5}] = getCaseDirListRc09(rootPath);
        case 'HDD'
            rootPath = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001(rootPath);
            rootPath = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/01_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01(rootPath);
            rootPath = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/02_A_0.55_Rc_0.3';
            [configList{3}] = getCaseDirListRc03(rootPath);
            rootPath = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/03_A_0.8_Rc_0.5';
            [configList{4}] = getCaseDirListRc05(rootPath);
            rootPath = '/Volumes/Silver16TB/03_Bubble+/GoodCaseCollection/04_A_0.99_Rc_0.9';
            [configList{5}] = getCaseDirListRc09(rootPath);
        otherwise
            disp('The choice of tag is:')
            disp('HDD NAS curta')
    end



end

