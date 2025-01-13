function [grad3dTmp] = getGrad3dTmpInst(bubble, itpMesh, timeStep)

    tmpOrg = readField(bubble, 'tmp', timeStep);
    h1 = bubble.h1;
    h2 = bubble.h2;
    x2d = bubble.x2dS;
    y2d = bubble.y2dS;
    [x2dMatrix,y2dMatrix] = meshgrid(x2d,y2d);

    [gradX2dTmp,gradY2dTmp] = getGradCoord2d(h1, h2, tmpOrg);
    [gradX3dInner_2D, gradY3dInner_2D, gradZ3dInner_2D] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dTmp, gradY2dTmp);

    gradX3dInner = interp2(x2d, y2d, gradX3dInner_2D, itpMesh.x2d, itpMesh.y2d);
    gradY3dInner = interp2(x2d, y2d, gradY3dInner_2D, itpMesh.x2d, itpMesh.y2d);
    gradZ3dInner = interp2(x2d, y2d, gradZ3dInner_2D, itpMesh.x2d, itpMesh.y2d);


    tmp = itpField(bubble, 'tmp', timeStep, itpMesh);
    [gradPhi,gradTheta] = getGradCoordSph(itpMesh.dPhi, itpMesh.dTheta, tmp);
    
    [gradX3dBoundary, gradY3dBoundary, gradZ3dBoundary] = gradSphToGrad3d(itpMesh.phi, itpMesh.theta, gradPhi, gradTheta);

    idxSphPart = round(3*itpMesh.nTheta/4);  
    grad3dTmp.x3d = gradX3dInner;
    grad3dTmp.x3d(idxSphPart:end,:) = gradX3dBoundary(idxSphPart:end,:);
    grad3dTmp.y3d = gradY3dInner;
    grad3dTmp.y3d(idxSphPart:end,:) = gradY3dBoundary(idxSphPart:end,:);
    grad3dTmp.z3d = gradZ3dInner;
    grad3dTmp.z3d(idxSphPart:end,:) = gradZ3dBoundary(idxSphPart:end,:);


end