function [success, structF_done] = calStructF_CPU2(varargin)

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
    numStepSlice = 200;
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
        x2dU = structF.x2dU;
        x2dV = structF.x2dV;
        y2dU = structF.y2dU;
        y2dV = structF.y2dV;
    end


    t0_Slice = clock;
    h_Slice = waitbar(0,'Waiting for calculation of the first slice ...','Name','Processing time slices...');
    for iSlice = 1:numSlice
        
        t1_Slice = clock;
        timeStart = structF.timeStep(1) + (iSlice - 1)*numStepSlice;
        if iSlice ~= numSlice
            timeEnd = structF.timeStep(1) + iSlice*numStepSlice -1;
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

        
        t0 = clock;
        h_D = waitbar(0,'Waiting for calculation of the first d ...','Name','Processing d(i)...');
        for iD = 1:numD
            t1 = clock;
            [p1_phi,p1_theta,p2_phi,p2_theta] = prList(d(iD), scanWin, resolution, algorithm, GPU);
            
            [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
            [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
            [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
            [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);

            
            
            if strcmp(type,'T')
                meanF_OneStep = zeros(numOrder,numel(timeStepList));
                for idx = 1:numel(timeStepList)
                    t_1 = interp2(x2dS, y2dS, tmpOrg(:,:,idx), p1_x2d, p1_y2d, itpMethod);
                    t_2 = interp2(x2dS, y2dS, tmpOrg(:,:,idx), p2_x2d, p2_y2d, itpMethod);
                    dTmp = abs(t_2 - t_1);
                    for idx_order = 1:numOrder
                        meanF_OneStep(idx_order,idx) = mean( dTmp.^(order(idx_order)), 'all');
                    end
                end
                f_eachSlice(:,iD,iSlice) = mean(meanF_OneStep,2);

            elseif strcmp(type,'U')

                % calculate the plane p1-O-p2
                A = -1*ones(size(p1_x3d));
                B = (p1_x3d.*p2_z3d - p2_x3d.*p1_z3d)./(p1_y3d.*p2_z3d-p2_y3d.*p1_z3d);
                C = (p1_x3d.*p2_y3d - p2_x3d.*p1_y3d)./(p1_z3d.*p2_y3d-p2_z3d.*p1_y3d);
                J_xy_p1 = 2*A.*p1_y3d - 2*B.*p1_x3d;
                J_xy_p2 = 2*A.*p2_y3d - 2*B.*p1_x3d;
                J_xz_p1 = 2*A.*p1_z3d - 2*C.*p1_x3d;
                J_xz_p2 = 2*A.*p2_z3d - 2*C.*p2_x3d;
                J_yz_p1 = 2*B.*p1_z3d - 2*C.*p1_y3d;
                J_yz_p2 = 2*B.*p2_z3d - 2*C.*p2_y3d;

                L_tao_p1 = sqrt(J_xy_p1.^2 + J_xz_p1.^2 + J_yz_p1.^2);
                L_tao_p2 = sqrt(J_xy_p2.^2 + J_xz_p2.^2 + J_yz_p2.^2);

                tao_x_p1 = J_yz_p1./L_tao_p1;
                tao_y_p1 = J_xz_p1./L_tao_p1;
                tao_z_p1 = J_xy_p1./L_tao_p1;

                tao_x_p2 = J_yz_p2./L_tao_p2;
                tao_y_p2 = J_xz_p2./L_tao_p2;
                tao_z_p2 = J_xy_p2./L_tao_p2;
                
                f_AllStep = zeros(numOrder,1);

                % start the calculation for every time step
                for idx = numel(timeStepList):-1:1
                    
                    f_future(idx) = parfeval(@calVelOneStep,1,x2dU,y2dU,x2dV,y2dV,u2dOrg(:,:,idx),v2dOrg(:,:,idx), ...,
                    p1_x2d,p1_y2d,p2_x2d,p2_y2d,itpMethod,order,tao_x_p1,tao_y_p1,tao_z_p1,tao_x_p2,tao_y_p2,tao_z_p2);
                     
                end
                % Build a waitbar to track progress
                % h = waitbar(0,'Waiting for calculation of each time step to complete...');
                % while not all finished
                for idx = 1:1:numel(timeStepList)
                    [completedIdx,f_OneStep] = fetchNext(f_future);
                    % add all the steps together
                    f_AllStep = f_AllStep + f_OneStep;
                    % update waitbar
                    % h.Name = ['Progress time step: ',num2str(idx,'%d'),'/',num2str(numel(timeStepList),'%d')];
                    % waitbar(idx/numel(timeStepList),h,sprintf('Latest time step: %d',completedIdx));  
                end
                % delete(h);
                f_eachSlice(:,iD,iSlice) = f_AllStep./numel(timeStepList);
            end            

            t2 = clock;
            if strcmp( logFile, 'null')
                disp(timeInfor(t0,t1,t2,iD,numD))
            else
                % disp(timeInfor(t0,t1,t2,iD,numD))
                fprintf(logFile, '%s \n',timeInfor(t0,t1,t2,iD,numD));
            end
            h_D.Name = ['Progress d: ',num2str(iD,'%d'),'/',num2str(numD,'%d')];
            waitbar(iD/numD,h_D,sprintf('%s',timeInfor(t0,t1,t2,iD,numD)));

        end
        delete(h_D)

        t2_Slice = clock;
        h_Slice.Name = ['Progress Slice: ',num2str(iSlice,'%d'),'/',num2str(numSlice,'%d')];
        waitbar(iSlice/numSlice,h_Slice,sprintf('%s',timeInfor(t0_Slice,t1_Slice,t2_Slice,iSlice,numSlice)) );
    end
    delete(h_Slice);
    f = mean(f_eachSlice,3);
    structF.f = f;
    d_acting = 2*asin(d./2);
    structF.d = d_acting;

    success = true;
    structF_done = structF;

end

function [f] = calVelOneStep(x2dU,y2dU,x2dV,y2dV,u2dOrg,v2dOrg,p1_x2d,p1_y2d,p2_x2d,p2_y2d,itpMethod,order,tao_x_p1,tao_y_p1,tao_z_p1,tao_x_p2,tao_y_p2,tao_z_p2)
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

    
    U_tao_p1 = p1_u3d.*tao_x_p1 + p1_v3d.*tao_y_p1 + p1_w3d.*tao_z_p1;
    U_tao_p2 = p2_u3d.*tao_x_p2 + p2_v3d.*tao_y_p2 + p2_w3d.*tao_z_p2;
    dVel = abs( U_tao_p1 - U_tao_p2 );
    
    f = zeros(numel(order),1);
    for idx_order = 1:numel(order)
        f(idx_order) =  mean( dVel.^(order(idx_order)), 'all');
    end
end