function [tmpIni,u2dIni,v2dIni,prsIni] = rawReadIniCondition(caseRawDir)
    
    [~, ~, ~, ~, ~, ~,~, ~, ~, ~, n1, n2, ~,~,~] = getCoefs(caseRawDir);

    % allocate field of one time step  
    tmpIni = zeros(n2, n1);
    u2dIni = zeros(n2, n1 + 1);
    v2dIni = zeros(n2 + 1, n1);
    prsIni = zeros(n2, n1);
    % calculate the quntity of numbers in one timeStep
    % tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
    % n1*n2         n2*(n1+1)               (n2+1)*n1               n1*n2;
    numFloatInOneTimeStep = n1 * n2 + (n1 + 1) * n2 + n1 * (n2 + 1) + n1 * n2;
    
    nslectPath = fullfile(caseRawDir,'nslect.dat');
    nslectID = fopen(nslectPath,'r','n','UTF-8');
    numSkipLine = 5;
    % read fields
    cache = textscan(nslectID, '%f', numFloatInOneTimeStep, 'headerlines', numSkipLine);
    if numel(cache{1}) ~= numFloatInOneTimeStep
        tmpIni(:) = 0;
        u2dIni(:) = 0;
        v2dIni(:) = 0;
        prsIni(:) = 0;
    else
        headIndex = 1;
        % load tmpOrg Temperature
        for j = 1:n2
            for i = 1:n1
                tmpIni(j, i) = cache{1}(headIndex);    
                headIndex = headIndex + 1;
            end
        end
        % load u2dOrg
        for j = 1:n2
            for i = 1:(n1 + 1)
                u2dIni(j, i) = cache{1}(headIndex);
                headIndex = headIndex + 1;
            end
        end
        % load v2dOrg
        for j = 1:(n2 + 1)
            for i = 1:n1
                v2dIni(j, i) = cache{1}(headIndex);
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
    end

end