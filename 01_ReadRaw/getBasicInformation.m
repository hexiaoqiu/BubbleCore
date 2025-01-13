function [x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, Ra, R0, Pr, St, Ff] = getBasicInformation(caseRawDir)

        % locate the raw data file
        nssaveDir = fullfile(caseRawDir, 'nssave.dat');
        
        %   Open File
        fid = fopen(nssaveDir);
        % read the head line
        idgeom = textscan(fid, '%80c', 1);
        % read the boundaries of computational domain
        xyd = textscan(fid, '%f %f %f %f', 1);
        x2dGauche = xyd{1}; % x1 gauche
        x2dDroit = xyd{2}; % x1 droite
        y2dBas = xyd{3}; % x2 bas
        y2dHaut = xyd{4}; % x2 haut
        % read the resolution of discretization
        n = textscan(fid, '%f %f', 1);
        n1 = n{1};
        n2 = n{2};
        % read ciefficients
        timeNote = textscan(fid, '%s %s %f', 1);
        cache = textscan(fid, '%s', 1);
        raNote = cache{1}{1};
        cache = textscan(fid, '%s', 1);
        prNote = cache{1}{1};
        cache = textscan(fid, '%s', 1);
        stNote = cache{1}{1};
        cache = textscan(fid, '%s', 1);
        r0Note = cache{1}{1};
        cache = textscan(fid, '%s', 1);
        ffNote = cache{1}{1};
    
        Ra = str2double(raNote(4:end));
        R0 = str2double(r0Note(4:end));
        Pr = str2double(prNote(4:end));
        St = str2double(stNote(4:end));
        Ff = str2double(ffNote(4:end));
        % close file
        fclose(fid);
        

end