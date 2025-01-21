function [Amp_vib, Omega_vib] = getVibration(caseRawDir)
    % locate the nsread.dat
    vibDir = fullfile(caseRawDir,'vibration.dat');

    % read the string
    fid = fopen(vibDir, 'r');
    if fid > 0
        cache = textscan(fid, '%f', 1, 'headerlines', 1);
        Amp_vib = cache{1};
        cache = textscan(fid, '%f', 1, 'headerlines', 2);
        Omega_vib = cache{1};
        fclose(fid);
    else
        disp('No dissip.dat found! Skip it!');
        Amp_vib = NaN;
        Omega_vib = NaN;
    end

end