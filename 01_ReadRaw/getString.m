function  [IDGOM, IDSOLU] = getString(caseRawDir)
    % locate the nsread.dat
    nsreadDir = fullfile(caseRawDir,'nsread.dat');

    % read the string
    [fid, errmsg ]= fopen(nsreadDir, 'r');
    if isempty(errmsg)
        cache = textscan(fid, '%s', 1, 'headerlines', 9, 'Delimiter', '\n');
        IDGOM = cache{1}{1};
        cache = textscan(fid, '%s', 1, 'headerlines', 9, 'Delimiter', '\n');
        IDSOLU = cache{1}{1};
        fclose(fid);
    else
        disp(errmsg);
        return
    end

end