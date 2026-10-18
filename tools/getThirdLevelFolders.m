function allCaseDirList = getThirdLevelFolders(rootDir)
%GETTHIRDLEVELFOLDERS 获取指定目录下全部合规的第三级文件夹完整路径。
%   返回列cell数组。rootDir以下任一层目录名称包含readme（忽略大小写），
%   就排除该目录及其全部后代；rootDir本身及其上级路径不参与检查。

    arguments
        rootDir (1, :) char
    end

    %% 先取得已逐层筛选的上一级目录，不进入被排除的分支
    parentDirectories = getSecondLevelFolders(rootDir);
    allCaseDirList = cell(0,1);

    %% 仅遍历合规父目录的直接子目录，保持精确层级
    for index = 1:numel(parentDirectories)
        childDirectories = getFirstLevelFolders(parentDirectories{index});
        allCaseDirList = [allCaseDirList;childDirectories]; %#ok<AGROW> 按目录分支累加路径，不读取流场
    end
end
