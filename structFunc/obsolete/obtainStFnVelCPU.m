% Author: Xiaoqiu HE
% Date: 2021/01/11
% Function Usage:
% compute Structure Function of velocity only by CPU

function [success] = obtainStFnVelCPU(varargin)

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

    StFn.field = 'U';

    % Step 1.1 : prepare the coefficients
    numD = numel(StFn.d);
    numTimeStep = numel(StFn.timeStepList);


    t0 = clock;
    % the code assign to CPU / accelerated by the multi-task level parallel
    for iD = 1:numD
        % disp(['Inner Iteration Index = ',num2str(iD,'%d')])
        % formulate the point pairs distanced by r
        [p1_phi,p1_theta,p2_phi,p2_theta] = prList(StFn.d(iD), StFn.scanWindow, StFn.resolution, StFn.algorithm, 1);

        % check if the r is not valid(too large)
        if isnan(p1_phi) % if it is too large
            StFn.f(iD) = NaN;
            continue
        end

        % calculate the corresponding coordinate of 2D system
        % numPair = numel(p1_phi);
        
        [p1_x3d,p1_y3d,p1_z3d] = posSphto3D(p1_phi, p1_theta); 
        [p2_x3d,p2_y3d,p2_z3d] = posSphto3D(p2_phi, p2_theta); 
        [p1_x2d,p1_y2d] = pos3Dto2D(p1_x3d,p1_y3d,p1_z3d);
        [p2_x2d,p2_y2d] = pos3Dto2D(p2_x3d,p2_y3d,p2_z3d);
        

        % prepare for parallel read
        f_0 = zeros(1,numTimeStep);
        t1 = clock;
        parfor iTime = 1:numTimeStep

            time = StFn.timeStepList(iTime);
            u2dOrg = readField(StFn,'u',time);
            v2dOrg = readField(StFn,'v',time);
        
            p1_u2d = interp2(StFn.x2dU, StFn.y2dU, u2dOrg, p1_x2d, p1_y2d, StFn.itpMethod);
            p1_v2d = interp2(StFn.x2dV, StFn.y2dV, v2dOrg, p1_x2d, p1_y2d, StFn.itpMethod);
            p2_u2d = interp2(StFn.x2dU, StFn.y2dU, u2dOrg, p2_x2d, p2_y2d, StFn.itpMethod);
            p2_v2d = interp2(StFn.x2dV, StFn.y2dV, v2dOrg, p2_x2d, p2_y2d, StFn.itpMethod);

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

            f_0(iTime) = mean( dVel.^(StFn.order), 'all');

        end
        t2 = clock;

        if strcmp( logFile, 'null')
            disp(timeInfor(t0,t1,t2,iD,numD))
        else
            fprintf(logFile, '%s \n',timeInfor(t0,t1,t2,iD,numD));
        end

        StFn.f(iD) = mean(f_0,'all');
    end

    success = true;
end
