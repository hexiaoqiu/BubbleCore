function allCaseDirList = getFirstLevelFolders(rootDir)
%GETFIRSTLEVELFOLDERS 获取指定目录下所有第一级文件夹的完整路径
%
% 输入：
%   rootDir - 根目录，例如：
%       '/Volumes/G-DRIVE PRO/DNS_Data/SpotsOnBubble/'
%
% 输出：
%   allCaseDirList - 包含所有第一级文件夹完整路径的列 cell 数组。
%                    排除子目录名称包含 "readme" 的分支（忽略大小写）。
%                    只检查rootDir以下的目录，rootDir本身及其上级不参与判断。

    arguments
        rootDir (1, :) char
    end

    if ~isfolder(rootDir)
        error('指定的根目录不存在：%s', rootDir);
    end

    % 获取第一级目录：
    % rootDir/第一级
    folderInfo = dir(fullfile(rootDir, '*'));

    % 仅保留文件夹，并排除 "." 和 ".."
    folderInfo = folderInfo([folderInfo.isdir]);
    folderInfo = folderInfo(~ismember({folderInfo.name}, {'.', '..'}));

    % 只检查当前这一层的子目录名称；被排除的目录不会传给下一层遍历。
    containsReadme = contains( ...
        {folderInfo.name}, 'readme', 'IgnoreCase', true);
    folderInfo(containsReadme) = [];

    % 组合成完整路径，并存入列 cell 数组
    allCaseDirList = cell(numel(folderInfo),1);
    for index = 1:numel(folderInfo)
        allCaseDirList{index} = fullfile(folderInfo(index).folder,folderInfo(index).name);
    end
end
