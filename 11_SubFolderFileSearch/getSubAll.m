function s = getSubAll(src)
    folder = dir(src);
    subfolder = folder(3:end);
    s = [];
    length(subfolder)
    for i = 1:length(subfolder)
        path = [src, '/', subfolder(i).name];
        if isfile(path)
            s = [s, string(path)];
        end
        if isfolder(path)
            subpath = getFiles(path);
            s = [s, subpath];
        end
    end
end