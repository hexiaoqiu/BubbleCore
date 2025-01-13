function s = getSubFolder(src)
    folder = dir(src);
    subfolder = folder(3:end);
    s = cell(1);
    idxFolder = 0;
    for i = 1:length(subfolder)
        path = [src, '/', subfolder(i).name];
        if isfolder(path)
            idxFolder = idxFolder + 1;
            s{idxFolder,1} = path;
        end
    end
end

