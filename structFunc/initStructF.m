function [structF] = initStructF(binPath, config)
    structF.binPath = binPath;
    
    basicInfoDir = fullfile(structF.binPath, 'basicInformation.bin');
    id = fopen(basicInfoDir, 'r');
    structF.x2dGauche = fread(id, [1,1], 'double');
    structF.x2dDroit = fread(id, [1,1], 'double');
    structF.y2dHaut = fread(id, [1,1], 'double');
    structF.y2dBas = fread(id, [1,1], 'double');
    structF.n1 = fread(id, [1,1], 'double');
    structF.n2 = fread(id, [1,1], 'double');
    structF.Ra = fread(id, [1,1], 'double');
    structF.Ro = fread(id, [1,1], 'double');
    structF.Pr = fread(id, [1,1], 'double');
    structF.St = fread(id, [1,1], 'double');
    structF.Ff = fread(id, [1,1], 'double');
    structF.Delta = fread(id, [1,1], 'double');
    structF.maxN  = fread(id, [1,1], 'int');
    fclose(id);

    structF.h1 = (structF.x2dDroit - structF.x2dGauche) / structF.n1;
    structF.h2 = (structF.y2dHaut - structF.y2dBas) / structF.n2;

    nsDissipDir = fullfile(structF.binPath,'dissip.bin');
    fid = fopen(nsDissipDir, 'r');
    if fid > 2
        structF.dumpType = fread(fid, [1,1], 'int');
        structF.r_c = fread(fid, [1,1], 'double');
        structF.delta_r = fread(fid, [1,1], 'double');
        fclose(fid);
    else
        structF.dumpType = -1;
        structF.r_c = -1;
        structF.delta_r = -1;
    end

    x2dSDir = fullfile(structF.binPath,'org', 'x2dS.bin');
    y2dSDir = fullfile(structF.binPath,'org', 'y2dS.bin');
    x2dUDir = fullfile(structF.binPath,'org', 'x2dU.bin');
    y2dUDir = fullfile(structF.binPath,'org', 'y2dU.bin');
    x2dVDir = fullfile(structF.binPath,'org', 'x2dV.bin');
    y2dVDir = fullfile(structF.binPath,'org', 'y2dV.bin');

    id = fopen(x2dSDir,'r');
    structF.x2dS = fread(id, [1,structF.n1], 'double');
    fclose(id);
    
    id = fopen(y2dSDir, 'r');
    structF.y2dS = fread(id,[structF.n2,1],'double');
    fclose(id);

    id = fopen(x2dUDir,'r');
    structF.x2dU = fread(id, [1,structF.n1+1], 'double');
    fclose(id);
    
    id = fopen(y2dUDir,'r');
    structF.y2dU = fread(id, [structF.n2,1], 'double');
    fclose(id);

    id = fopen(x2dVDir, 'r');
    structF.x2dV = fread(id, [1,structF.n1], 'double');
    fclose(id);

    id = fopen(y2dVDir, 'r');
    structF.y2dV = fread(id, [structF.n2+1,1], 'double');
    fclose(id);

    structF.prefixU = fullfile(structF.binPath,'org','u_');
    structF.prefixV = fullfile(structF.binPath,'org','v_');
    structF.prefixTmp = fullfile(structF.binPath,'org','tmp_');
    structF.prefixVor = fullfile(structF.binPath,'org','vor_');
    structF.prefixPrs = fullfile(structF.binPath,'org','prs_');

    structF.type = config.type;
    structF.order = config.order;
    structF.d = config.d;
    structF.f = zeros(numel(structF.order),numel(structF.d));
    structF.scanWin = config.scanWin;
    structF.resolution = config.resolution;
    structF.algorithm = config.algorithm;
    structF.timeStep = config.timeStep;
    structF.itpMethod = config.itpMethod;
    structF.dVelMethod = config.vecMethod;
    structF.GPU = config.GPU;
end
