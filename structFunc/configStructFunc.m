function StFn = configStructFunc(path,order,d)
    StFn.path = path;
    StFn.basicInfoDir = fullfile(StFn.path, 'basicInformation.bin');
    id = fopen(StFn.basicInfoDir, 'r');

    StFn.x2dGauche = fread(id, [1,1], 'double');
    StFn.x2dDroit = fread(id, [1,1], 'double');
    StFn.y2dHaut = fread(id, [1,1], 'double');
    StFn.y2dBas = fread(id, [1,1], 'double');
    StFn.n1 = fread(id, [1,1], 'double');
    StFn.n2 = fread(id, [1,1], 'double');
    StFn.Ra = fread(id, [1,1], 'double');
    StFn.Ro = fread(id, [1,1], 'double');
    StFn.Pr = fread(id, [1,1], 'double');
    StFn.St = fread(id, [1,1], 'double');
    StFn.Ff = fread(id, [1,1], 'double');
    StFn.Delta = fread(id, [1,1], 'double');
    StFn.maxN  = fread(id, [1,1], 'int');
    fclose(id);

    StFn.h1 = (StFn.x2dDroit - StFn.x2dGauche) / StFn.n1;
    StFn.h2 = (StFn.y2dHaut - StFn.y2dBas) / StFn.n2;

    nsDissipDir = fullfile(StFn.path,'dissip.bin');
    fid = fopen(nsDissipDir, 'r');
    if fid > 2
        StFn.dumpType = fread(fid, [1,1], 'int');
        StFn.r_c = fread(fid, [1,1], 'double');
        StFn.delta_r = fread(fid, [1,1], 'double');
        fclose(fid);
    else
        StFn.dumpType = -1;
        StFn.r_c = -1;
        StFn.delta_r = -1;
    end

    x2dSDir = fullfile(StFn.path,'org', 'x2dS.bin');
    y2dSDir = fullfile(StFn.path,'org', 'y2dS.bin');
    x2dUDir = fullfile(StFn.path,'org', 'x2dU.bin');
    y2dUDir = fullfile(StFn.path,'org', 'y2dU.bin');
    x2dVDir = fullfile(StFn.path,'org', 'x2dV.bin');
    y2dVDir = fullfile(StFn.path,'org', 'y2dV.bin');

    id = fopen(x2dSDir,'r');
    StFn.x2dS = fread(id, [1,StFn.n1], 'double');
    fclose(id);
    
    id = fopen(y2dSDir, 'r');
    StFn.y2dS = fread(id,[StFn.n2,1],'double');
    fclose(id);

    id = fopen(x2dUDir,'r');
    StFn.x2dU = fread(id, [1,StFn.n1+1], 'double');
    fclose(id);
    
    id = fopen(y2dUDir,'r');
    StFn.y2dU = fread(id, [StFn.n2,1], 'double');
    fclose(id);

    id = fopen(x2dVDir, 'r');
    StFn.x2dV = fread(id, [1,StFn.n1], 'double');
    fclose(id);

    id = fopen(y2dVDir, 'r');
    StFn.y2dV = fread(id, [StFn.n2+1,1], 'double');
    fclose(id);

    StFn.rootFileNameU = 'u_';
    StFn.rootFileNameV = 'v_';
    StFn.rootFileNameTmp = 'tmp_';
    StFn.rootFileNameVor = 'vor_';
    StFn.rootFileNamePrs = 'prs_';


    StFn.field = 'null';
    StFn.order = order;
    StFn.d = d;
    StFn.f = zeros(numel(StFn.order),numel(StFn.d));
    StFn.scanWindow = [0,360,0,89];
    StFn.resolution = [100,100];
    StFn.algorithm = 'theta';
    StFn.timeStepList = (1:1:StFn.maxN)';
    StFn.itpMethod = 'linear';
    StFn.dVelMethod = 'l';
end