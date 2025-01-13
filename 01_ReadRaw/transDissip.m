function  transDissip(caseRawDir,caseOrgDir)
    
    [r_c, dissipType,delta_r] = getDissip(caseRawDir);

    % locate the binary store dir
    dissipBinDir = fullfile(caseOrgDir,'dissip.bin');
    % save the dissip infor
    fid = fopen(dissipBinDir, 'w');
    fwrite(fid, dissipType, 'int');
    fwrite(fid, r_c, 'double');
    fwrite(fid, delta_r, 'double');
    fclose(fid);

end