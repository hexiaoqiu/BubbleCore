function s = getSubFolder(src)
%GETSUBFOLDER 返回合规的直接子目录路径，保持dir顺序和输入路径形式。
% 只检查src以下子目录名；包含readme（忽略大小写）的目录及其分支不进入结果。
% src自身和祖先不检查；显式以某个readme目录为src时，仍扫描它的子目录。

    % 按名称排除点目录、普通文件和readme目录，不假设点目录排在前两项。
    folder = dir(src);
    names = {folder.name};
    isDotDir = ismember(names, {'.', '..'});
    isReadMe = contains(names, 'readme', 'IgnoreCase', true);
    subfolder = folder([folder.isdir] & ~isDotDir & ~isReadMe);

    % 保留相对输入对应相对输出的约定；空结果为0×1 cell。
    s = cell(numel(subfolder), 1);
    for i = 1:numel(subfolder)
        s{i,1} = fullfile(src, subfolder(i).name);
    end
end

