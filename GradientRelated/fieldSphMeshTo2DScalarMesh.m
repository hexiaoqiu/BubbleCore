function [field2D] = fieldSphMeshTo2DScalarMesh(fieldSph,M)
    
    x2dVec = linspace(-1.02,1.02,M);
    y2dVec = linspace(-1.02,1.02,M);
    [x2dMatrix,y2dMatrix] = meshgrid(x2dVec,y2dVec);
    [x3dMatrix, y3dMatrix, z3dMatrix] = pos2Dto3D(x2dMatrix,y2dMatrix);
    [phiMatrix, thetaMatrix] = pos3DtoSph(x3dMatrix, y3dMatrix, z3dMatrix);

    
    [numTheta,numPhi] = size(fieldSph);
    phiPositionVec = linspace(0,2*pi,numPhi);
    thetaPositionVec = linspace(0,pi/2,numTheta)';
    [field2D] = interp2(phiPositionVec,thetaPositionVec,fieldSph,phiMatrix,thetaMatrix,"linear");


end