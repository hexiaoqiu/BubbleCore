% **************************************************************************************************
% Author: Xiaoqiu HE
% Date  : 2026/02/28 at HUST
% **************************************************************************************************
% Purpose:
%   Build a dns structure used to manipulate and assemble a series of DNS subcases.
%
% Attention:
%   The cases in <subCaseDirList> should be sequenced.
%
% Updates:
%   2026/02/28:
%       将 AmsCase 改为 dnsCase，命名更加清晰，相应函数代码迁移到 setDnsCase，
%       输出结构体默认名字也是 dns。
%
%   2026/07/01:
%       1. 先检查数据文件，删除没有 nssave.bin / nssave.dat 的 subcase；
%       2. 再读取 realMaxN，删除 realMaxN == 0 的 subcase；
%       3. 在清理无效 subcase 之后，再计算 startTime / endTime / time；
%       4. 增加全局帧索引信息：
%           dns.globalFrameStart
%           dns.globalFrameEnd
%           dns.globalFrameRange
%           dns.globalFrameSubCase
%           dns.globalFrameLocal
%       5. 增加 dns.timeLine 作为 dns.time 的别名。
% **************************************************************************************************

function [dns] = getDNS(varargin)

    narginchk(1, 2);

    if nargin == 1
        subCaseDirList = varargin{1};
        dns = struct();
    elseif nargin == 2
        subCaseDirList = varargin{1};
        dns = varargin{2};
    end

    % ==============================================================================================
    % Normalize input subCaseDirList
    % ==============================================================================================
    if ischar(subCaseDirList)
        subCaseDirList = {subCaseDirList};
    elseif isstring(subCaseDirList)
        subCaseDirList = cellstr(subCaseDirList);
    end

    if ~iscell(subCaseDirList)
        error('subCaseDirList should be a cell array, string array, or char array.')
    end

    subCaseDirList = reshape(subCaseDirList, 1, []);

    dns.numSubCase = numel(subCaseDirList);
    dns.subCaseDir = subCaseDirList;

    if dns.numSubCase == 0
        error('subCaseDirList is empty.')
    end

    % ==============================================================================================
    % Check data file type for all subcases
    % Remove subcases without nssave.bin or nssave.dat
    % ==============================================================================================
    dns.type = cell(1, dns.numSubCase);
    dns.dataFileName = cell(1, dns.numSubCase);

    idxSubCase = 0;

    while idxSubCase < dns.numSubCase

        idxSubCase = idxSubCase + 1;

        disp(['In subCase: ', dns.subCaseDir{idxSubCase}])

        filePathBin = fullfile(dns.subCaseDir{idxSubCase}, 'nssave.bin');
        filePathTxt = fullfile(dns.subCaseDir{idxSubCase}, 'nssave.dat');

        if exist(filePathBin, "file") == 2

            dns.type{idxSubCase} = 'bin';
            dns.dataFileName{idxSubCase} = 'nssave.bin';
            disp('Data is stored in binary form!')

        elseif exist(filePathTxt, "file") == 2

            dns.type{idxSubCase} = 'txt';
            dns.dataFileName{idxSubCase} = 'nssave.dat';
            disp('Data is stored in text form!')

        else

            disp(['No data file is found in ', dns.subCaseDir{idxSubCase}])
            disp('Deleting it from the sub directory list!')

            dns.subCaseDir(idxSubCase) = [];
            dns.type(idxSubCase) = [];
            dns.dataFileName(idxSubCase) = [];

            idxSubCase = idxSubCase - 1;
            dns.numSubCase = dns.numSubCase - 1;

        end

    end

    if dns.numSubCase == 0
        error('No valid subCase is found! No nssave.bin or nssave.dat exists.')
    end

    % ==============================================================================================
    % Check real number of saved frames for each subcase
    % Remove subcases with realMaxN == 0
    % ==============================================================================================
    dns.maxN = zeros(1, dns.numSubCase);

    for idxSubCase = 1:dns.numSubCase

        filePathRealMaxN = fullfile(dns.subCaseDir{idxSubCase}, 'realMaxN.txt');

        if exist(filePathRealMaxN, 'file') == 2

            fileIDRealMaxN = fopen(filePathRealMaxN, 'r', 'n');

            if fileIDRealMaxN < 0
                error(['Cannot open realMaxN.txt in ', dns.subCaseDir{idxSubCase}])
            end

            cache = textscan(fileIDRealMaxN, '%n', 'HeaderLines', 1);
            coefs = cell2mat(cache);
            fclose(fileIDRealMaxN);

            if isempty(coefs)
                error(['realMaxN.txt is empty or invalid in ', dns.subCaseDir{idxSubCase}])
            end

            realMaxN = coefs(1);

        else

            disp(['No real MaxN record is found! Check it by going through ', ...
                  dns.subCaseDir{idxSubCase}, ' !'])

            if strcmp(dns.type{idxSubCase}, 'bin')
                realMaxN = asmGetRealMaxNBin(dns.subCaseDir{idxSubCase});
            else
                realMaxN = asmGetRealMaxNTxt(dns.subCaseDir{idxSubCase});
            end

            disp('Get Real MaxN! Write it to realMaxN.txt!')

            fileIDRealMaxN = fopen(filePathRealMaxN, 'w', 'n');

            if fileIDRealMaxN < 0
                error(['Cannot write realMaxN.txt in ', dns.subCaseDir{idxSubCase}])
            end

            fprintf(fileIDRealMaxN, 'Real MaxN \n');
            fprintf(fileIDRealMaxN, '%d', realMaxN);
            fclose(fileIDRealMaxN);

        end

        dns.maxN(idxSubCase) = realMaxN;

    end

    % Remove subcases with realMaxN == 0.
    idxInvalidSubCase = find(dns.maxN == 0);
    idxValidSubCase   = find(dns.maxN >  0);

    if ~isempty(idxInvalidSubCase)

        disp('The following subCases have realMaxN == 0 and will be removed from dns:')

        for k = 1:numel(idxInvalidSubCase)
            idx = idxInvalidSubCase(k);
            disp(['No. ', num2str(idx, '%d'), ' subCase: ', dns.subCaseDir{idx}])
        end

        dns.subCaseDir   = dns.subCaseDir(idxValidSubCase);
        dns.type         = dns.type(idxValidSubCase);
        dns.dataFileName = dns.dataFileName(idxValidSubCase);
        dns.maxN         = dns.maxN(idxValidSubCase);

        dns.numSubCase = numel(idxValidSubCase);

    end

    if dns.numSubCase == 0
        error('No valid subCase is found! All subCases have realMaxN == 0.')
    end

    % ==============================================================================================
    % Get strings from the first valid subcase
    % ==============================================================================================
    [IDGOM, IDSOLU] = getString(dns.subCaseDir{1});

    dns.IDGOM = IDGOM;
    dns.IDSOLU = IDSOLU;

    % ==============================================================================================
    % Read reference physical and computational parameters from the first valid subcase
    % ==============================================================================================
    [Ra_ref, Pr_ref, St_ref, R0_ref, Ff_ref, Delta_ref, ...
     x2dGauche_ref, x2dDroit_ref, y2dBas_ref, y2dHaut_ref, ...
     n1_ref, n2_ref, maxNPlan_ref, dt_ref, dtSave_ref] ...
        = getCoefs(dns.subCaseDir{1});

    [r_c_ref_raw, dissipType_ref, ~] = getDissip(dns.subCaseDir{1});
    [Amp_vib, Omega_vib] = getVibration(dns.subCaseDir{1});

    r_c_ref = r_c_ref_raw;

    if isnan(r_c_ref)
        r_c_ref = 0;
        dissipType_ref = 0;
    end

    % ==============================================================================================
    % Store physical parameters
    % ==============================================================================================
    dns.Ra = Ra_ref;
    dns.Pr = Pr_ref;

    % rotation bubble
    dns.invRo = R0_ref;

    % tilted bubble
    dns.Delta = Delta_ref;

    % frozen top bubble
    dns.r_c = r_c_ref_raw;
    dns.theta_c = atan(dns.r_c) * 2;
    dns.theta_c_deg = rad2deg(dns.theta_c);
    dns.H = pi/2 - dns.theta_c;
    dns.W = (2*pi) / dns.H;
    dns.A = 1 / sin(dns.theta_c);
    dns.realRa = dns.Ra * (dns.H)^3;

    if isnan(dns.r_c)

        dns.r_c = 0;
        dns.theta_c = 0;
        dns.theta_c_deg = 0;
        dns.H = pi/2;
        dns.W = 4;
        dns.realRa = dns.Ra;
        dns.A = 0;

    end

    dns.dissipType = dissipType_ref;

    % vibration bubble
    dns.Amp_vib = Amp_vib;
    dns.Omega_vib = Omega_vib;

    if isnan(dns.Omega_vib)
        dns.Amp_vib = 0;
        dns.Omega_vib = 0;
    end

    % ==============================================================================================
    % Store invariant computational parameters
    % ==============================================================================================
    dns.x2dGauche = x2dGauche_ref;
    dns.x2dDroit  = x2dDroit_ref;
    dns.y2dBas    = y2dBas_ref;
    dns.y2dHaut   = y2dHaut_ref;

    % ==============================================================================================
    % Read and check parameters for all valid subcases
    % ==============================================================================================
    dns.St = zeros(1, dns.numSubCase);
    dns.Ff = zeros(1, dns.numSubCase);
    dns.n1 = zeros(1, dns.numSubCase);
    dns.n2 = zeros(1, dns.numSubCase);
    dns.maxNPlan = zeros(1, dns.numSubCase);
    dns.dt = zeros(1, dns.numSubCase);
    dns.dtSave = zeros(1, dns.numSubCase);

    for idxSubCase = 1:dns.numSubCase

        [Ra_i, Pr_i, St_i, R0_i, Ff_i, Delta_i, ...
         x2dGauche_i, x2dDroit_i, y2dBas_i, y2dHaut_i, ...
         n1_i, n2_i, maxNPlan_i, dt_i, dtSave_i] ...
            = getCoefs(dns.subCaseDir{idxSubCase});

        [r_c_i, dissipType_i, ~] = getDissip(dns.subCaseDir{idxSubCase});

        if isnan(r_c_i)
            r_c_i = 0;
            dissipType_i = 0;
        end

        consistency = ...
            (Ra_ref == Ra_i) && ...
            (Pr_ref == Pr_i) && ...
            (R0_ref == R0_i) && ...
            (Delta_ref == Delta_i) && ...
            (x2dGauche_ref == x2dGauche_i) && ...
            (x2dDroit_ref  == x2dDroit_i)  && ...
            (y2dBas_ref    == y2dBas_i)    && ...
            (y2dHaut_ref   == y2dHaut_i)   && ...
            (r_c_ref == r_c_i) && ...
            (dissipType_ref == dissipType_i);

        if ~consistency

            disp('The cases are not consistent in the coefficients!')
            disp(['The inconsistent case is in the ', num2str(idxSubCase, '%d'), 'th place'])
            disp(['The inconsistent case is in: ', dns.subCaseDir{idxSubCase}])

            error('Subcases are not physically or geometrically consistent.')

        end

        dns.St(idxSubCase) = St_i;
        dns.Ff(idxSubCase) = Ff_i;
        dns.n1(idxSubCase) = n1_i;
        dns.n2(idxSubCase) = n2_i;
        dns.maxNPlan(idxSubCase) = maxNPlan_i;
        dns.dt(idxSubCase) = dt_i;
        dns.dtSave(idxSubCase) = dtSave_i;

    end

    % ==============================================================================================
    % Record start and end time of each subcase
    % ==============================================================================================
    dns.startTime = zeros(1, dns.numSubCase);
    dns.endTime   = zeros(1, dns.numSubCase);

    dns.startTime(1) = dns.dtSave(1);
    dns.endTime(1)   = dns.maxN(1) * dns.dtSave(1);

    if dns.numSubCase > 1

        for idxSubCase = 2:dns.numSubCase

            dns.startTime(idxSubCase) = dns.endTime(idxSubCase-1) + ...
                dns.dtSave(idxSubCase);

            dns.endTime(idxSubCase) = dns.endTime(idxSubCase-1) + ...
                dns.dtSave(idxSubCase) * dns.maxN(idxSubCase);

        end

    end

    dns.dnsBeginTime = dns.startTime(1);
    dns.dnsStopTime  = dns.endTime(dns.numSubCase);
    dns.totalN       = sum(dns.maxN);

    % ==============================================================================================
    % Build global frame index table
    %
    % dns.globalFrameStart(idxSubCase):
    %   The first global frame index of this subcase.
    %
    % dns.globalFrameEnd(idxSubCase):
    %   The last global frame index of this subcase.
    %
    % dns.globalFrameRange{idxSubCase}:
    %   All global frame indices belonging to this subcase.
    %
    % dns.globalFrameSubCase(idxGlobalFrame):
    %   Which subcase this global frame belongs to.
    %
    % dns.globalFrameLocal(idxGlobalFrame):
    %   Local frame index inside the corresponding subcase.
    % ==============================================================================================
    dns.globalFrameStart = zeros(1, dns.numSubCase);
    dns.globalFrameEnd   = zeros(1, dns.numSubCase);
    dns.globalFrameRange = cell(1, dns.numSubCase);

    dns.globalFrameSubCase = zeros(dns.totalN, 1);
    dns.globalFrameLocal   = zeros(dns.totalN, 1);

    headIdx = 0;

    for idxSubCase = 1:dns.numSubCase

        nFrame = dns.maxN(idxSubCase);

        idxStart = headIdx + 1;
        idxEnd   = headIdx + nFrame;

        dns.globalFrameStart(idxSubCase) = idxStart;
        dns.globalFrameEnd(idxSubCase)   = idxEnd;
        dns.globalFrameRange{idxSubCase} = idxStart:idxEnd;

        dns.globalFrameSubCase(idxStart:idxEnd) = idxSubCase;
        dns.globalFrameLocal(idxStart:idxEnd)   = (1:nFrame)';

        headIdx = idxEnd;

    end

    % ==============================================================================================
    % Build the global DNS time table
    % ==============================================================================================
    dns.timeLocal = cell(1, dns.numSubCase);
    dns.time = zeros(dns.totalN, 1);

    lastTime = 0;

    for idxSubCase = 1:dns.numSubCase

        idxFrame = dns.globalFrameRange{idxSubCase};

        dns.timeLocal{idxSubCase} = lastTime + ...
            dns.dtSave(idxSubCase) * (1:1:dns.maxN(idxSubCase))';

        dns.time(idxFrame) = dns.timeLocal{idxSubCase};

        lastTime = dns.timeLocal{idxSubCase}(end);

    end

    % ==============================================================================================
    % Build and store mesh
    % ==============================================================================================
    dns.x2dS = cell(1, dns.numSubCase);
    dns.y2dS = cell(1, dns.numSubCase);
    dns.x2dU = cell(1, dns.numSubCase);
    dns.y2dU = cell(1, dns.numSubCase);
    dns.x2dV = cell(1, dns.numSubCase);
    dns.y2dV = cell(1, dns.numSubCase);

    dns.h1 = zeros(1, dns.numSubCase);
    dns.h2 = zeros(1, dns.numSubCase);

    for idxSubCase = 1:dns.numSubCase

        [dns.x2dS{idxSubCase}, dns.y2dS{idxSubCase}, ...
         dns.x2dU{idxSubCase}, dns.y2dU{idxSubCase}, ...
         dns.x2dV{idxSubCase}, dns.y2dV{idxSubCase}] ...
            = buildMeshOrg(dns.x2dGauche, dns.x2dDroit, ...
                dns.y2dHaut, dns.y2dBas, dns.n1(idxSubCase), dns.n2(idxSubCase));

        dns.h1(idxSubCase) = (dns.x2dDroit - dns.x2dGauche) / dns.n1(idxSubCase);
        dns.h2(idxSubCase) = (dns.y2dHaut - dns.y2dBas) / dns.n2(idxSubCase);

    end

    % ==============================================================================================
    % Initialize read control parameters
    % ==============================================================================================
    dns.lastReadTime = -1;
    dns.nextReadTime = -1;
    dns.readNowSubCaseIdx = -1;
    dns.readNowFileID = -1;
    dns.readCounter = 0;

    dns.timePrecision = getDecimalPrecision(dns.dtSave, 6);

    % ==============================================================================================
    % Display physical parameters of assembled cases
    % ==============================================================================================
    disp(['Finished setting up assemble case: ', asmGetParameterStr(dns)])

end

function precision = getDecimalPrecision(x, maxPrecision, tol)
%GETDECIMALPRECISION 找到表示数组所需的最小小数位数
%
% precision = getDecimalPrecision(x)
% precision = getDecimalPrecision(x, maxPrecision)
% precision = getDecimalPrecision(x, maxPrecision, tol)

    if nargin < 2
        maxPrecision = 12;
    end
    
    if nargin < 3
        tol = 100 * eps(max(1, max(abs(x(:)))));
    end
    
    x = x(:);
    x = x(isfinite(x));   % 去掉 NaN 和 Inf
    
    if isempty(x)
        precision = 0;
        return;
    end
    
    for p = 0:maxPrecision
        xRound = round(x, p);
    
        if all(abs(x - xRound) <= tol)
            precision = p;
            return;
        end
    end
    
    precision = maxPrecision;
end