function [finish] = outputLastStepRawBin(varargin)

    if nargin == 2
        rawCaseDir  = varargin{1};
        outputPath  = varargin{2};
        resolutionN = NaN;
    elseif nargin == 3
        rawCaseDir  = varargin{1};
        outputPath  = varargin{2};
        resolutionN = varargin{3};
    end
    
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(rawCaseDir);
    [tmpOrgLast, u2dOrgLast, v2dOrgLast, prsOrgLast] = getLastStepForRaw(rawCaseDir);
    [IDGOM, IDSOLU] = getString(rawCaseDir);
    [r_c, dissipType,delta_r] = getDissip(rawCaseDir);

    dispCoefKey(Ra,Pr,R0,Delta,r_c,St,Ff,maxN,dt,dtSave);

    if isempty(tmpOrgLast)&&isempty(u2dOrgLast)&&isempty(v2dOrgLast)&&isempty(prsOrgLast)
        finish = false;
        return
    end
    
    if ~isnan(resolutionN)
        disp(['Changing resolution from ',num2str(n1,'%d'),' to ',num2str(resolutionN,'%d')])
        h1 = (x2dDroit - x2dGauche) / n1;
        h2 = (y2dHaut - y2dBas) / n2;
    
        % mesh vector orthgonal in 2D system
        x2dS = x2dGauche+h1/2:h1:x2dDroit-h1/2;
        y2dS = y2dBas+h2/2:h2:y2dHaut-h2/2;
        x2dU = x2dGauche:h1:x2dDroit;
        y2dU = y2dS;
        x2dV = x2dS;
        y2dV = y2dBas:h2:y2dHaut;
    
        % change resolution by interpolating
        x2dSOut = linspace(x2dS(1),x2dS(end),resolutionN);
        y2dSOut = linspace(y2dS(1),y2dS(end),resolutionN)';
    
        x2dUOut = linspace(x2dU(1),x2dU(end),resolutionN+1);
        y2dUOut = linspace(y2dU(1),y2dU(end),resolutionN)';
        
        x2dVOut = linspace(x2dV(1),x2dV(end),resolutionN);
        y2dVOut = linspace(y2dV(1),y2dV(end),resolutionN+1)';
    
        tmpOrgLast = interp2(x2dS,y2dS,tmpOrgLast,x2dSOut,y2dSOut,'spline');
        u2dOrgLast = interp2(x2dU,y2dU,u2dOrgLast,x2dUOut,y2dUOut,'spline');
        v2dOrgLast = interp2(x2dV,y2dV,v2dOrgLast,x2dVOut,y2dVOut,'spline');
        prsOrgLast = interp2(x2dS,y2dS,prsOrgLast,x2dSOut,y2dSOut,'spline');
    end

    fileDir = fullfile(outputPath,'nslect.dat');
    fid = fopen(fileDir,'w');
    fprintf(fid,'%s\n', IDGOM);
    fprintf(fid,'%15.7E%15.7E%15.7E%15.7E\n', ...,
    x2dGauche, x2dDroit, y2dBas, y2dHaut);
    fprintf(fid, '%8d%8d\n', resolutionN, resolutionN);
    fprintf(fid, '%s\n', IDSOLU);
    fprintf(fid, '%15.7E\n', Ra);

    writeField(fid,tmpOrgLast);
    writeField(fid,u2dOrgLast);
    writeField(fid,v2dOrgLast);
    writeField(fid,prsOrgLast);
    fclose(fid);
    finish = true;


end