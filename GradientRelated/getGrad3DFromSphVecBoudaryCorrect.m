function [gradX3d,gradY3d,gradZ3d] = getGrad3DFromSphVecBoudaryCorrect(sphVec,sphX2d,sphY2d,n_2d)
    
    x2dS = linspace(-1.02,1.02,n_2d);
    y2dS = linspace(-1.02,1.02,n_2d);
    sphVec2DMesh = fieldSphMeshTo2DScalarMesh(sphVec,n_2d);
    grad3DSphVec2DMesh = get3DGradBy2DMesh(x2dS,y2dS,sphVec2DMesh);
    
    gradX3dSphMesh = zeros(size(sphX2d));
    gradY3dSphMesh = zeros(size(sphX2d));
    gradZ3dSphMesh = zeros(size(sphX2d));
    gradX3dSphMesh(1:end-2,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradX3d,sphX2d(1:end-2,:),sphY2d(1:end-2,:),"cubic");
%     gradX3dSphMesh(end,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradX3d,sphX2d(end,:),sphY2d(end,:),"nearest");
    gradY3dSphMesh(1:end-2,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradY3d,sphX2d(1:end-2,:),sphY2d(1:end-2,:),"cubic");
%     gradY3dSphMesh(end,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradY3d,sphX2d(end,:),sphY2d(end,:),"nearest");
    gradZ3dSphMesh(1:end-2,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradZ3d,sphX2d(1:end-2,:),sphY2d(1:end-2,:),"cubic");
%     gradZ3dSphMesh(end,:) = interp2(x2dS,y2dS,grad3DSphVec2DMesh.gradZ3d,sphX2d(end,:),sphY2d(end,:),"nearest");

    gradX3d = mean(gradX3dSphMesh,2);
    gradY3d = mean(gradY3dSphMesh,2);
    gradZ3d = mean(gradZ3dSphMesh,2);

%     [gradX3d(end-1)] = getMeanAndIgnoreNan(gradX3dSphMesh(end-1,:));
%     [gradX3d(end)] = getMeanAndIgnoreNan(gradX3dSphMesh(end,:));
%     [gradY3d(end-1)] = getMeanAndIgnoreNan(gradY3dSphMesh(end-1,:));
%     [gradY3d(end)] = getMeanAndIgnoreNan(gradY3dSphMesh(end,:));
%     [gradZ3d(end-1)] = getMeanAndIgnoreNan(gradZ3dSphMesh(end-1,:));
%     [gradZ3d(end)] = getMeanAndIgnoreNan(gradZ3dSphMesh(end,:));

%     % the derivatives on the equator should be modelled
%     % the gradient in phi (Par A / Par Phi = 0) on the equator is zero (as the assumption of the model)
%     % so, the gradient in x3d and y3d is also zero
%     % On the other hand, the gradient in theta dierction is just the inversion of the gradient in z3d direction for the eqautor 
%     gradX3d(end) = 0;
%     gradY3d(end) = 0;
% 
%     % calculate the Par A / Par theta on the eqautor
%     dTheta = pi/2/(numel(sphVec)-1);
%     gradSphVec_Theta = 1/(2*dTheta)*(3*sphVec(end) -4*sphVec(end-1) + sphVec(end-2) );
%     gradZ3d(end) = -1*gradSphVec_Theta;
    
    thetaVec = linspace(0,pi/2,numel(sphVec));
    gradX3d(end-3:end) = interp1(thetaVec(1:end-4),gradX3d(1:end-4),thetaVec(end-3:end),"spline","extrap");
    gradY3d(end-3:end) = interp1(thetaVec(1:end-4),gradY3d(1:end-4),thetaVec(end-3:end),"spline","extrap");
    gradZ3d(end-3:end) = interp1(thetaVec(1:end-4),gradZ3d(1:end-4),thetaVec(end-3:end),"spline","extrap");
    

end

function [meanValue] = getMeanAndIgnoreNan(Vector)
%     nonNanIdx = ~isnan(Vector);
    meanValue = mean(Vector(~isnan(Vector)),'all');
end