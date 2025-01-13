function  createInitLight(bubble, t, outputPath)

    if (t>bubble.maxN)||(t<1)
        t = bubble.maxN;
    end
    
    lastTmp = readField(bubble, 'tmp', t);

    lastU2d = readField(bubble, 'u', t);

    lastV2d = readField(bubble, 'v', t);

    lastPrs = readField(bubble, 'prs', t);
    
    idgom = bubble.IDGOM;
    idsolu = bubble.IDSOLU;
    len = numel(idgom);
    for idx = len+1:1:80
        idgom(idx) = ' ';
    end
    len = numel(idsolu);
    for idx = len+1:1:80
        idsolu(idx) = ' ';
    end

    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', idgom);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    bubble.x2dGauche, bubble.x2dDroit, bubble.y2dBas, bubble.y2dHaut);
    fprintf(fid, '%8d%8d\n', bubble.n1, bubble.n2);
    fprintf(fid, '%s\n', idsolu);
    fprintf(fid, '%15.7E\n', bubble.Ra);
    writeField(fid,lastTmp);
    writeField(fid,lastU2d);
    writeField(fid,lastV2d);
    writeField(fid,lastPrs);
    fclose(fid);
    
end