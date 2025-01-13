function [uPhi,vTheta]=obtainUSph(lightCase,timeStep,itpMesh)
    
    [u3d,v3d,w3d]=obtainU3d(lightCase,timeStep,itpMesh);

    [phiGrid,thetaGrid]=meshgrid(itpMesh.phi,itpMesh.theta);
    [uPhi, vTheta] = velocity3DToSpherical(u3d, v3d, w3d, phiGrid, thetaGrid);
    
end