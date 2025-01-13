function [structFun] = getStructFunTmp(bubble, distanceList, orderList, NumSampPhi, NumSampTheta, winPhiMin, winPhiMax, winThetaMin, winThetaMax, Direction, timeStepStart, timeStepEnd)
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
        x2dS = gpuArray(bubble.x2dS);
        y2dS = gpuArray(bubble.y2dS);
    else
        x2dS = bubble.x2dS;
        y2dS = bubble.y2dS;
    end
    
    for idxTimeStep = timeStepStart:1:timeStepEnd
        
        if idxTimeStep <= timeStepStart + 10
            if debug == 1
                time_1 = clock;
            end
        end
        
        if GPU == 1
            tmp = gpuArray(readField(bubble, 'tmp', idxTimeStep));        
        else
            tmp = readField(bubble, 'tmp', idxTimeStep);
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
                
            [p1_x2d,p1_y2d] = posVec1DCar2StereoGraph(p1_x3d,p1_y3d,p1_z3d);
            [p2_x2d,p2_y2d] = posVec1DCar2StereoGraph(p2_x3d,p2_y3d,p2_z3d);
            
            if GPU == 1
                p1_tmp = interp2(x2dS, y2dS, tmp, p1_x2d, p1_y2d, 'linear');
                p2_tmp = interp2(x2dS, y2dS, tmp, p2_x2d, p2_y2d, 'linear');
            else
                p1_tmp = interp2(x2dS, y2dS, tmp, p1_x2d, p1_y2d, 'spline');
                p2_tmp = interp2(x2dS, y2dS, tmp, p2_x2d, p2_y2d, 'spline');
            end
            
            
            normDiffTmp = abs( p2_tmp - p1_tmp );
            structFun_ThisDisThisStep = zeros(1,numOrder);
            for idxOrder = 1:1:numOrder
                structFun_ThisDisThisStep(idxOrder) =  mean(normDiffTmp.^(orderList(idxOrder)),'all');
            end
            
            if GPU == 1
                structFun(idxDistance,:) = (1/numTimeStep)*gather(structFun_ThisDisThisStep);
            else
                structFun(idxDistance,:) = (1/numTimeStep)*structFun_ThisDisThisStep;
            end

            
        end
        
        if idxTimeStep <= timeStepStart + 10
            if debug == 1
                time_2 = clock;
                [infor] = timeInfor(time_0,time_1,time_2,idxTimeStep-timeStepStart+1,numTimeStep);
                disp(infor);
            end
        end

    end
    



end

