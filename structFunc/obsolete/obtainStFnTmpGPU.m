function [success] = obtainStFnTmpGPU(varargin)

    if nargin == 1
        StFn = varargin{1};
        logFile = 'null';
    elseif nargin == 2
        StFn = varargin{1};
        logFile = varargin{2};
    else
        success = false;
        return
    end

    StFn.field = 'T';

    % Step 1.0 : read the configuration parameters
    numD = numel(StFn.d);              
    order = StFn.order;
    numTimeStep = numel(StFn.timeStepList);

    f_0 = zeros(numD,1);
    x2dS = gpuArray(StFn.x2dS);
    y2dS = gpuArray(StFn.y2dS);
    time0 = clock;
    % the code is run by CPU
    for iD = 1:numD
        
        % formulate the point pairs distanced by r
        [p1_phi,p1_theta,p2_phi,p2_theta] = prList(StFn.d(iD), StFn.scanWindow, StFn.resolution, StFn.algorithm, 0);

        % check if the r is not valid(too large)
        if isnan(gather(p1_phi)) % if it is too large
            f_0(iD) = NaN;
            continue
        end

        % calculate the corresponding coordinate of 2D system
        numPair = numel(p1_phi);
        
        [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
        [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
        [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
        [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);
        
        x2d_total = [p1_x2d; p2_x2d];
        y2d_total = [p1_y2d; p2_y2d];

        time1 = clock;
        f_eachStep = gpuArray(zeros(numTimeStep,1));
        for iTime = 1:numTimeStep
            
            time = StFn.timeStepList(iTime);
            tmp = gpuArray(readField(StFn,'tmp',time));
            
            t_total = interp2(x2dS, y2dS, tmp, x2d_total, y2d_total, StFn.itpMethod);
            t1 = t_total(1:numPair);
            t2 = t_total(numPair+1:end);

            f_eachStep(iTime) = mean( abs(t1 - t2 ).^(order), 'all');
        end

        f_0(iD) = gather( mean(f_eachStep,1) );
        time2 = clock;

        if strcmp( logFile, 'null')
            disp(timeInfor(time0,time1,time2,iD,numD))
        else
            fprintf(logFile, '%s \n',timeInfor(time0,time1,time2,iD,numD));
        end

    end

    StFn.f = f_0;
    success = true;

end