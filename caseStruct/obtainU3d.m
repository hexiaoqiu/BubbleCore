function [u3d,v3d,w3d]=obtainU3d(lightCase,timeStep,itpMesh)
    
    u2d = itpField(lightCase, 'u', timeStep, itpMesh);
    v2d = itpField(lightCase, 'v', timeStep, itpMesh);

    [u3d, v3d, w3d] = velocity2DTo3D(u2d, v2d, itpMesh.x2d, itpMesh.y2d);
    
end