function [tmpIni,u2dIni,v2dIni,prsIni] = asmGetIniCondt(varargin)
    narginchk(1,2)
    if nargin == 1
        asmCase = varargin{1};
        idxSubCase = 1;
    elseif nargin == 2
        asmCase = varargin{1};
        idxSubCase = varargin{2};
    end

    initFile = fullfile(asmCase.subCaseDir{idxSubCase},'nslect.dat');
    iniID = fopen(initFile, 'r','n','UTF-8');
    numSkipLine = 5;
    n1 = asmCase.n1(idxSubCase);
    n2 = asmCase.n2(idxSubCase);
    % original mesh
    x2dS = asmCase.x2dS{idxSubCase};
    y2dS = asmCase.y2dS{idxSubCase};
    x2dU = asmCase.x2dU{idxSubCase};
    y2dU = asmCase.y2dU{idxSubCase};
    x2dV = asmCase.x2dV{idxSubCase};
    y2dV = asmCase.y2dV{idxSubCase};

    % allocate field of one time step  
    tmpIni = zeros(n2, n1);
    u2dIni = zeros(n2, n1 + 1);
    v2dIni = zeros(n2 + 1, n1);
    prsIni = zeros(n2, n1);
    % calculate the quntity of numbers in one timeStep
    % tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
    % n1*n2         n2*(n1+1)               (n2+1)*n1               n1*n2;
    numFloatInOneTimeStep = n1 * n2 + (n1 + 1) * n2 + n1 * (n2 + 1) + n1 * n2;

    % read fields
    cache = textscan(iniID, '%f', numFloatInOneTimeStep, 'headerlines', numSkipLine);
    numFloat = numel(cache{1});
    if numFloat == numFloatInOneTimeStep

        headIndex = 1;
        % load tmpOrg Temperature
        for j = 1:n2
            y = y2dS(j);
            for i = 1:n1
                x = x2dS(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    tmpIni(j, i) = cache{1}(headIndex);   
                else
                    tmpIni(j, i) = 1;
                end
                headIndex = headIndex + 1;
            end
        end
        % load u2dOrg
        for j = 1:n2
            y = y2dU(j);
            for i = 1:(n1 + 1)
                x = x2dU(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    u2dIni(j, i) = cache{1}(headIndex);   
                else
                    u2dIni(j, i) = 0;
                end
                headIndex = headIndex + 1;
            end
        end
        % load v2dOrg
        for j = 1:(n2 + 1)
            y = y2dV(j);
            for i = 1:n1
                x = x2dV(i);
                r = sqrt(x^2+y^2);
                if r < 1
                    v2dIni(j, i) = cache{1}(headIndex);   
                else
                    v2dIni(j, i) = 0;
                end
                headIndex = headIndex + 1;
            end
        end
        % load prsOrg
        for j = 1:n1
            for i = 1:n2
                prsIni(j, i) = cache{1}(headIndex);   
                headIndex = headIndex + 1;
            end
        end
        
    else

        tmpIni(:) = 0;
        u2dIni(:) = 0;
        v2dIni(:) = 0;
        prsIni(:) = 0;

    end
    fclose(iniID);

end