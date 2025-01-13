function [grad3dU, grad3dV, grad3dW] = getGrad3dVelInst(bubble, itpMesh, timeStep)

    x2d = bubble.x2dS;
    y2d = bubble.y2dS;

    h1 = bubble.h1;
    h2 = bubble.h2;

    u2dOrg = readField(bubble, 'u', timeStep);
    v2dOrg = readField(bubble, 'v', timeStep);

    u2dOrgShift = interp2(bubble.x2dU, bubble.y2dU, u2dOrg, x2d, y2d);
    v2dOrgShift = interp2(bubble.x2dV, bubble.y2dV, v2dOrg, x2d, y2d);

    [x2dMatrix,y2dMatrix] = meshgrid(x2d,y2d);
    [u3dOrg, v3dOrg, w3dOrg] = velocity2DTo3D(u2dOrgShift, v2dOrgShift, x2dMatrix, y2dMatrix);

    [gradX2dU3d,gradY2dU3d] = getGradCoord2d(h1, h2, u3dOrg);
    [gradX2dV3d,gradY2dV3d] = getGradCoord2d(h1, h2, v3dOrg);
    [gradX2dW3d,gradY2dW3d] = getGradCoord2d(h1, h2, w3dOrg);

    [gradX3dU3d_2d, gradY3dU3d_2d, gradZ3dU3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dU3d, gradY2dU3d);
    [gradX3dV3d_2d, gradY3dV3d_2d, gradZ3dV3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dV3d, gradY2dV3d);
    [gradX3dW3d_2d, gradY3dW3d_2d, gradZ3dW3d_2d] = grad2dToGrad3d(x2dMatrix, y2dMatrix, gradX2dW3d, gradY2dW3d);


    gradX3dU3d_Inner = interp2(x2d, y2d, gradX3dU3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dU3d_Inner = interp2(x2d, y2d, gradY3dU3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dU3d_Inner = interp2(x2d, y2d, gradZ3dU3d_2d, itpMesh.x2d, itpMesh.y2d);

    gradX3dV3d_Inner = interp2(x2d, y2d, gradX3dV3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dV3d_Inner = interp2(x2d, y2d, gradY3dV3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dV3d_Inner = interp2(x2d, y2d, gradZ3dV3d_2d, itpMesh.x2d, itpMesh.y2d);

    gradX3dW3d_Inner = interp2(x2d, y2d, gradX3dW3d_2d, itpMesh.x2d, itpMesh.y2d);
    gradY3dW3d_Inner = interp2(x2d, y2d, gradY3dW3d_2d, itpMesh.x2d, itpMesh.y2d); 
    gradZ3dW3d_Inner = interp2(x2d, y2d, gradZ3dW3d_2d, itpMesh.x2d, itpMesh.y2d);

    [u3d, v3d, w3d]=obtainU3d(bubble,timeStep,itpMesh);
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