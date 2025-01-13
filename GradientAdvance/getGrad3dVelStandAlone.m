function [grad3dU, grad3dV, grad3dW] = getGrad3dVelStandAlone(x2dGauche, x2dDroit, y2dBas, y2dHaut,n1, n2, u2dOrg, v2dOrg, itpMesh)
    
    h1 = (x2dDroit - x2dGauche) / n1;
    h2 = (y2dHaut - y2dBas) / n2;

    [x2dS, y2dS, x2dU, y2dU, x2dV, y2dV] = buildMeshOrg(x2dGauche, x2dDroit, y2dHaut, y2dBas, n1, n2);

    u2dOrgShift = interp2(x2dU, y2dU, u2dOrg, x2dS, y2dS);
    v2dOrgShift = interp2(x2dV, y2dV, v2dOrg, x2dS, y2dS);

    [x2dMatrix,y2dMatrix] = meshgrid(x2dS,y2dS);
    [u3dOrg, v3dOrg, w3dOrg] = velocity2DTo3D(u2dOrgShift, v2dOrgShift, x2dMatrix, y2dMatrix);

    [gradX2dU3d,gradY2dU3d] = getGradCoord2d(h1, h2, u3dOrg);
    [gradX2dV3d,gradY2dV3d] = getGradCoord2d(h1, h2, v3dOrg);
    [gradX2dW3d,gradY2dW3d] = getGradCoord2d(h1, h2, w3dOrg);

    [gradX3dU3d_2d, gradY3dU3d_2d, gradZ3dU3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dU3d, gradY2dU3d);
    [gradX3dV3d_2d, gradY3dV3d_2d, gradZ3dV3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dV3d, gradY2dV3d);
    [gradX3dW3d_2d, gradY3dW3d_2d, gradZ3dW3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dW3d, gradY2dW3d);


    gradX3dU3d_Inner = interp2(x2dS, y2dS, gradX3dU3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dU3d_Inner = interp2(x2dS, y2dS, gradY3dU3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dU3d_Inner = interp2(x2dS, y2dS, gradZ3dU3d_2d, itpMesh.x2d, itpMesh.y2d);

    gradX3dV3d_Inner = interp2(x2dS, y2dS, gradX3dV3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dV3d_Inner = interp2(x2dS, y2dS, gradY3dV3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dV3d_Inner = interp2(x2dS, y2dS, gradZ3dV3d_2d, itpMesh.x2d, itpMesh.y2d);

    gradX3dW3d_Inner = interp2(x2dS, y2dS, gradX3dW3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dW3d_Inner = interp2(x2dS, y2dS, gradY3dW3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dW3d_Inner = interp2(x2dS, y2dS, gradZ3dW3d_2d, itpMesh.x2d, itpMesh.y2d);

    u2d = interp2(x2dU, y2dU, u2dOrg, itpMesh.x2d, itpMesh.y2d);
    v2d = interp2(x2dV, y2dV, v2dOrg, itpMesh.x2d, itpMesh.y2d);
    [u3d, v3d, w3d] = velocity2DTo3D(u2d, v2d, itpMesh.x2d, itpMesh.y2d);

    [gradPhiU3d,gradThetaU3d] = getGradCoordSph(itpMesh.dPhi, itpMesh.dTheta, u3d);
    [gradPhiV3d,gradThetaV3d] = getGradCoordSph(itpMesh.dPhi, itpMesh.dTheta, v3d);
    [gradPhiW3d,gradThetaW3d] = getGradCoordSph(itpMesh.dPhi, itpMesh.dTheta, w3d);
    
    [gradX3dU3d_Boundary, gradY3dU3d_Boundary, gradZ3dU3d_Boundary] = ...
        gradSphToGrad3d(itpMesh.phi, itpMesh.theta, gradPhiU3d, gradThetaU3d);
    [gradX3dV3d_Boundary, gradY3dV3d_Boundary, gradZ3dV3d_Boundary] = ...
        gradSphToGrad3d(itpMesh.phi, itpMesh.theta, gradPhiV3d, gradThetaV3d);
    [gradX3dW3d_Boundary, gradY3dW3d_Boundary, gradZ3dW3d_Boundary] = ...
        gradSphToGrad3d(itpMesh.phi, itpMesh.theta, gradPhiW3d, gradThetaW3d);

    idxSphPart = round(3*itpMesh.nTheta/4);  
    grad3dU.x3d = gradX3dU3d_Inner;
    grad3dU.x3d(idxSphPart:end,:) = gradX3dU3d_Boundary(idxSphPart:end,:);
    grad3dU.y3d = gradY3dU3d_Inner;
    grad3dU.y3d(idxSphPart:end,:) = gradY3dU3d_Boundary(idxSphPart:end,:);
    grad3dU.z3d = gradZ3dU3d_Inner;
    grad3dU.z3d(idxSphPart:end,:) = gradZ3dU3d_Boundary(idxSphPart:end,:);

    grad3dV.x3d = gradX3dV3d_Inner;
    grad3dV.x3d(idxSphPart:end,:) = gradX3dV3d_Boundary(idxSphPart:end,:);
    grad3dV.y3d = gradY3dV3d_Inner;
    grad3dV.y3d(idxSphPart:end,:) = gradY3dV3d_Boundary(idxSphPart:end,:);
    grad3dV.z3d = gradZ3dV3d_Inner;
    grad3dV.z3d(idxSphPart:end,:) = gradZ3dV3d_Boundary(idxSphPart:end,:);

    grad3dW.x3d = gradX3dW3d_Inner;
    grad3dW.x3d(idxSphPart:end,:) = gradX3dW3d_Boundary(idxSphPart:end,:);
    grad3dW.y3d = gradY3dW3d_Inner;
    grad3dW.y3d(idxSphPart:end,:) = gradY3dW3d_Boundary(idxSphPart:end,:);
    grad3dW.z3d = gradZ3dW3d_Inner;
    grad3dW.z3d(idxSphPart:end,:) = gradZ3dW3d_Boundary(idxSphPart:end,:);



end