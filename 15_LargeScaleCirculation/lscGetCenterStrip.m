function [centerStripe,phiVecCenterStrip,thetaVecCenterStrip] = lscGetCenterStrip(roll,field,N)
    [nTheta,nPhi] = size(field);

    [xCenter,~] = lscGetRollCenter(roll);
    phiCenter = xCenter*pi/2;
    [widthRoll] = lscGetRollWidth(roll);
    width = 0.1*widthRoll;
    head = phiCenter - width/2;
    rail = phiCenter + width/2;
    % dPhi = width/N;
    phiVecCenterStrip = linspace(head,rail,N+1)';
    % it is enough that theta vec is linear, the exact value is not
    % necessary
    thetaVecCenterStrip = linspace(0,pi/2,nTheta);

    if head < 0
        field = repmat(field,[1,2]);
        phiVec = linspace(-2*pi,2*pi,nPhi*2)';
    elseif rail > 2*pi
        field = repmat(field,[1,2]);
        phiVec = linspace(0,4*pi,nPhi*2)';
    else
        phiVec = linspace(0,2*pi,nPhi)';
    end
    thetaVec = linspace(0,pi/2,nTheta);

    centerStripe = interp2(phiVec,thetaVec,field,phiVecCenterStrip,thetaVecCenterStrip,"spline");
        

end