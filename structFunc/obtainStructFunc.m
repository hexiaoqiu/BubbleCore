function [success, StructFunc] = obtainStructFunc(varargin)

    if nargin == 3
        StructFuncIn = varargin{1};
        Field = varargin{2};
        GPU = varargin{3};
        logFile = 'null';
    elseif nargin == 4
        StructFuncIn = varargin{1};
        Field = varargin{2};
        GPU = varargin{3};
        logFile = varargin{4};
    else
        success = false;
        return
    end

    validField = strcmp(Field,'T') || strcmp(Field,'U');
    if validField == false
        success = false;
        return
    end

    if (GPU ~= 0)&&(GPU ~= 1)
        success = false;
        return
    end

    StructFunc = StructFuncIn;
    StructFunc.field = Field;

    % Step 1.0 : read the configuration parameters
    numD = numel(StructFunc.d);              
    dataPath = StructFunc.path;
    order = StructFunc.order;
    n_x = StructFunc.n1;
    n_y = StructFunc.n2;
    itpMethod = StructFunc.itpMethod;
    timeStepList = StructFunc.timeStepList;
    if GPU == 0
        if strcmp(Field, 'T')
            x2dS = StructFunc.x2dS;
            y2dS = StructFunc.y2dS;
        end
        if strcmp(Field,'U')
            x2dU = StructFunc.x2dU;
            x2dV = StructFunc.x2dV;
            y2dU = StructFunc.y2dU;
            y2dV = StructFunc.y2dV;
        end
    end

    if GPU == 1
        if strcmp(Field, 'T')
            x2dS = gpuArray(StructFunc.x2dS);
            y2dS = gpuArray(StructFunc.y2dS);
        end
        if strcmp(Field,'U')
            x2dU = gpuArray(StructFunc.x2dU);
            x2dV = gpuArray(StructFunc.x2dV);
            y2dU = gpuArray(StructFunc.y2dU);
            y2dV = gpuArray(StructFunc.y2dV);
        end
    end




    t0 = clock;
    % the code assign to CPU / accelerated by the multi-task level parallel
    for iD = 1:numD
        % formulate the point pairs distanced by r
        [p1_phi,p1_theta,p2_phi,p2_theta] = prList(StructFunc.d(iD), StructFunc.scanWindow, StructFunc.resolution, StructFunc.algorithm, GPU);

        % check if the r is not valid(too large)
        if GPU == 1
            licitP1 = ~isnan(gather(p1_phi));
        end
        if GPU == 0
            licitP1 = ~isnan(p1_phi);
        end
        if licitP1 == false % if it is too large
            StructFunc.f(iD) = NaN;
            continue
        end

        % calculate the corresponding coordinate of 2D system
        [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
        [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
        [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
        [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);
        
        t1 = clock;
        if strcmp(Field,'T')
            x2d_total = [p1_x2d; p2_x2d];
            y2d_total = [p1_y2d; p2_y2d];
            f_of_iD = computeTmp(n_x,n_y,order,dataPath,x2dS,y2dS,x2d_total,y2d_total,timeStepList,GPU,itpMethod);
        end
        if strcmp(Field,'U')
            f_of_iD = computeVel(n_x,n_y,order,dataPath,x2dU,y2dU,x2dV,y2dV,p1_x2d,p1_y2d,p2_x2d,p2_y2d,p1_x3d,p1_y3d,p1_z3d,p2_x3d,p2_y3d,p2_z3d,timeStepList,GPU,itpMethod);
        end

        t2 = clock;

        if strcmp( logFile, 'null')
            disp(timeInfor(t0,t1,t2,iD,numD))
        else
            fprintf(logFile, '%s \n',timeInfor(t0,t1,t2,iD,numD));
        end

        StructFunc.f(:,iD) = f_of_iD;

    end

    success = true;

end

function [ f_of_iD ] = computeTmp(n_x,n_y,order,dataPath,x2dS,y2dS,x2d_total,y2d_total,timeStepList,GPU,itpMethod)
    numOrder = numel(order);
    numTimeStep = numel(timeStepList);
    f_eachStep = zeros(numOrder,numTimeStep);
    numPair = 0.5*numel(x2d_total);
    parfor iTime = 1:numTimeStep       
        time = timeStepList(iTime);
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

function [ f_of_iD ] = computeVel(n_x,n_y,order,dataPath,x2dU,y2dU,x2dV,y2dV,p1_x2d,p1_y2d,p2_x2d,p2_y2d,p1_x3d,p1_y3d,p1_z3d,p2_x3d,p2_y3d,p2_z3d,timeStepList,GPU,itpMethod)
    numOrder = numel(order);
    numTimeStep = numel(timeStepList);
    f_eachStep = zeros(numOrder,numTimeStep);
    parfor iTime = 1:numTimeStep

        time = timeStepList(iTime);
        fileNameU = ['u_',num2str(time,'%d'),'.bin'];
        filePathU = fullfile(dataPath,'org',fileNameU);
        fileU = fopen(filePathU,'r');
        fileNameV = ['v_',num2str(time,'%d'),'.bin'];
        filePathV = fullfile(dataPath,'org',fileNameV);
        fileV = fopen(filePathV,'r');
        if GPU == 1
            u2dOrg = gpuArray( fread(fileU, [n_y,n_x+1], 'double') );
            v2dOrg = gpuArray( fread(fileV, [n_y+1,n_x], 'double') );
        end
        if GPU == 0
            u2dOrg = fread(fileU, [n_y,n_x+1], 'double');
            v2dOrg = fread(fileV, [n_y+1,n_x], 'double');
        end
        fclose(fileU);
        fclose(fileV);

    
        p1_u2d = interp2(x2dU, y2dU, u2dOrg, p1_x2d, p1_y2d, itpMethod);
        p1_v2d = interp2(x2dV, y2dV, v2dOrg, p1_x2d, p1_y2d, itpMethod);
        p2_u2d = interp2(x2dU, y2dU, u2dOrg, p2_x2d, p2_y2d, itpMethod);
        p2_v2d = interp2(x2dV, y2dV, v2dOrg, p2_x2d, p2_y2d, itpMethod);

        p1_c_1 = ( 1.0 + p1_x2d.^2 + p1_y2d.^2 );
        p1_u3d =   ( p1_u2d.*(1.0 - p1_x2d.^2 + p1_y2d.^2) - p1_v2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
        p1_v3d =   ( p1_v2d.*(1.0 - p1_y2d.^2 + p1_x2d.^2) - p1_u2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
        p1_w3d =   ( -p1_u2d.*2.0.*p1_x2d - p1_v2d.*(2.0*p1_y2d) ) ./ p1_c_1;

        p2_c_1 = ( 1.0 + p2_x2d.^2 + p2_y2d.^2 );
        p2_u3d =   ( p2_u2d.*(1.0 - p2_x2d.^2 + p2_y2d.^2) - p2_v2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
        p2_v3d =   ( p2_v2d.*(1.0 - p2_y2d.^2 + p2_x2d.^2) - p2_u2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
        p2_w3d =   ( -p2_u2d.*2.0.*p2_x2d - p2_v2d.*(2.0*p2_y2d) ) ./ p2_c_1;

        dVel_x = p2_u3d - p1_u3d;
        dVel_y = p2_v3d - p1_v3d;
        dVel_z = p2_w3d - p1_w3d;
        
        dx = p2_x3d - p1_x3d;
        dy = p2_y3d - p1_y3d;
        dz = p2_z3d - p1_z3d;

        l_norm = sqrt( dx.^2 + dy.^2 + dz.^2 );

        l_hat_x = dx./l_norm;
        l_hat_y = dy./l_norm;
        l_hat_z = dz./l_norm;

        dVel = abs( dVel_x.*l_hat_x + dVel_y.*l_hat_y + dVel_z.*l_hat_z );

        if GPU == 1
            for i = 1:numOrder
                f_eachStep(i,iTime) = gather(mean( dVel.^(order(i)), 'all'));
            end
        else
            for i = 1:numOrder
                f_eachStep(i,iTime) = mean( dVel.^(order(i)), 'all');
            end
        end
    end
    f_of_iD = mean(f_eachStep,2);
end
