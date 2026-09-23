function [uPhi,vTheta] = velocity2DToSph( ...
    u2d,v2d,x2dGrid,y2dGrid,phiGrid,thetaGrid)
%VELOCITY2DTOSPH Convert projected velocity to spherical tangent velocity.

    [u3d,v3d,w3d] = velocity2DTo3D( ...
        u2d,v2d,x2dGrid,y2dGrid);

    [uPhi,vTheta] = velocity3DToSpherical( ...
        u3d,v3d,w3d,phiGrid,thetaGrid);
end
