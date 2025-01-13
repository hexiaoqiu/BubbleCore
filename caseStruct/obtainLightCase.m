function [lightCase] = obtainLightCase(path)

    nsDissipDir = fullfile(path,'dissip.bin');
    fid = fopen(nsDissipDir, 'r');
    if fid > 2
        lightCase.dumpType = fread(fid, [1,1], 'int');
        lightCase.r_c = fread(fid, [1,1], 'double');
        lightCase.delta_r = fread(fid, [1,1], 'double');
        fclose(fid);
    else
        lightCase.dumpType = nan;
        lightCase.r_c = nan;
        lightCase.delta_r = nan;
    end

    nsVibDir = fullfile(path,'vibration.bin');
    fid = fopen(nsVibDir, 'r');
    if fid > 2
        lightCase.amp = fread(fid, [1,1], 'double');
        lightCase.omega = fread(fid, [1,1], 'double');
        fclose(fid);
    else
        lightCase.amp = nan;
        lightCase.omega = nan;
    end

    lightCase.path = path;
    lightCase.basicInfoDir = fullfile(path, 'basicInformation.bin');
    id = fopen(lightCase.basicInfoDir, 'r');

    lightCase.x2dGauche = fread(id, [1,1], 'double');
    lightCase.x2dDroit = fread(id, [1,1], 'double');
    lightCase.y2dHaut = fread(id, [1,1], 'double');
    lightCase.y2dBas = fread(id, [1,1], 'double');
    lightCase.n1 = fread(id, [1,1], 'double');
    lightCase.n2 = fread(id, [1,1], 'double');
    lightCase.Ra = fread(id, [1,1], 'double');
    lightCase.Ro = fread(id, [1,1], 'double');
    lightCase.Pr = fread(id, [1,1], 'double');
    lightCase.St = fread(id, [1,1], 'double');
    lightCase.Ff = fread(id, [1,1], 'double');
    lightCase.Delta = fread(id, [1,1], 'double');
    lightCase.maxN  = fread(id, [1,1], 'int');
    lightCase.time  = fread(id, [1,1], 'double');
    lightCase.dt  = fread(id, [1,1], 'double');
    lightCase.dtSave  = fread(id, [1,1], 'double');
    fclose(id);


    lightCase.h1 = (lightCase.x2dDroit - lightCase.x2dGauche) / lightCase.n1;
    lightCase.h2 = (lightCase.y2dHaut - lightCase.y2dBas) / lightCase.n2;

    nsStringDir = fullfile(path,'nsString.dat');
    fid = fopen(nsStringDir);
    if fid > 2
        cache = textscan(fid, '%s', 1, 'Delimiter', '\n');
        lightCase.IDGOM = cache{1}{1};
        cache = textscan(fid, '%s', 1, 'Delimiter', '\n');
        lightCase.IDSOLU = cache{1}{1};
        fclose(fid);
    end

    

    x2dSDir = fullfile(path,'org', 'x2dS.bin');
    y2dSDir = fullfile(path,'org', 'y2dS.bin');
    x2dUDir = fullfile(path,'org', 'x2dU.bin');
    y2dUDir = fullfile(path,'org', 'y2dU.bin');
    x2dVDir = fullfile(path,'org', 'x2dV.bin');
    y2dVDir = fullfile(path,'org', 'y2dV.bin');

    id = fopen(x2dSDir,'r');
    lightCase.x2dS = fread(id, [1,lightCase.n1], 'double');
    fclose(id);
    
    id = fopen(y2dSDir, 'r');
    lightCase.y2dS = fread(id,[lightCase.n2,1],'double');
    fclose(id);

    id = fopen(x2dUDir,'r');
    lightCase.x2dU = fread(id, [1,lightCase.n1+1], 'double');
    fclose(id);
    
    id = fopen(y2dUDir,'r');
    lightCase.y2dU = fread(id, [lightCase.n2,1], 'double');
    fclose(id);

    id = fopen(x2dVDir, 'r');
    lightCase.x2dV = fread(id, [1,lightCase.n1], 'double');
    fclose(id);

    id = fopen(y2dVDir, 'r');
    lightCase.y2dV = fread(id, [lightCase.n2+1,1], 'double');
    fclose(id);

    lightCase.rootFileNameU = 'u_';
    lightCase.rootFileNameV = 'v_';
    lightCase.rootFileNameTmp = 'tmp_';
    lightCase.rootFileNameVor = 'vor_';
    lightCase.rootFileNamePrs = 'prs_';

end