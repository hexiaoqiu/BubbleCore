function  transString(caseRawDir,caseOrgDir)

    [IDGOM, IDSOLU] = getString(caseRawDir);
    
    % locate the binary store dir
    nsStringDir = fullfile(caseOrgDir,'nsString.dat');

    % save the strings
    fid = fopen(nsStringDir, 'w');
    fprintf(fid, '%s', IDGOM);
    fprintf(fid,'\n');
    fprintf(fid, '%s', IDSOLU);
    fclose(fid);

end