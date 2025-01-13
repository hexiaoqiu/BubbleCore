function [divFlux] = getDivFluxThermalEnergy(bubble, timeStep, itpMesh)

    tmpOrg = readField(bubble, 'tmp', timeStep);
    
    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    h1 = x2d(2) - x2d(1);
    h2 = y2d(2) - y2d(1);

    gradTmpX2d = zeros( size(tmpOrg) );
    gradTmpY2d = zeros( size(tmpOrg) );

    gradTmpX2d(:,2:end-1) = (tmpOrg(:,3:end) - tmpOrg(:,1:end-2)) ./ (2*h1);
    gradTmpY2d(2:end-1,:) = (tmpOrg(3:end,:) - tmpOrg(1:end-2,:)) ./ (2*h2);

    gradTmpX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradTmpX2d - x2d.*y2d.*gradTmpY2d;
    gradTmpY3d = - x2d.*y2d.*gradTmpX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradTmpY2d;
    gradTmpZ3d = - x2d.*gradTmpX2d - y2d.*gradTmpY2d;

    psiX3d = tmpOrg.*gradTmpX3d;
    psiY3d = tmpOrg.*gradTmpY3d;
    psiZ3d = tmpOrg.*gradTmpZ3d;

    gradPsiX3dX2d = zeros( size(psiX3d) );
    gradPsiX3dY2d = zeros( size(psiX3d) );
    gradPsiX3dX2d(:,2:end-1) = (psiX3d(:,3:end) - psiX3d(:,1:end-2)) ./ (2*h1);
    gradPsiX3dY2d(2:end-1,:) = (psiX3d(3:end,:) - psiX3d(1:end-2,:)) ./ (2*h2);

    gradPsiY3dX2d = zeros( size(psiY3d) );
    gradPsiY3dY2d = zeros( size(psiY3d) );
    gradPsiY3dX2d(:,2:end-1) = (psiY3d(:,3:end) - psiY3d(:,1:end-2)) ./ (2*h1);
    gradPsiY3dY2d(2:end-1,:) = (psiY3d(3:end,:) - psiY3d(1:end-2,:)) ./ (2*h2);

    gradPsiZ3dX2d = zeros( size(psiZ3d) );
    gradPsiZ3dY2d = zeros( size(psiZ3d) );
    gradPsiZ3dX2d(:,2:end-1) = (psiZ3d(:,3:end) - psiZ3d(:,1:end-2)) ./ (2*h1);
    gradPsiZ3dY2d(2:end-1,:) = (psiZ3d(3:end,:) - psiZ3d(1:end-2,:)) ./ (2*h2);

    gradPsiX3dX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradPsiX3dX2d - x2d.*y2d.*gradPsiX3dY2d;
    gradPsiY3dY3d = - x2d.*y2d.*gradPsiY3dX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradPsiY3dY2d;
    gradPsiZ3dZ3d = - x2d.*gradPsiZ3dX2d - y2d.*gradPsiZ3dY2d;

    divFluxOrg = gradPsiX3dX3d + gradPsiY3dY3d + gradPsiZ3dZ3d;

    divFlux = interp2(x2d, y2d, divFluxOrg, itpMesh.x2d, itpMesh.y2d);

end