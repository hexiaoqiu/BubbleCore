function testFolderBranchExclusion()
%TESTFOLDERBRANCHEXCLUSION 精确层级、分支剪除和root排除边界的独立合成测试。
    toolDirectory = fileparts(fileparts(mfilename('fullpath')));
    oldPath = path; pathCleanup = onCleanup(@() path(oldPath));
    addpath(toolDirectory);
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
    % 调用者明确指定含readme的目录为新root时，不应检查该root自身。
    newRoot = fullfile(top,'readme');
    assertPaths(getFirstLevelFolders(newRoot),{fullfile(newRoot,'middle')});
    assertPaths(getSecondLevelFolders(newRoot),{fullfile(newRoot,'middle','dns')});
    assertPaths(getThirdLevelFolders(newRoot),{fullfile(newRoot,'middle','dns','fourth')});

    empty = fullfile(scratch,'empty'); mkdir(empty);
    assertPaths(getFirstLevelFolders(empty),cell(0,1));
    assertPaths(getSecondLevelFolders(empty),cell(0,1));
    assertPaths(getThirdLevelFolders(empty),cell(0,1));
    onlyExcluded = fullfile(scratch,'onlyExcluded');
    mkdir(fullfile(onlyExcluded,'READme','middle','dns'));
    assertPaths(getFirstLevelFolders(onlyExcluded),cell(0,1));
    assertPaths(getSecondLevelFolders(onlyExcluded),cell(0,1));
    assertPaths(getThirdLevelFolders(onlyExcluded),cell(0,1));

    % 相对root和尾部分隔符不改变筛选边界；临时切换目录后完整恢复。
    originalDirectory = pwd;
    directoryCleanup = onCleanup(@() cd(originalDirectory));
    cd(scratch);
    relativeRoot = fullfile('READme_ancestor','ReadMe_root');
    assertPaths(getThirdLevelFolders(relativeRoot),{third;otherThird});
    assertPaths(getSecondLevelFolders([top,filesep]),{second;otherSecond});
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
    fprintf('PASS: three folder levels, branch pruning, root immunity, empty and invalid roots.\n');
end

function assertPaths(actual,expected)
    assert(iscell(actual) && size(actual,2)==1);
    assert(isequal(sort(actual),sort(expected)));
    assert(numel(unique(actual))==numel(actual));
end
