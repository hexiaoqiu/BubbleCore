% **************************************************************************************************
% Aurthor: Xiaoqiu HE
% Date: 04/11/2023 at IMB
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
%    
%   
%   

function [asmCase] = setAsmCase(varargin)
    
    narginchk(1,2);
    if nargin == 1
        subCaseDirList = varargin{1};
    elseif nargin == 2
        subCaseDirList = varargin{1};
        asmCase = varargin{2};
    end

    % obtain the raw cases' coefficients and numbers
    % disp('Start set up the assemble cases')
    % disp('Obtaining the raw case lists:')
    asmCase.numSubCase = numel(subCaseDirList);
    asmCase.subCaseDir = subCaseDirList;
    % for idxSubCase = 1:asmCase.numSubCase
    %     disp(asmCase.subCaseDir{idxSubCase})
    % end

    % get strings
    % disp('Getting the string:')
    [IDGOM, IDSOLU] = getString(asmCase.subCaseDir{1});
    asmCase.IDGOM = IDGOM;
    asmCase.IDSOLU = IDSOLU;
    % disp(asmCase.IDGOM)
    % disp(asmCase.IDSOLU)
    
    % read parameters
    [Ra, Pr, St, R0, Ff, Delta,x2dGauche, x2dDroit, y2dBas, y2dHaut, n1, n2, maxN,dt,dtSave] ...,
    = getCoefs(asmCase.subCaseDir{1});
    [r_c, dissipType,~] = getDissip(asmCase.subCaseDir{1});
    [Amp_vib, Omega_vib] = getVibration(asmCase.subCaseDir{1});

    % physical parameters
    % ogirin parameters
    asmCase.Ra = Ra;
    asmCase.Pr = Pr;
    % rotation bubble
    asmCase.invRo = R0;
    % tiled bubble
    asmCase.Delta = Delta;
    % frozen top bubble
    if ~isnan(r_c)
        asmCase.r_c = r_c;
        asmCase.theta_c = atan(r_c)*2;
        asmCase.theta_c_deg = rad2deg(asmCase.theta_c);
        asmCase.H = pi/2 - asmCase.theta_c;
        asmCase.W = (2*pi)/asmCase.H;
        asmCase.A = 1/sin(asmCase.theta_c);
        asmCase.realRa = asmCase.Ra*(asmCase.H)^3;
    end
    % vibration bubble
    if ~isnan(Amp_vib)
        asmCase.Amp_vib = Amp_vib;
        asmCase.Omega_vib = Omega_vib;
    end
    
    
    % computational parameters invariant
    asmCase.x2dGauche = x2dGauche;
    asmCase.x2dDroit = x2dDroit;
    asmCase.y2dBas = y2dBas;
    asmCase.y2dHaut = y2dHaut;
    % computational parameters may vary
    asmCase.St(1) = St;
    asmCase.Ff(1) = Ff;
    asmCase.n1(1) = n1;
    asmCase.n2(1) = n2;
    asmCase.maxN(1) = maxN;
    asmCase.dt(1) = dt;
    asmCase.dtSave(1) = dtSave;

    % check types for all subcases
    idxSubCase = 0;
    while idxSubCase < asmCase.numSubCase
        idxSubCase = idxSubCase + 1;

        % disp(['In subCase: ', asmCase.subCaseDir{idxSubCase}])
        if exist(fullfile(asmCase.subCaseDir{idxSubCase},'nssave.bin'),"file") == 2
            asmCase.type{idxSubCase} = 'bin';
            asmCase.dataFileName{idxSubCase} = 'nssave.bin';
            % disp('Data is stored in binary form!')
        elseif exist(fullfile(asmCase.subCaseDir{idxSubCase},'nssave.dat'),"file") == 2
            asmCase.type{idxSubCase} = 'txt';
            asmCase.dataFileName{idxSubCase} = 'nssave.dat';
            % disp('Data is stored in texte form!')
        else
            disp(['No data file is found in ',asmCase.subCaseDir{idxSubCase}])
            disp('Deleting it from the sub directory list!')
            asmCase.subCaseDir(idxSubCase) = [];
            idxSubCase = idxSubCase - 1;
            asmCase.numSubCase = asmCase.numSubCase - 1;
        end
        
    end
    
    % check the consistency between subCases
    if asmCase.numSubCase > 1
        % disp(['There are ',num2str(asmCase.numSubCase,'%d'),' to assemble! Checking physical parameters'' consistency!']);
        for idxSubCase = 2:asmCase.numSubCase
            [Ra_2, Pr_2, St_2, R0_2, Ff_2, Delta_2, x2dGauche_2, x2dDroit_2, y2dBas_2, y2dHaut_2, n1_2, n2_2, maxN_2,dt_2,dtSave_2] ...,
            = getCoefs(asmCase.subCaseDir{idxSubCase});
            [r_c_2, dissipType_2,delta_r_2] = getDissip(asmCase.subCaseDir{idxSubCase});
    
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
                disp(['The inconsistent case is in: ',asmCase.subCaseDir{idxSubCase}])
                return
            else
                asmCase.St(idxSubCase) = St_2;
                asmCase.Ff(idxSubCase) = Ff_2;
                asmCase.n1(idxSubCase) = n1_2;
                asmCase.n2(idxSubCase) = n2_2;
                asmCase.maxN(idxSubCase) = maxN_2;
                asmCase.dt(idxSubCase) = dt_2;
                asmCase.dtSave(idxSubCase) = dtSave_2;
            end
        end
        % disp('Physical parameters of all Sub Cases are consistent!');
    end

    %  check real time steps for each case
    % disp('Start checking data integrity.............')
    for idxSubCase = 1:asmCase.numSubCase
        % disp(['Verifying the real number of time steps of No.',num2str(idxSubCase,'%g'),' Sub Case: ',asmCase.subCaseDir{idxSubCase}])
        filePathRealMaxN = fullfile(asmCase.subCaseDir{idxSubCase},'realMaxN.txt');
        if exist(filePathRealMaxN, 'file') == 2
            % disp('Find realMaxN.txt! Reading it!')
            fileIDRealMaxN = fopen(filePathRealMaxN,'r','n');
            cache = textscan(fileIDRealMaxN, '%n', 'HeaderLines', 1);
            coefs = cell2mat(cache);
            realMaxN = coefs(1);
            fclose(fileIDRealMaxN);
        else
            disp(['No real MaxN record is found! Check it by going through ',asmCase.subCaseDir{idxSubCase},' !'])
            if strcmp(asmCase.type{idxSubCase},'bin')
                [realMaxN] = asmGetRealMaxNBin(asmCase.subCaseDir{idxSubCase});
            else
                [realMaxN] = asmGetRealMaxNTxt(asmCase.subCaseDir{idxSubCase});
            end
            disp('Get Real MaxN! Write it to realMaxN.txt!')
            fileIDRealMaxN = fopen(filePathRealMaxN,'w','n');
            fprintf(fileIDRealMaxN,'Real MaxN \n');
            fprintf(fileIDRealMaxN,'%d',realMaxN);
            fclose(fileIDRealMaxN);
        end
        % disp(['No. ',num2str(idxSubCase,'%g'),' Sub Case time step: Planned ', ...
        %     num2str(asmCase.maxN(idxSubCase)),' Real ',num2str(realMaxN,'%g')]);
        asmCase.maxN(idxSubCase) = realMaxN;
    end
    asmCase.endTime(1) = asmCase.maxN(1)*asmCase.dtSave(1);
    asmCase.startTime(1) = asmCase.dtSave(1);
    if asmCase.numSubCase > 1
        for idxSubCase = 2:asmCase.numSubCase
            if asmCase.maxN(idxSubCase) >= 1
                asmCase.startTime(idxSubCase) = asmCase.endTime(idxSubCase-1) + ...
                    asmCase.dtSave(idxSubCase);
                asmCase.endTime(idxSubCase) = asmCase.endTime(idxSubCase-1) + ...
                    asmCase.dtSave(idxSubCase)*asmCase.maxN(idxSubCase);
            elseif asmCase.maxN(idxSubCase) == 0
                disp('This Case has no data saved!')
                disp(['case dir: ', asmCase.subCaseDir{idxSubCase}])
                asmCase.startTime(idxSubCase) = asmCase.endTime(idxSubCase-1);
                asmCase.endTime(idxSubCase) = asmCase.endTime(idxSubCase-1);
            end
        end
    end
    asmCase.dnsBeginTime = asmCase.startTime(1);
    asmCase.dnsStopTime = asmCase.endTime(asmCase.numSubCase);
    asmCase.totalN = sum(asmCase.maxN);
    
    % build the global time table
    for idxSubCase = 1:asmCase.numSubCase
        if idxSubCase == 1
            asmCase.timeLocal{idxSubCase} = asmCase.dtSave(idxSubCase)*(1:1:asmCase.maxN(idxSubCase))';
        else
            asmCase.timeLocal{idxSubCase} = asmCase.timeLocal{idxSubCase-1}(end)...
                + asmCase.dtSave(idxSubCase)*(1:1:asmCase.maxN(idxSubCase))';
        end
    end
    asmCase.time = zeros(asmCase.totalN,1);
    for idxSubCase = 1:asmCase.numSubCase
        if idxSubCase == 1
            asmCase.time(1:asmCase.maxN(1)) = asmCase.timeLocal{idxSubCase};
        else
            headIdx = sum(asmCase.maxN(1:idxSubCase-1));
            asmCase.time(headIdx+1:headIdx+asmCase.maxN(idxSubCase)) = asmCase.timeLocal{idxSubCase};
        end
    end

    % build and store mesh
    % disp('Building mesh')
    for idxSubCase = 1:asmCase.numSubCase
        [asmCase.x2dS{idxSubCase}, asmCase.y2dS{idxSubCase}, ...,
         asmCase.x2dU{idxSubCase}, asmCase.y2dU{idxSubCase}, ...,
         asmCase.x2dV{idxSubCase}, asmCase.y2dV{idxSubCase}] ...,
        = buildMeshOrg(asmCase.x2dGauche, asmCase.x2dDroit, ...,
            asmCase.y2dHaut, asmCase.y2dBas, asmCase.n1(idxSubCase), asmCase.n2(idxSubCase));
        asmCase.h1(idxSubCase) = (asmCase.x2dDroit - asmCase.x2dGauche) / asmCase.n1(idxSubCase);
        asmCase.h2(idxSubCase) = (asmCase.y2dHaut - asmCase.y2dBas) / asmCase.n2(idxSubCase);
    end
    
    % read related coefficients
    % disp('Initializing read control parameters')
    asmCase.lastReadTime = -1;
    asmCase.nextReadTime = -1;
    asmCase.readNowSubCaseIdx = -1;
    asmCase.readNowFileID = -1;
    asmCase.readCounter = 0;
    asmCase.timePrecision = ceil( max(-1*log10(asmCase.dtSave), [],'all') );

    % display the physical parameters of assemble cases
    disp(['Finished setting up assmble case: ',asmGetParameterStr(asmCase)])

end