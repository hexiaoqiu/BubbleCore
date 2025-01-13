function [uPhi, vTheta] = velocity2DToSph(u2d, v2d, x2dGrid, y2dGrid, phiGrid, thetaGrid)
    
    c_1 = ( 1.0 + x2dGrid.^2 + y2dGrid.^2 );

    u3d =   ( u2d.*(1.0 - x2dGrid.^2 + y2dGrid.^2) - v2d.*(2.0 * x2dGrid.* y2dGrid) ) ...,
            ./ ...,
            c_1;

    v3d =   ( v2d.*(1.0 - y2dGrid.^2 + x2dGrid.^2) - u2d.*(2.0 * x2dGrid.* y2dGrid) ) ...,
            ./ ...,
            c_1;

    w3d =   ( -u2d.*2.0.*x2dGrid - v2d.*(2.0*y2dGrid) ) ...,
            ./ ...,
            c_1;

    vTheta = 1*( ...,
        cos(thetaGrid) .* cos(phiGrid) .* u3d ...,
        + cos(thetaGrid) .* sin(phiGrid) .* v3d ...,
        - sin(thetaGrid) .* w3d ...,
    );

    uPhi = -sin(phiGrid).*u3d + cos(phiGrid).*v3d;

    
end

