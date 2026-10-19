function dirList = getDnsSubcaseDirList(rootPath)
%GETDNSSUBCASEDIRLIST 按dir原有顺序返回合规的直接子case目录（列cell）。
% 只检查rootPath以下的子目录名称；名称包含readme（忽略大小写）即排除。
% rootPath自身及其上级名称不参与检查；不递归、不做数值排序。

    % 列举直接子目录，保留dir的顺序，避免改变续算子case的拼接顺序。
    items = dir(rootPath);

    % 排除普通文件和点目录。
    isDir = [items.isdir];

    names = {items.name};
    isDotDir = strcmp(names, '.') | strcmp(names, '..');

    % 仅检查当前子目录名称，不能对完整路径做readme匹配。
    isReadMe = contains(names, 'readme', 'IgnoreCase', true);

    % 被排除的目录不会交给下游，因此其后代也不会进入自动发现流程。
    folders = items(isDir & ~isDotDir & ~isReadMe);

    % 返回完整路径列cell；无合规子目录时返回0×1 cell。
    dirList = cell(numel(folders), 1);

    for i = 1:numel(folders)
        dirList{i, 1} = fullfile(folders(i).folder, folders(i).name);
    end

end


