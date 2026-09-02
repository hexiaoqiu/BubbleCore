function allCaseDirList = getFirstLevelFolders(rootDir)
%GETFIRSTLEVELFOLDERS 获取指定目录下所有第一级文件夹的完整路径
%
% 输入：
%   rootDir - 根目录，例如：
%       '/Volumes/G-DRIVE PRO/DNS_Data/SpotsOnBubble/'
%
% 输出：
%   allCaseDirList - 包含所有第一级文件夹完整路径的列 cell 数组。
%                    路径中包含 "readme"（忽略大小写）的目录会被排除。

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

    % 组合成完整路径，并存入列 cell 数组
    allCaseDirList = arrayfun( ...
        @(item) fullfile(item.folder, item.name), ...
        folderInfo, ...
        'UniformOutput', false ...
    );

    allCaseDirList = allCaseDirList(:);
    containsReadme = contains( ...
        allCaseDirList, 'readme', 'IgnoreCase', true);
    allCaseDirList(containsReadme) = [];
end
