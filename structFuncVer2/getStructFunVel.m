function [structFun] = getStructFunVel(bubble, distanceList, orderList, NumSampPhi, NumSampTheta, winPhiMin, winPhiMax, winThetaMin, winThetaMax, Direction, timeStepStart, timeStepEnd)
    debug = 0;
    GPU = 1;

    if debug == 1
        time_0 = clock;
    end
    % initialization
    numD = numel(distanceList);
    numOrder = numel(orderList);
    numTimeStep = timeStepEnd - timeStepStart + 1;

    structFun = zeros(numD,numOrder);
    if strcmp(Direction,'longitude')
        method = 'theta';
    else
        method = 'phi';
    end
    computationWindow = [winPhiMin, winPhiMax, winThetaMin, winThetaMax];
    computationResolution = [NumSampPhi, NumSampTheta];
    
    if GPU == 1
        x2dU = gpuArray(bubble.x2dU);
        y2dU = gpuArray(bubble.y2dU);
        x2dV = gpuArray(bubble.x2dV);
        y2dV = gpuArray(bubble.y2dV);
    else
        x2dU = bubble.x2dU;
        y2dU = bubble.y2dU;
        x2dV = bubble.x2dV;
        y2dV = bubble.y2dV;
    end

    for idxTimeStep = timeStepStart:1:timeStepEnd
        if idxTimeStep <= timeStepStart + 5
            if debug == 1
                time_1 = clock;
            end
        end
        
        if GPU == 1
            u2dOrg = gpuArray(readField(bubble, 'u', idxTimeStep));
            v2dOrg = gpuArray(readField(bubble, 'v', idxTimeStep));
        else
            u2dOrg = readField(bubble, 'u', idxTimeStep);
            v2dOrg = readField(bubble, 'v', idxTimeStep);
        end
        
        for idxDistance = 1:numD

            [p1_phi,p1_theta,p2_phi,p2_theta] = ...,
            prList( distanceList(idxDistance), computationWindow, computationResolution, method, GPU);
            licitP1 = ~isnan(p1_phi);
            if licitP1 == false % if it is too large
                structFun(idxDistance) = 0;
                continue
            end
    
            % calculate the corresponding coordinate of 2D system
            [p1_x3d,p1_y3d,p1_z3d] = posVec1DSph2Car(p1_phi, p1_theta); 
            [p2_x3d,p2_y3d,p2_z3d] = posVec1DSph2Car(p2_phi, p2_theta);
            L = sqrt( (p1_x3d-p2_x3d).^2 + (p1_y3d-p2_y3d).^2 + (p1_z3d-p2_z3d).^2 ); 
            angleBetween = acos( (2 - L.^2)/2 );
            p3_x3d = ( p2_x3d - p1_x3d.*cos(angleBetween) )./sin(angleBetween);
            p3_y3d = ( p2_y3d - p1_y3d.*cos(angleBetween) )./sin(angleBetween);
            p3_z3d = ( p2_z3d - p1_z3d.*cos(angleBetween) )./sin(angleBetween);
    
            tanVecX3d_P1 = -1*p1_x3d.*sin(0) + p3_x3d.*cos(0);
            tanVecY3d_P1 = -1*p1_y3d.*sin(0) + p3_y3d.*cos(0);
            tanVecZ3d_P1 = -1*p1_z3d.*sin(0) + p3_z3d.*cos(0);
            tanVecNorm_P1 = sqrt(tanVecX3d_P1.^2 + tanVecY3d_P1.^2 + tanVecZ3d_P1.^2);
    
            tanUniVecX3d_P1 = tanVecX3d_P1./tanVecNorm_P1;
            tanUniVecY3d_P1 = tanVecY3d_P1./tanVecNorm_P1;
            tanUniVecZ3d_P1 = tanVecZ3d_P1./tanVecNorm_P1;
    
    
            tanVecX3d_P2 = -1*p1_x3d.*sin(angleBetween) + p3_x3d.*cos(angleBetween);
            tanVecY3d_P2 = -1*p1_y3d.*sin(angleBetween) + p3_y3d.*cos(angleBetween);
            tanVecZ3d_P2 = -1*p1_z3d.*sin(angleBetween) + p3_z3d.*cos(angleBetween);
            tanVecNorm_P2 = sqrt(tanVecX3d_P2.^2 + tanVecY3d_P2.^2 + tanVecZ3d_P2.^2);
    
            tanUniVecX3d_P2 = tanVecX3d_P2./tanVecNorm_P2;
            tanUniVecY3d_P2 = tanVecY3d_P2./tanVecNorm_P2;
            tanUniVecZ3d_P2 = tanVecZ3d_P2./tanVecNorm_P2;
    
            [p1_x2d,p1_y2d] = posVec1DCar2StereoGraph(p1_x3d,p1_y3d,p1_z3d);
            [p2_x2d,p2_y2d] = posVec1DCar2StereoGraph(p2_x3d,p2_y3d,p2_z3d);

            

            p1_u2d = interp2(x2dU, y2dU, u2dOrg, p1_x2d, p1_y2d, 'linear');
            p1_v2d = interp2(x2dV, y2dV, v2dOrg, p1_x2d, p1_y2d, 'linear');
            p2_u2d = interp2(x2dU, y2dU, u2dOrg, p2_x2d, p2_y2d, 'linear');
            p2_v2d = interp2(x2dV, y2dV, v2dOrg, p2_x2d, p2_y2d, 'linear');

            p1_c_1 = ( 1.0 + p1_x2d.^2 + p1_y2d.^2 );
            p1_u3d =   ( p1_u2d.*(1.0 - p1_x2d.^2 + p1_y2d.^2) - p1_v2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
            p1_v3d =   ( p1_v2d.*(1.0 - p1_y2d.^2 + p1_x2d.^2) - p1_u2d.*(2.0 * p1_x2d.* p1_y2d) ) ./ p1_c_1;
            p1_w3d =   ( -p1_u2d.*2.0.*p1_x2d - p1_v2d.*(2.0*p1_y2d) ) ./ p1_c_1;

            p2_c_1 = ( 1.0 + p2_x2d.^2 + p2_y2d.^2 );
            p2_u3d =   ( p2_u2d.*(1.0 - p2_x2d.^2 + p2_y2d.^2) - p2_v2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
            p2_v3d =   ( p2_v2d.*(1.0 - p2_y2d.^2 + p2_x2d.^2) - p2_u2d.*(2.0 * p2_x2d.* p2_y2d) ) ./ p2_c_1;
            p2_w3d =   ( -p2_u2d.*2.0.*p2_x2d - p2_v2d.*(2.0*p2_y2d) ) ./ p2_c_1;

            u1 = p1_u3d.*tanUniVecX3d_P1;
            v1 = p1_v3d.*tanUniVecY3d_P1;
            w1 = p1_w3d.*tanUniVecZ3d_P1;

            u2 = p2_u3d.*tanUniVecX3d_P2;
            v2 = p2_v3d.*tanUniVecY3d_P2;
            w2 = p2_w3d.*tanUniVecZ3d_P2;

            normDiffVel = sqrt( (u2-u1).^2 + (v2-v1).^2 + (w2-w1).^2 );
            structFun_ThisDisThisStep = zeros(1,numOrder);
            for idxOrder = 1:1:numOrder
                structFun_ThisDisThisStep(idxOrder) =  mean(normDiffVel.^(orderList(idxOrder)),'all');
            end
            
            if GPU == 1
                structFun(idxDistance,:) = ...
                (1/numTimeStep)*gather(structFun_ThisDisThisStep);
            else
                structFun(idxDistance,:) = ...
                (1/numTimeStep)*structFun_ThisDisThisStep;
            end
            
        end
        
        if idxTimeStep <= timeStepStart + 5
            if debug == 1
                time_2 = clock;
                [infor] = timeInfor(time_0,time_1,time_2,idxTimeStep-timeStepStart+1,numTimeStep);
                disp(infor);
            end
        end

    end
    



end

