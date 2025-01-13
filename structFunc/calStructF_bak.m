function [success, structF_done] = calStructF_bak(varargin)

    if nargin == 1
        structF = varargin{1};
        logFile = 'null';
    elseif nargin == 2
        structF = varargin{1};
        logFile = varargin{2};
    else
        success = false;
        return
    end


    % Step 1.0 : read the configuration parameters
    numD = numel(structF.d);              
    % dataPath = structF.path;
    % order = structF.order;
    % n_x = structF.n1;
    % n_y = structF.n2;
    % itpMethod = structF.itpMethod;
    % timeStep = structF.timeStep;
    % if structF.GPU == 0
    %     if strcmp(structF.type, 'T')
    %         x2dS = structF.x2dS;
    %         y2dS = structF.y2dS;
    %     end
    %     if strcmp(structF.type,'U')
    %         x2dU = structF.x2dU;
    %         x2dV = structF.x2dV;
    %         y2dU = structF.y2dU;
    %         y2dV = structF.y2dV;
    %     end
    % end

    % if structF.GPU == 1
    %     if strcmp(structF.type, 'T')
    %         x2dS = gpuArray(structF.x2dS);
    %         y2dS = gpuArray(structF.y2dS);
    %     end
    %     if strcmp(structF.type,'U')
    %         x2dU = gpuArray(structF.x2dU);
    %         x2dV = gpuArray(structF.x2dV);
    %         y2dU = gpuArray(structF.y2dU);
    %         y2dV = gpuArray(structF.y2dV);
    %     end
    % end




    t0 = clock;
    % the code assign to CPU / accelerated by the multi-task level parallel
    for iD = 1:numD
        % formulate the point pairs distanced by r
        [p1_phi,p1_theta,p2_phi,p2_theta] = prList(structF.d(iD), structF.scanWin, structF.resolution, structF.algorithm, structF.GPU);

        % check if the r is not valid(too large)
        if structF.GPU == 1
            licitP1 = ~isnan(gather(p1_phi));
        end
        if structF.GPU == 0
            licitP1 = ~isnan(p1_phi);
        end
        if licitP1 == false % if it is too large
            structF.f(iD) = NaN;
            continue
        end

        % calculate the corresponding coordinate of 2D system
        [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
        [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
        [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
        [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);
        
        t1 = clock;
        if strcmp(structF.type,'T')
            x2d_total = [p1_x2d; p2_x2d];
            y2d_total = [p1_y2d; p2_y2d];
            f_of_iD = computeTmp(x2d_total,y2d_total, ...,
            structF.n1,structF.n2,structF.order,structF.path,structF.x2dS,structF.y2dS,structF.timeStep,structF.GPU,structF.itpMethod);
        end
        if strcmp(structF.type,'U')
            f_of_iD = computeVel(p1_x2d,p1_y2d,p2_x2d,p2_y2d,p1_x3d,p1_y3d,p1_z3d,p2_x3d,p2_y3d,p2_z3d, ...,
            structF.n1,structF.n2,structF.order,structF.path,structF.x2dU,structF.y2dU,structF.x2dV,structF.y2dV,structF.timeStep,structF.GPU,structF.itpMethod);
        end

        t2 = clock;

        if strcmp( logFile, 'null')
            disp(timeInfor(t0,t1,t2,iD,numD))
        else
            fprintf(logFile, '%s \n',timeInfor(t0,t1,t2,iD,numD));
        end

        structF.f(:,iD) = f_of_iD;

    end

    success = true;

end

function [ f_of_iD ] = computeTmp(x2d_total,y2d_total,n_x,n_y,order,dataPath,x2dS,y2dS,timeStep,GPU,itpMethod)
    numOrder = numel(order);
    numTimeStep = numel(timeStep);
    f_eachStep = zeros(numOrder,numTimeStep);
    numPair = 0.5*numel(x2d_total);
    parfor iTime = 1:numTimeStep       
        time = timeStep(iTime);
        fileName = ['tmp_',num2str(time,'%d'),'.bin'];
        filePath = fullfile(dataPath,'org',fileName);
        file = fopen(filePath,'r');
        if GPU == 1
            tmp = gpuArray( fread(file, [n_y,n_x], 'double') );
        end
        if GPU == 0
            tmp = fread(file, [n_y,n_x], 'double');
        end
        fclose(file);
        
        t_total = interp2(x2dS, y2dS, tmp, x2d_total, y2d_total, itpMethod);
        t1 = t_total(1:numPair);
        t2 = t_total(numPair+1:end);
        
        if GPU == 1
            for i = 1:numOrder
                f_eachStep(i,iTime) = gather( mean( abs(t1 - t2 ).^(order(i)), 'all') );
            end
        else
            for i = 1:numOrder
                f_eachStep(i,iTime) = mean( abs(t1 - t2 ).^(order(i)), 'all');
            end
        end
    end
    f_of_iD = mean(f_eachStep,2);
end

function [ f_of_iD ] = computeVel(p1_x2d,p1_y2d,p2_x2d,p2_y2d,p1_x3d,p1_y3d,p1_z3d,p2_x3d,p2_y3d,p2_z3d,n_x,n_y,order,dataPath,x2dU,y2dU,x2dV,y2dV,timeStep,GPU,itpMethod)
    numOrder = numel(order);
    numTimeStep = numel(timeStep);
    numStepSlice = 100;
    numSlice = floor(numTimeStep/numStepSlice);
    numStepLastSlice = mod(numTimeStep,numStepSlice);
    if numStepLastSlice ~= 0
        numSlice = numSlice + 1;
    end
    u2dOrg = zeros(n_y,n_x+1,numStepSlice);
    v2dOrg = zeros(n_y+1,n_x,numStepSlice);
    f_eachSlice = zeros(numel(order),numSlice);

    for iSlice = 1:numSlice

        timeStart = 1 + (iSlice - 1)*numStepSlice;
        if iSlice ~= numSlice
            timeEnd = iSlice*numStepSlice;
        else
            timeEnd = timeStep(end);
        end
        timeStepList = timeStart:1:timeEnd;
        for idx = 1:numel(timeStepList) 
            fileNameU = ['u_',num2str(timeStepList(idx),'%d'),'.bin'];
            filePathU = fullfile(dataPath,'org',fileNameU);
            fileU = fopen(filePathU,'r');
            fileNameV = ['v_',num2str(timeStepList(idx),'%d'),'.bin'];
            filePathV = fullfile(dataPath,'org',fileNameV);
            fileV = fopen(filePathV,'r');
        
            u2dOrg(:,:,idx) = fread(fileU, [n_y,n_x+1], 'double');
            v2dOrg(:,:,idx) = fread(fileV, [n_y+1,n_x], 'double');
            
            fclose(fileU);
            fclose(fileV);
        end
        
        meanDVel = zeros(numOrder, numel(timeStepList));
        for idx = 1:numel(timeStepList)

            

            p1_u2d = interp2(x2dU, y2dU, u2dOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
            p1_v2d = interp2(x2dV, y2dV, v2dOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
            p2_u2d = interp2(x2dU, y2dU, u2dOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);
            p2_v2d = interp2(x2dV, y2dV, v2dOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);

            p1_c_1 = ( 1.0 + p1_x2d.^2 + p1_y2d.^2 );
            p1_u3d =   ( p1_u2d.*(1.0 - p1_x2d.^2 + p1_y2d.^2) - p1_v2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
            p1_v3d =   ( p1_v2d.*(1.0 - p1_y2d.^2 + p1_x2d.^2) - p1_u2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
            % p1_w3d =   ( -p1_u2d.*2.0.*p1_x2d - p1_v2d.*(2.0*p1_y2d) ) ./ p1_c_1;

            p2_c_1 = ( 1.0 + p2_x2d.^2 + p2_y2d.^2 );
            p2_u3d =   ( p2_u2d.*(1.0 - p2_x2d.^2 + p2_y2d.^2) - p2_v2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
            p2_v3d =   ( p2_v2d.*(1.0 - p2_y2d.^2 + p2_x2d.^2) - p2_u2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
            % p2_w3d =   ( -p2_u2d.*2.0.*p2_x2d - p2_v2d.*(2.0*p2_y2d) ) ./ p2_c_1;

    %         p1_theta = acos(p1_z3d/1);
            p1_phi = atan(p1_y3d./p1_x3d);

            % p1_Vtheta = 1*( cos(p1_theta) .* cos(p1_phi) .* p1_u3d + cos(p1_theta) .* sin(p1_phi) .* p1_v3d - sin(p1_theta) .* p1_w3d );
            p1_Uphi = -sin(p1_phi).*p1_u3d + cos(p1_phi).*p1_v3d;

    %         p2_theta = acos(p2_z3d/1);
            p2_phi = atan(p2_y3d./p2_x3d);

            p2_Uphi = -sin(p2_phi).*p2_u3d + cos(p2_phi).*p2_v3d;

            dVel = abs( p2_Uphi - p1_Uphi );

            for idx_order = 1:numOrder
                meanDVel(idx_order,idx) = mean( dVel.^(order(idx_order)), 'all');
            end
        end
        f_eachSlice(:,iSlice) = mean(meanDVel,2);
    end
    f_of_iD = mean(f_eachSlice,2);
end
