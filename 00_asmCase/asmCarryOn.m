function [] = asmCarryOn(asmCase,outputPath)
    
    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', asmCase.IDGOM);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    asmCase.x2dGauche, asmCase.x2dDroit, asmCase.y2dBas, asmCase.y2dHaut);
    fprintf(fid, '%8d%8d\n', asmCase.n1(end), asmCase.n2(end));
    fprintf(fid, '%s\n', asmCase.IDSOLU);
    fprintf(fid, '%15.7E\n', asmCase.Ra);
    
    [asmCase, tmpOrgLast,u2dOrgLast,v2dOrgLast,prsOrgLast] = asmInitRead(asmCase,asmCase.dnsStopTime);
    asmFinishRead(asmCase);
    writeField(fid,tmpOrgLast);
    writeField(fid,u2dOrgLast);
    writeField(fid,v2dOrgLast);
    writeField(fid,prsOrgLast);
    fclose(fid);
    clear tmpOrgLast
    clear u2dOrgLast
    clear v2dOrgLast    
    clear prsOrgLast
    
    
    % check the case information
    % asmPrtInfor(asmCase);
    % check the nslect header:
    disp('The header of nslect.dat is:');
    fid = fopen(fileDir,'r','n','UTF-8');
    for idxLine = 1:5
        line = fgetl(fid);
        disp(line);
    end
    fclose(fid);
end