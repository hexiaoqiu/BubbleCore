function allGood = outputInitSolutionWithResolution(varargin)
    if nargin == 3
        bubble      = varargin{1};
        outputPath  = varargin{2};
        resolutionN = varargin{3};
        timeStep    = bubble.maxN;
        u2d         = readField(bubble, 'u', timeStep);
        v2d         = readField(bubble, 'v', timeStep);
        tmp         = readField(bubble, 'tmp', timeStep);
        prs         = readField(bubble, 'prs', timeStep);
    elseif nargin == 4
        bubble      = varargin{1};
        outputPath  = varargin{2};
        timeStep    = varargin{3};
        resolutionN = varargin{4};
        u2d         = readField(bubble, 'u', timeStep);
        v2d         = readField(bubble, 'v', timeStep);
        tmp         = readField(bubble, 'tmp', timeStep);
        prs         = readField(bubble, 'prs', timeStep);
    elseif nargin == 7
        bubble     = varargin{1};
        outputPath = varargin{2};
        u2d        = varargin{3};
        v2d        = varargin{4};
        tmp        = varargin{5};
        prs        = varargin{6};
        resolutionN = varargin{7};
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

    % change resolution by interpolating
    x2dSOut = linspace(bubble.x2dS(1),bubble.x2dS(end),resolutionN);
    y2dSOut = linspace(bubble.y2dS(1),bubble.y2dS(end),resolutionN)';

    x2dUOut = linspace(bubble.x2dU(1),bubble.x2dU(end),resolutionN+1);
    y2dUOut = linspace(bubble.y2dU(1),bubble.y2dU(end),resolutionN)';
    
    x2dVOut = linspace(bubble.x2dV(1),bubble.x2dV(end),resolutionN);
    y2dVOut = linspace(bubble.y2dV(1),bubble.y2dV(end),resolutionN+1)';

    tmpOut = interp2(bubble.x2dS,bubble.y2dS,tmp,x2dSOut,y2dSOut,'spline');
    u2dOut = interp2(bubble.x2dU,bubble.y2dU,u2d,x2dUOut,y2dUOut,'spline');
    v2dOut = interp2(bubble.x2dV,bubble.y2dV,v2d,x2dVOut,y2dVOut,'spline');
    prsOut = interp2(bubble.x2dS,bubble.y2dS,prs,x2dSOut,y2dSOut,'spline');

    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', idgom);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    bubble.x2dGauche, bubble.x2dDroit, bubble.y2dBas, bubble.y2dHaut);
    fprintf(fid, '%8d%8d\n', resolutionN, resolutionN);
    fprintf(fid, '%s\n', idsolu);
    fprintf(fid, '%15.7E\n', bubble.Ra);

    writeField(fid,tmpOut);
    writeField(fid,u2dOut);
    writeField(fid,v2dOut);
    writeField(fid,prsOut);
    fclose(fid);

    allGood = true;

end