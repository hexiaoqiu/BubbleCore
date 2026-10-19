function testFolderBranchExclusion()
%TESTFOLDERBRANCHEXCLUSION 精确层级、分支剪除和root排除边界的独立合成测试。
    toolDirectory = fileparts(fileparts(mfilename('fullpath')));
    oldPath = path; pathCleanup = onCleanup(@() path(oldPath));
    addpath(toolDirectory);
    coreDirectory = fileparts(toolDirectory);
    addpath(fullfile(coreDirectory,'00_asmCase'));
    addpath(fullfile(coreDirectory,'11_SubFolderFileSearch'));
    addpath(fullfile(coreDirectory,'01_ReadRaw'));
    scratch = tempname; mkdir(scratch);
    cleanup = onCleanup(@() rmdir(scratch,'s'));
    top = fullfile(scratch,'READme_ancestor','ReadMe_root');
    first = fullfile(top,'normal');
    second = fullfile(first,'middle');
    third = fullfile(second,'dns');
    mkdir(fullfile(third,'fourth'));
    % 只按readme连续子串排除，不扩大成带空格的其他名称规则。
    otherFirst = fullfile(top,'read_me');
    otherSecond = fullfile(otherFirst,'middle');
    otherThird = fullfile(otherSecond,'dns'); mkdir(otherThird);
    % 使用不同前后缀，避免macOS大小写不敏感磁盘把夹具合并为同一目录。
    for name = {'readme','prefix_ReadMe','mixed_rEaDmE_suffix','prefix_README_suffix'}
        mkdir(fullfile(top,name{1},'middle','dns','fourth'));
        mkdir(fullfile(first,name{1},'dns','fourth'));
        mkdir(fullfile(second,name{1},'fourth'));
    end
    fid = fopen(fullfile(second,'ordinary_file'),'w'); assert(fid>=0); fclose(fid);

    assertPaths(getFirstLevelFolders(top),{first;otherFirst});
    assertPaths(getSecondLevelFolders(top),{second;otherSecond});
    assertPaths(getThirdLevelFolders(top),{third;otherThird});
    assertDirectFolders(top,{first;otherFirst});
    assertDirectFolders(first,{second});
    assertDirectFolders(second,{third});
    % 调用者明确指定含readme的目录为新root时，不应检查该root自身。
    newRoot = fullfile(top,'readme');
    assertPaths(getFirstLevelFolders(newRoot),{fullfile(newRoot,'middle')});
    assertPaths(getSecondLevelFolders(newRoot),{fullfile(newRoot,'middle','dns')});
    assertPaths(getThirdLevelFolders(newRoot),{fullfile(newRoot,'middle','dns','fourth')});
    assertDirectFolders(newRoot,{fullfile(newRoot,'middle')});

    empty = fullfile(scratch,'empty'); mkdir(empty);
    assertPaths(getFirstLevelFolders(empty),cell(0,1));
    assertPaths(getSecondLevelFolders(empty),cell(0,1));
    assertPaths(getThirdLevelFolders(empty),cell(0,1));
    assertDirectFolders(empty,cell(0,1));
    onlyExcluded = fullfile(scratch,'onlyExcluded');
    mkdir(fullfile(onlyExcluded,'READme','middle','dns'));
    assertPaths(getFirstLevelFolders(onlyExcluded),cell(0,1));
    assertPaths(getSecondLevelFolders(onlyExcluded),cell(0,1));
    assertPaths(getThirdLevelFolders(onlyExcluded),cell(0,1));
    assertDirectFolders(onlyExcluded,cell(0,1));

    % 数字目录沿用dir顺序（1、10、2），不能擅自改变成数值排序。
    orderedRoot = fullfile(scratch,'ordered');
    mkdir(fullfile(orderedRoot,'2'));
    mkdir(fullfile(orderedRoot,'10'));
    mkdir(fullfile(orderedRoot,'1'));
    assertDirectFolders(orderedRoot,{fullfile(orderedRoot,'1'); ...
        fullfile(orderedRoot,'10');fullfile(orderedRoot,'2')});

    % 相对root和尾部分隔符不改变筛选边界；临时切换目录后完整恢复。
    originalDirectory = pwd;
    directoryCleanup = onCleanup(@() cd(originalDirectory));
    cd(scratch);
    relativeRoot = fullfile('READme_ancestor','ReadMe_root');
    assertPaths(getThirdLevelFolders(relativeRoot),{third;otherThird});
    assertPaths(getSecondLevelFolders([top,filesep]),{second;otherSecond});
    % DNS发现仍返回完整路径；两个旧路径工具继续保持相对路径形式。
    assert(isequal(getDnsSubcaseDirList(relativeRoot),{first;otherFirst}));
    expectedRelative = {fullfile(relativeRoot,'normal');fullfile(relativeRoot,'read_me')};
    assert(isequal(getSubFolder(relativeRoot),expectedRelative));
    [count,paths] = getCaseRawDir(relativeRoot);
    assert(count==2 && isequal(paths,expectedRelative));
    assertDirectFolders([top,filesep],{first;otherFirst});
    cd(originalDirectory);
    for level = 1:3
        failed = false;
        try
            switch level
                case 1
                    getFirstLevelFolders(fullfile(scratch,'missing'));
                case 2
                    getSecondLevelFolders(fullfile(scratch,'missing'));
                case 3
                    getThirdLevelFolders(fullfile(scratch,'missing'));
            end
        catch exception
            failed = true; assert(contains(exception.message,'不存在'));
        end
        assert(failed);
    end
    fprintf('PASS: folder levels and direct-child tools, pruning, order, relative paths and empty results.\n');
end

function assertDirectFolders(root,expected)
% 精确比较顺序与列cell形状，不用排序掩盖子case顺序变化。
    assert(isequal(getDnsSubcaseDirList(root),expected));
    assert(isequal(getSubFolder(root),expected));
    [count,paths] = getCaseRawDir(root);
    assert(count==numel(expected) && isequal(paths,expected));
end

function assertPaths(actual,expected)
    assert(iscell(actual) && size(actual,2)==1);
    assert(isequal(sort(actual),sort(expected)));
    assert(numel(unique(actual))==numel(actual));
end
