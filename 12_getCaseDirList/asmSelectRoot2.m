function [configList] = asmSelectRoot2(tag)
    configList = cell(1);
    switch tag
        case 'curta'
            path = '/scratch/xhe/0_Bubble+Raw/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001_2(path);
            
            path = '/scratch/xhe/0_Bubble+Raw/02_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01_2(path);

            path = '/scratch/xhe/0_Bubble+Raw/09_A_4';
            [configList{3}] = getCaseDirListA4(path);

            path = '/scratch/xhe/0_Bubble+Raw/08_A_3';
            [configList{4}] = getCaseDirListA3(path);

            path = '/scratch/xhe/0_Bubble+Raw/04_A_0.55_Rc_0.3';
            [configList{5}] = getCaseDirListRc03(path);

            path = '/scratch/xhe/0_Bubble+Raw/06_A_0.8_Rc_0.5';
            [configList{6}] = getCaseDirListRc05(path);

            path = '/scratch/xhe/0_Bubble+Raw/07_A_0.99_Rc_0.9';
            [configList{7}] = getCaseDirListRc09(path);

        case 'IMB'
            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/00_A_0.02_Rc_0.01';
            [configList{1}] = getCaseDirListRc001_2(path);
            
            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/02_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01_2(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/09_A_4';
            [configList{3}] = getCaseDirListA4(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/08_A_3';
            [configList{4}] = getCaseDirListA3(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/04_A_0.55_Rc_0.3';
            [configList{5}] = getCaseDirListRc03(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/06_A_0.8_Rc_0.5';
            [configList{6}] = getCaseDirListRc05(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/07_A_0.99_Rc_0.9';
            [configList{7}] = getCaseDirListRc09(path);

        case 'MacMini'
            root = '/Volumes/00_BubbleDNSData/00_Raw/03_Bubble+/GoodCaseCollection';
            
            folderName = '00_A_50_Rc_0.01';
            path = fullpath(root,folderName);
            [configList{1}] = getCaseDirListRc001_2(path);
            
            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/02_A_0.2_Rc_0.1';
            [configList{2}] = getCaseDirListRc01_2(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/09_A_4';
            [configList{3}] = getCaseDirListA4(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/08_A_3';
            [configList{4}] = getCaseDirListA3(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/04_A_0.55_Rc_0.3';
            [configList{5}] = getCaseDirListRc03(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/06_A_0.8_Rc_0.5';
            [configList{6}] = getCaseDirListRc05(path);

            path = '/tmp/0_CurtaScratch/0_Bubble+Raw/07_A_0.99_Rc_0.9';
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

