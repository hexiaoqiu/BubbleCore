function [r_c, dissipType,delta_r] = getDissip(caseRawDir)
    % locate the nsread.dat
    dissipDir = fullfile(caseRawDir,'dissip.dat');

    % read the string
    fid = fopen(dissipDir, 'r');
    if fid > 0
        cache = textscan(fid, '%f', 1, 'headerlines', 1);
        dissipType = cache{1};
        cache = textscan(fid, '%f', 1, 'headerlines', 2);
        r_c = cache{1};
        cache = textscan(fid, '%f', 1, 'headerlines', 2);
        delta_r = cache{1};
        fclose(fid);
    else
        disp('No dissip.dat found! Skip it!');
        r_c = NaN;
        dissipType = NaN;
        delta_r = NaN;
    end

end