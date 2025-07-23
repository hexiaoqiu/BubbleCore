function [dnsCaseDirList] = getAllDNSDir(tag)
dnsCaseDirList = cell(1);
folderName = cell(1);
folderName{1} = '01_A_50_Rc_0.01';
folderName{2} = '02_A_5_Rc_0.1';
folderName{3} = '03_A_4';
folderName{4} = '04_A_3';
folderName{5} = '05_A_1.82_Rc_0.3';
folderName{6} = '06_A_1.25_Rc_0.5';
folderName{7} = '07_A_1_Rc_0.9';

funcList = {@getCaseDirListRc001_2, @getCaseDirListRc01_2,...
    @getCaseDirListA4, @getCaseDirListA3, @getCaseDirListRc03, ...
    @getCaseDirListRc05, @getCaseDirListRc09};

switch tag
    case 'GDrivePro'
        root = '/Volumes/G-DRIVE PRO/01_BubblePlus';
    case 'Silver16T'
        root = '/Volumes/ProNTFSDrive/disk4s2/03_Bubble+/GoodCaseCollection';
    otherwise
        disp('The choice of tag is:')
        disp('HDD NAS curta')
        return
end

for i = 1:numel(folderName)
    path = fullfile(root,folderName{i});
    [dnsCaseDirList{i}] = funcList{i}(path);
end



end

