function outputInitSolution(varargin)
    if nargin == 2
        bubble      = varargin{1};
        outputPath  = varargin{2};
        timeStep    = bubble.maxN;
        u2d         = readField(bubble, 'u', timeStep);
        v2d         = readField(bubble, 'v', timeStep);
        tmp         = readField(bubble, 'tmp', timeStep);
        prs         = readField(bubble, 'prs', timeStep);
    elseif nargin == 3
        bubble      = varargin{1};
        outputPath  = varargin{2};
        timeStep    = varargin{3};
        u2d         = readField(bubble, 'u', timeStep);
        v2d         = readField(bubble, 'v', timeStep);
        tmp         = readField(bubble, 'tmp', timeStep);
        prs         = readField(bubble, 'prs', timeStep);
    elseif nargin == 6
        bubble     = varargin{1};
        outputPath = varargin{2};
        u2d        = varargin{3};
        v2d        = varargin{4};
        tmp        = varargin{5};
        prs        = varargin{6};
    end

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
    writeField(fid,tmp);
    writeField(fid,u2d);
    writeField(fid,v2d);
    writeField(fid,prs);
    fclose(fid);

end