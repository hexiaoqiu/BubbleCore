function [] = asmCarryOnResN(asmCase,outputPath,N)
    
    [asmCase, tmpOrgLast,u2dOrgLast,v2dOrgLast,prsOrgLast] = asmInitRead(asmCase,asmCase.dnsStopTime);
    x2dSOrg = asmCase.x2dS{asmCase.readNowSubCaseIdx};
    y2dSOrg = asmCase.y2dS{asmCase.readNowSubCaseIdx};
    x2dUOrg = asmCase.x2dU{asmCase.readNowSubCaseIdx};
    y2dUOrg = asmCase.y2dU{asmCase.readNowSubCaseIdx};
    x2dVOrg = asmCase.x2dV{asmCase.readNowSubCaseIdx};
    y2dVOrg = asmCase.y2dV{asmCase.readNowSubCaseIdx};
    asmFinishRead(asmCase);
    
    
    h1 = (asmCase.x2dDroit - asmCase.x2dGauche) / N;
    h2 = (asmCase.y2dHaut - asmCase.y2dBas) / N;

    % mesh vector orthgonal in 2D system
    x2dS = asmCase.x2dGauche+h1/2:h1:asmCase.x2dDroit-h1/2;
    y2dS = (asmCase.y2dBas+h2/2:h2:asmCase.y2dHaut-h2/2)';
    x2dU = asmCase.x2dGauche:h1:asmCase.x2dDroit;
    y2dU = y2dS;
    x2dV = x2dS;
    y2dV = (asmCase.y2dBas:h2:asmCase.y2dHaut)';
    
    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', asmCase.IDGOM);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    asmCase.x2dGauche, asmCase.x2dDroit, asmCase.y2dBas, asmCase.y2dHaut);
    fprintf(fid, '%8d%8d\n', N, N);
    fprintf(fid, '%s\n', asmCase.IDSOLU);
    fprintf(fid, '%15.7E\n', asmCase.Ra);
    
    field = interp2(x2dSOrg,y2dSOrg,tmpOrgLast,x2dS,y2dS,'spline');
    writeField(fid,field);
    field = interp2(x2dUOrg,y2dUOrg,u2dOrgLast,x2dU,y2dU,'spline');
    writeField(fid,field);
    field = interp2(x2dVOrg,y2dVOrg,v2dOrgLast,x2dV,y2dV,'spline');
    writeField(fid,field);
    field = interp2(x2dSOrg,y2dSOrg,prsOrgLast,x2dS,y2dS,'spline');
    writeField(fid,field);
    fclose(fid);
    
    % check the case information
    asmPrtInfor(asmCase);
    % check the nslect header:
    disp('The header of nslect.dat is:');
    fid = fopen(fileDir,'r','n','UTF-8');
    for idxLine = 1:5
        line = fgetl(fid);
        disp(line);
    end
    fclose(fid);
end