function [finish] = makeHighTmpInit(caseRawDir,tmpInitValue,outputPath)

    % get information
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, ...
        n1, n2, maxN,dt,dtSave] = getCoefs(caseRawDir);
    [IDGOM, IDSOLU] = getString(caseRawDir);
    [r_c, ~,~] = getDissip(caseRawDir);
    
    dispCoefKey(Ra,Pr,R0,Delta,r_c,St,Ff,maxN,dt,dtSave);
    disp(['Initial Temperature = ',num2str(tmpInitValue,'%g')])

    h1 = (x2dDroit - x2dGauche) / n1;
    h2 = (y2dHaut - y2dBas) / n2;
    
    % mesh vector orthgonal in 2D system
    x2dS = x2dGauche+h1/2:h1:x2dDroit-h1/2;
    y2dS = y2dBas+h2/2:h2:y2dHaut-h2/2;
    
    tmpInit = zeros(n2,n1);
    for idx = 1:n1
        for idy = 1:n2
            x2d = x2dS(idx);
            y2d = y2dS(idy);
            r = sqrt(x2d^2 + y2d^2);
            if r <= r_c
                tmpInit(idy,idx) = 0;
            elseif r <= 1
                tmpInit(idy,idx) = tmpInitValue;
            else
                tmpInit(idy,idx) = 1;
            end
        end
    end
    
    prsInit = zeros(n2,n1);
    u2dInit = zeros(n2,n1+1);
    v2dInit = zeros(n2+1,n1);
    
    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', IDGOM);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    x2dGauche, x2dDroit, y2dBas, y2dHaut);
    fprintf(fid, '%8d%8d\n', n1, n2);
    fprintf(fid, '%s\n', IDSOLU);
    fprintf(fid, '%15.7E\n', Ra);

    writeField(fid,tmpInit);
    writeField(fid,prsInit);
    writeField(fid,u2dInit);
    writeField(fid,v2dInit);
    fclose(fid);
    finish = true;

end