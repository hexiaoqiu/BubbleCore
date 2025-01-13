function [u3d, v3d, w3d] = velocity2DTo3D(u2d, v2d, x2dGrid, y2dGrid)
    % Attention !
    % in order to obtain the velocity vector field in Cartesian Coordinate System
    % the first step is to interplate two components of  the velocity of 
    % Project Coordinate System onto the same spacial points
    % then transform them to the velocity of Cartesian
    
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
        
end