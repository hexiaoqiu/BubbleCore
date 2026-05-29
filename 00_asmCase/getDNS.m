% **************************************************************************************************
% Aurthor: Xiaoqiu HE
% Date: 2026/02/28 at HUST
% **************************************************************************************************
% Purpose : 
%   This is new struct used for manipulate the assemble of a series cases of which the start and end 
%   are corresponded.
%
% **************************************************************************************************
% Attention :
%   the cases in <caseRawDirList> should be sequenced 
% **************************************************************************************************
% Updates :
%  2026/02/28: 将AmsCase改为dnsCase，命名更加清晰，相应函数代码迁移到setDnsCase,
% 输出结构体默认名字也是dns  
%   
%   

function [dns] = getDNS(varargin)
    
    narginchk(1,2);
    if nargin == 1
        subCaseDirList = varargin{1};
    elseif nargin == 2
        subCaseDirList = varargin{1};
        dns = varargin{2};
    end

    % obtain the raw cases' coefficients and numbers
    dns.numSubCase = numel(subCaseDirList);
    dns.subCaseDir = subCaseDirList;

    % get strings
    [IDGOM, IDSOLU] = getString(dns.subCaseDir{1});
    dns.IDGOM = IDGOM;
    dns.IDSOLU = IDSOLU;
    
    % read parameters
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(dns.subCaseDir{1});
    [r_c, dissipType,~] = getDissip(dns.subCaseDir{1});
    [Amp_vib, Omega_vib] = getVibration(dns.subCaseDir{1});

    % physical parameters
    % ogirin parameters
    dns.Ra = Ra;
    dns.Pr = Pr;
    % rotation bubble
    dns.invRo = R0;
    % tiled bubble
    dns.Delta = Delta;
    % frozen top bubble
    dns.r_c = r_c;
    dns.theta_c = atan(r_c)*2;
    dns.theta_c_deg = rad2deg(dns.theta_c);
    dns.H = pi/2 - dns.theta_c;
    dns.W = (2*pi)/dns.H;
    dns.A = 1/sin(dns.theta_c);
    dns.realRa = dns.Ra*(dns.H)^3;
    if isnan(dns.r_c)
        dns.r_c = 0;
        dns.theta_c = 0;
        dns.theta_c_deg = 0;
        dns.H = pi/2;
        dns.W = 4;
        dns.realRa = dns.Ra;
        dns.A = 0;
        dissipType = 0;
        r_c = 0;
    end
    % vibration bubble
    dns.Amp_vib = Amp_vib;
    dns.Omega_vib = Omega_vib;
    if isnan(dns.Omega_vib)
        dns.Amp_vib = 0;
        dns.Omega_vib = 0;
    end
    
    
    % computational parameters invariant
    dns.x2dGauche = x2dGauche;
    dns.x2dDroit = x2dDroit;
    dns.y2dBas = y2dBas;
    dns.y2dHaut = y2dHaut;
    % computational parameters may vary
    dns.St(1) = St;
    dns.Ff(1) = Ff;
    dns.n1(1) = n1;
    dns.n2(1) = n2;
    dns.maxN(1) = maxN;
    dns.dt(1) = dt;
    dns.dtSave(1) = dtSave;

    % check types for all subcases
    idxSubCase = 0;
    while idxSubCase < dns.numSubCase
        idxSubCase = idxSubCase + 1;

        disp(['In subCase: ', dns.subCaseDir{idxSubCase}])
        if exist(fullfile(dns.subCaseDir{idxSubCase},'nssave.bin'),"file") == 2
            dns.type{idxSubCase} = 'bin';
            dns.dataFileName{idxSubCase} = 'nssave.bin';
            disp('Data is stored in binary form!')
        elseif exist(fullfile(dns.subCaseDir{idxSubCase},'nssave.dat'),"file") == 2
            dns.type{idxSubCase} = 'txt';
            dns.dataFileName{idxSubCase} = 'nssave.dat';
            disp('Data is stored in texte form!')
        else
            disp(['No data file is found in ',dns.subCaseDir{idxSubCase}])
            disp('Deleting it from the sub directory list!')
            dns.subCaseDir(idxSubCase) = [];
            idxSubCase = idxSubCase - 1;
            dns.numSubCase = dns.numSubCase - 1;
        end
        
    end
    
    % check the consistency between subCases
    if dns.numSubCase > 1
        % disp(['There are ',num2str(dns.numSubCase,'%d'),' to assemble! Checking physical parameters'' consistency!']);
        for idxSubCase = 2:dns.numSubCase
            [Ra_2, Pr_2, St_2, R0_2, Ff_2, Delta_2, x2dGauche_2, x2dDroit_2, y2dBas_2, y2dHaut_2, n1_2, n2_2, maxN_2,dt_2,dtSave_2] ...,
            = getCoefs(dns.subCaseDir{idxSubCase});
            [r_c_2, dissipType_2,~] = getDissip(dns.subCaseDir{idxSubCase});
            if isnan(r_c_2)
                r_c_2 = 0;
                dissipType_2 = 0;
            end
    
            consistency = (Ra == Ra_2)&&(R0 == R0_2)&&(Pr == Pr_2)&&(Delta == Delta_2)&&(x2dGauche == x2dGauche_2) ...,
                        &&(x2dDroit == x2dDroit_2)&&(y2dBas == y2dBas_2)&&(y2dHaut == y2dHaut_2) ...,
                        && ...,
                        (r_c == r_c_2)&&(dissipType == dissipType_2)...
                        ... %&&(delta_r == delta_r_2)...
                        ... %&&(n1 == n1_2)&&(n2 == n2_2)&&(Ff == Ff_2)&&(St == St_2)&&(dtSave == dtSave_2)&&(dt == dt_2)...
                        ;
            if consistency == false
                disp('The cases are not consistent in the coefficients!')
                disp(['The inconsistent case is in the ',num2str(idxSubCase,'%d'),'th place'])
                disp(['The inconsistent case is in: ',dns.subCaseDir{idxSubCase}])
                return
            else
                dns.St(idxSubCase) = St_2;
                dns.Ff(idxSubCase) = Ff_2;
                dns.n1(idxSubCase) = n1_2;
                dns.n2(idxSubCase) = n2_2;
                dns.maxN(idxSubCase) = maxN_2;
                dns.dt(idxSubCase) = dt_2;
                dns.dtSave(idxSubCase) = dtSave_2;
            end
        end
        % disp('Physical parameters of all Sub Cases are consistent!');
    end

    %  check real time steps for each case
    % disp('Start checking data integrity.............')
    for idxSubCase = 1:dns.numSubCase
        % disp(['Verifying the real number of time steps of No.',num2str(idxSubCase,'%g'),' Sub Case: ',dns.subCaseDir{idxSubCase}])
        filePathRealMaxN = fullfile(dns.subCaseDir{idxSubCase},'realMaxN.txt');
        if exist(filePathRealMaxN, 'file') == 2
            % disp('Find realMaxN.txt! Reading it!')
            fileIDRealMaxN = fopen(filePathRealMaxN,'r','n');
            cache = textscan(fileIDRealMaxN, '%n', 'HeaderLines', 1);
            coefs = cell2mat(cache);
            realMaxN = coefs(1);
            fclose(fileIDRealMaxN);
        else
            disp(['No real MaxN record is found! Check it by going through ',dns.subCaseDir{idxSubCase},' !'])
            if strcmp(dns.type{idxSubCase},'bin')
                [realMaxN] = asmGetRealMaxNBin(dns.subCaseDir{idxSubCase});
            else
                [realMaxN] = asmGetRealMaxNTxt(dns.subCaseDir{idxSubCase});
            end
            disp('Get Real MaxN! Write it to realMaxN.txt!')
            fileIDRealMaxN = fopen(filePathRealMaxN,'w','n');
            fprintf(fileIDRealMaxN,'Real MaxN \n');
            fprintf(fileIDRealMaxN,'%d',realMaxN);
            fclose(fileIDRealMaxN);
        end
        % disp(['No. ',num2str(idxSubCase,'%g'),' Sub Case time step: Planned ', ...
        %     num2str(dns.maxN(idxSubCase)),' Real ',num2str(realMaxN,'%g')]);
        dns.maxN(idxSubCase) = realMaxN;
    end
    dns.endTime(1) = dns.maxN(1)*dns.dtSave(1);
    dns.startTime(1) = dns.dtSave(1);
    if dns.numSubCase > 1
        for idxSubCase = 2:dns.numSubCase
            if dns.maxN(idxSubCase) >= 1
                dns.startTime(idxSubCase) = dns.endTime(idxSubCase-1) + ...
                    dns.dtSave(idxSubCase);
                dns.endTime(idxSubCase) = dns.endTime(idxSubCase-1) + ...
                    dns.dtSave(idxSubCase)*dns.maxN(idxSubCase);
            elseif dns.maxN(idxSubCase) == 0
                disp('This Case has no data saved!')
                disp(['case dir: ', dns.subCaseDir{idxSubCase}])
                dns.startTime(idxSubCase) = dns.endTime(idxSubCase-1);
                dns.endTime(idxSubCase) = dns.endTime(idxSubCase-1);
            end
        end
    end
    dns.dnsBeginTime = dns.startTime(1);
    dns.dnsStopTime = dns.endTime(dns.numSubCase);
    dns.totalN = sum(dns.maxN);
    
    % build the global time table
    for idxSubCase = 1:dns.numSubCase
        if idxSubCase == 1
            dns.timeLocal{idxSubCase} = dns.dtSave(idxSubCase)*(1:1:dns.maxN(idxSubCase))';
        else
            dns.timeLocal{idxSubCase} = dns.timeLocal{idxSubCase-1}(end)...
                + dns.dtSave(idxSubCase)*(1:1:dns.maxN(idxSubCase))';
        end
    end
    dns.time = zeros(dns.totalN,1);
    for idxSubCase = 1:dns.numSubCase
        if idxSubCase == 1
            dns.time(1:dns.maxN(1)) = dns.timeLocal{idxSubCase};
        else
            headIdx = sum(dns.maxN(1:idxSubCase-1));
            dns.time(headIdx+1:headIdx+dns.maxN(idxSubCase)) = dns.timeLocal{idxSubCase};
        end
    end

    % build and store mesh
    % disp('Building mesh')
    for idxSubCase = 1:dns.numSubCase
        [dns.x2dS{idxSubCase}, dns.y2dS{idxSubCase}, ...,
         dns.x2dU{idxSubCase}, dns.y2dU{idxSubCase}, ...,
         dns.x2dV{idxSubCase}, dns.y2dV{idxSubCase}] ...,
        = buildMeshOrg(dns.x2dGauche, dns.x2dDroit, ...,
            dns.y2dHaut, dns.y2dBas, dns.n1(idxSubCase), dns.n2(idxSubCase));
        dns.h1(idxSubCase) = (dns.x2dDroit - dns.x2dGauche) / dns.n1(idxSubCase);
        dns.h2(idxSubCase) = (dns.y2dHaut - dns.y2dBas) / dns.n2(idxSubCase);
    end
    
    % read related coefficients
    % disp('Initializing read control parameters')
    dns.lastReadTime = -1;
    dns.nextReadTime = -1;
    dns.readNowSubCaseIdx = -1;
    dns.readNowFileID = -1;
    dns.readCounter = 0;
    dns.timePrecision = ceil( max(-1*log10(dns.dtSave), [],'all') );

    % display the physical parameters of assemble cases
    disp(['Finished setting up assmble case: ',asmGetParameterStr(dns)])

end