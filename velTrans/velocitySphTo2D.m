function [u2d,v2d] = velocitySphTo2D( ...
    uPhi,vTheta,x2dGrid,y2dGrid,phiGrid,thetaGrid)
%VELOCITYSPHTO2D Convert spherical tangent velocity to projected velocity.

    [u3d,v3d,w3d] = velocitySphericalTo3D( ...
        uPhi,vTheta,phiGrid,thetaGrid);

    [u2d,v2d] = velocity3DTo2D( ...
        u3d,v3d,w3d,x2dGrid,y2dGrid);
end
