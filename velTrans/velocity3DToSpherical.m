function [uPhi, vTheta] = velocity3DToSpherical(u3d, v3d, w3d, phiGrid, thetaGrid)

    vTheta = 1*( ...,
        cos(thetaGrid) .* cos(phiGrid) .* u3d ...,
        + cos(thetaGrid) .* sin(phiGrid) .* v3d ...,
        - sin(thetaGrid) .* w3d ...,
    );

    uPhi = -sin(phiGrid).*u3d + cos(phiGrid).*v3d;

end