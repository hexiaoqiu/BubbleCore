function [meanCenter] = lscGetMeanForCenter(roll,fieldMean,phiVecC,thetaVecC)
    
    % get size of mean field
    [nThetaMean,nPhiMean] = size(fieldMean);
    phiHeadC = phiVecC(1);
    phiRailC = phiVecC(end);

    % generate coordiante vector for mean field
    phiHeadM = roll.head*(2*pi);
    phiRearM = roll.rear*(2*pi);
    if phiRearM > phiHeadM
        phiVecMean = linspace(phiHeadM,phiRailC,nPhiMean);
    else
        if phiHeadC < 0
            phiVecMean = linspace(phiHeadM-2*pi,phiRearM,nPhiMean);
        elseif phiRailC > 2*pi
            phiVecMean = linspace(phiHeadM,phiRearM+2*pi,nPhiMean);
        end
    end
    % it is enough that theta vec is linear, the exact value is not
    % necessary
    thetaVecMean = linspace(0,pi/2,nThetaMean);

    meanCenter = interp2(phiVecMean,thetaVecMean,fieldMean,phiVecC,thetaVecC);

end