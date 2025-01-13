function [success, structF_done] = calStructF(varargin)

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
    type = structF.type;
    d = structF.d;
    order = structF.order;
    scanWin = structF.scanWin;
    resolution = structF.resolution;
    algorithm = structF.algorithm;
    itpMethod = structF.itpMethod;
    GPU = structF.GPU;
    n1 = structF.n1;
    n2 = structF.n2;
    binPath = structF.binPath;

    numD = numel(structF.d);              
    numOrder = numel(structF.order);
    numTimeStep = numel(structF.timeStep);
    numStepSlice = 1000;
    numSlice = floor(numTimeStep/numStepSlice);
    numStepLastSlice = mod(numTimeStep,numStepSlice);
    if numStepLastSlice ~= 0
        numSlice = numSlice + 1;
    end
    f_eachSlice = zeros(numOrder,numD,numSlice);

    if strcmp(structF.type,'T')
        tmpOrg = zeros(n2,n1,numStepSlice);
        x2dS = structF.x2dS;
        y2dS = structF.y2dS;
    elseif strcmp(structF.type,'U')
        u2dOrg = zeros(n2,n1+1,numStepSlice);
        v2dOrg = zeros(n2+1,n1,numStepSlice);
        x2dU = gpuArray(structF.x2dU);
        x2dV = gpuArray(structF.x2dV);
        y2dU = gpuArray(structF.y2dU);
        y2dV = gpuArray(structF.y2dV);
    end


    t0 = clock;
    for iSlice = 1:numSlice
        
        
        timeStart = 1 + (iSlice - 1)*numStepSlice;
        if iSlice ~= numSlice
            timeEnd = iSlice*numStepSlice;
        else
            timeEnd = structF.timeStep(end);
        end
        timeStepList = timeStart:1:timeEnd;

        if strcmp(type,'T')
            for idx = 1:numel(timeStepList) 
                fileNameTmp = ['tmp_',num2str(timeStepList(idx),'%d'),'.bin'];
                filePathTmp = fullfile(binPath,'org',fileNameTmp);
                fileTmp = fopen(filePathTmp,'r');
                tmpOrg(:,:,idx) = fread(fileTmp, [n2,n1], 'double');
                fclose(fileTmp);
            end
        elseif strcmp(type,'U')
            for idx = 1:numel(timeStepList) 
                fileNameU = ['u_',num2str(timeStepList(idx),'%d'),'.bin'];
                filePathU = fullfile(binPath,'org',fileNameU);
                fileU = fopen(filePathU,'r');
                fileNameV = ['v_',num2str(timeStepList(idx),'%d'),'.bin'];
                filePathV = fullfile(binPath,'org',fileNameV);
                fileV = fopen(filePathV,'r');
            
                u2dOrg(:,:,idx) = fread(fileU, [n2,n1+1], 'double');
                v2dOrg(:,:,idx) = fread(fileV, [n2+1,n1], 'double');
                
                fclose(fileU);
                fclose(fileV);
            end
        end

        

        for iD = 1:numD
            t1 = clock;
            [p1_phi,p1_theta,p2_phi,p2_theta] = prList(d(iD), scanWin, resolution, algorithm, GPU);
            
            [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
            [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
            [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
            [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);

            if strcmp(type,'T')
                meanF_OneStep = gpuArray(zeros(numOrder,numel(timeStepList)));
                for idx = 1:numel(timeStepList)
                    t_1 = interp2(x2dS, y2dS, tmpOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
                    t_2 = interp2(x2dS, y2dS, tmpOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);
                    dTmp = abs(t_2 - t_1);
                    for idx_order = 1:numOrder
                        meanF_OneStep(idx_order,idx) = mean( dTmp.^(order(idx_order)), 'all');
                    end
                end
                f_eachSlice(:,iD,iSlice) = gather(mean(meanF_OneStep,2));

            elseif strcmp(type,'U')
                meanF_OneStep = gpuArray(zeros(numOrder,numel(timeStepList)));
                for idx = 1:numel(timeStepList)
                    u2dGPU = gpuArray(u2dOrg(:,:,idx));
                    v2dGPU = gpuArray(v2dOrg(:,:,idx));
                    p1_u2d = interp2(x2dU, y2dU, u2dGPU, p1_x2d, p1_y2d, itpMethod);
                    p1_v2d = interp2(x2dV, y2dV, v2dGPU, p1_x2d, p1_y2d, itpMethod);
                    p2_u2d = interp2(x2dU, y2dU, u2dGPU, p2_x2d, p2_y2d, itpMethod);
                    p2_v2d = interp2(x2dV, y2dV, v2dGPU, p2_x2d, p2_y2d, itpMethod);

                    % p1_u2d = interp2(x2dU, y2dU, u2dOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
                    % p1_v2d = interp2(x2dV, y2dV, v2dOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
                    % p2_u2d = interp2(x2dU, y2dU, u2dOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);
                    % p2_v2d = interp2(x2dV, y2dV, v2dOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);

                    p1_c_1 = ( 1.0 + p1_x2d.^2 + p1_y2d.^2 );
                    p1_u3d =   ( p1_u2d.*(1.0 - p1_x2d.^2 + p1_y2d.^2) - p1_v2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
                    p1_v3d =   ( p1_v2d.*(1.0 - p1_y2d.^2 + p1_x2d.^2) - p1_u2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
                    % p1_w3d =   ( -p1_u2d.*2.0.*p1_x2d - p1_v2d.*(2.0*p1_y2d) ) ./ p1_c_1;

                    p2_c_1 = ( 1.0 + p2_x2d.^2 + p2_y2d.^2 );
                    p2_u3d =   ( p2_u2d.*(1.0 - p2_x2d.^2 + p2_y2d.^2) - p2_v2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
                    p2_v3d =   ( p2_v2d.*(1.0 - p2_y2d.^2 + p2_x2d.^2) - p2_u2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
                    % p2_w3d =   ( -p2_u2d.*2.0.*p2_x2d - p2_v2d.*(2.0*p2_y2d) ) ./ p2_c_1;

                    % DVel = U_phi
                    % p1_theta = acos(p1_z3d/1);
                    p1_phi = atan(p1_y3d./p1_x3d);
                    % p1_Vtheta = 1*( cos(p1_theta) .* cos(p1_phi) .* p1_u3d + cos(p1_theta) .* sin(p1_phi) .* p1_v3d - sin(p1_theta) .* p1_w3d );
                    p1_Uphi = -sin(p1_phi).*p1_u3d + cos(p1_phi).*p1_v3d;
                    % p2_theta = acos(p2_z3d/1);
                    p2_phi = atan(p2_y3d./p2_x3d);
                    p2_Uphi = -sin(p2_phi).*p2_u3d + cos(p2_phi).*p2_v3d;
                    dVel = abs( p2_Uphi - p1_Uphi );

                    % DVel = vector difference
                    % dVel_x = p2_u3d - p1_u3d;
                    % dVel_y = p2_v3d - p1_v3d;
                    % dVel_z = p2_w3d - p1_w3d;
                    % dx = p2_x3d - p1_x3d;
                    % dy = p2_y3d - p1_y3d;
                    % dz = p2_z3d - p1_z3d;
                    % l_norm = sqrt( dx.^2 + dy.^2 + dz.^2 );
                    % l_hat_x = dx./l_norm;
                    % l_hat_y = dy./l_norm;
                    % l_hat_z = dz./l_norm;
                    % dVel = abs( dVel_x.*l_hat_x + dVel_y.*l_hat_y + dVel_z.*l_hat_z );
                    
                    for idx_order = 1:numOrder
                        meanF_OneStep(idx_order,idx) =  mean( dVel.^(order(idx_order)), 'all');
                    end
                    clear u2dGPU v2dGPU
                    clear p1_u2d p2_u2d p1_v2d p2_v2d 
                    clear p1_u3d p2_u3d p1_v3d p2_v3d
                    clear p1_Uphi p2_Uphi
                    clear dVel

                    % clear dx dy dz
                    % clear dVel_x dVel_y dVel_z
                    % clear l_norm l_hat_x l_hat_y l_hat_z
                     
                end
                f_eachSlice(:,iD,iSlice) = gather(mean(meanF_OneStep,2));
                % f_eachSlice(:,iD,iSlice) = mean(meanF_OneStep,2);
            end

            clear p1_theta p1_phi p2_theta p2_phi 
            clear p1_x2d p1_y2d p2_x2d p2_y2d 
            clear p1_x3d p1_y3d p1_z3d p2_x3d p2_y3d p2_z3d
            

            t2 = clock;
            if strcmp( logFile, 'null')
                disp(timeInfor(t0,t1,t2,iD,numD))
            else
                % disp(timeInfor(t0,t1,t2,iD,numD))
                fprintf(logFile, '%s \n',timeInfor(t0,t1,t2,iD,numD));
            end
        end

        

    end
    f = mean(f_eachSlice,3);
    structF.f = f;

    success = true;
    structF_done = structF;

end