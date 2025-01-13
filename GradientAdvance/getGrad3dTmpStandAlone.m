function [gradTmp] = getGradTmp(bubble, timeStep)

    tmpOrg = readField(bubble, 'tmp', timeStep);
    
    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    h1 = x2d(2) - x2d(1);
    h2 = y2d(2) - y2d(1);

    gradTmpX2d = zeros( size(tmpOrg) );
    gradTmpY2d = zeros( size(tmpOrg) );

    gradTmpX2d(:,2:end-1) = (tmpOrg(:,3:end) - tmpOrg(:,1:end-2)) ./ (2*h1);
    gradTmpY2d(2:end-1,:) = (tmpOrg(3:end,:) - tmpOrg(1:end-2,:)) ./ (2*h2);

    gradTmp.gradTmpX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradTmpX2d - x2d.*y2d.*gradTmpY2d;
    gradTmp.gradTmpY3d = - x2d.*y2d.*gradTmpX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradTmpY2d;
    gradTmp.gradTmpZ3d = - x2d.*gradTmpX2d - y2d.*gradTmpY2d;

end