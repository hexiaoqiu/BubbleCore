function dirList = getDnsSubcaseDirList(rootPath)

    % Get contents directly under rootPath
    items = dir(rootPath);

    % Keep only folders
    isDir = [items.isdir];

    % Exclude "." and ".."
    names = {items.name};
    isDotDir = strcmp(names, '.') | strcmp(names, '..');

    % Exclude folder named "ReadMe", case-insensitive
    isReadMe = strcmpi(names, 'ReadMe');

    % Final filter
    folders = items(isDir & ~isDotDir & ~isReadMe);

    % Build full paths
    dirList = cell(numel(folders), 1);

    for i = 1:numel(folders)
        dirList{i, 1} = fullfile(folders(i).folder, folders(i).name);
    end

end


