function  readAndStoreVibrationCoef(caseRawDir,caseOrgDir)
    % locate the nsread.dat
    dissipDir = fullfile(caseRawDir,'vibration.dat');

    % locate the binary store dir
    dissipBinDir = fullfile(caseOrgDir,'vibration.bin');

    % read the string
    fid = fopen(dissipDir, 'r');
    if fid > 0
        cache = textscan(fid, '%f', 1, 'headerlines', 1);
        amplitude = cache{1};
        cache = textscan(fid, '%f', 1, 'headerlines', 2);
        omega = cache{1};
        fclose(fid);
        disp(['Find vibration.dat! amplitude is ',num2str(amplitude,5),'!']);
        disp(['Find vibration.dat! angular velocity is ',num2str(omega,5),'!']);

        % save the strings
        fid = fopen(dissipBinDir, 'w');
        fwrite(fid, amplitude, 'double');
        fwrite(fid, omega, 'double');
        fclose(fid);
    else
        disp('No vibration.dat found! Skip it!');
    end

end