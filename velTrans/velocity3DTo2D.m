function [u2d,v2d] = velocity3DTo2D( ...
    u3d,v3d,w3d,x2dGrid,y2dGrid)
%VELOCITY3DTO2D Convert Cartesian tangent velocity to projected velocity.
%   The two projected basis vectors are orthonormal on the unit sphere.
%   Taking the Cartesian velocity dot product with each basis vector
%   therefore gives the two projected velocity components.

    validateSameSize(u3d,v3d,w3d,x2dGrid,y2dGrid);

    denominator = 1 + x2dGrid.^2 + y2dGrid.^2;

    basisUx = (1 - x2dGrid.^2 + y2dGrid.^2)./denominator;
    basisUy = (-2*x2dGrid.*y2dGrid)./denominator;
    basisUz = (-2*x2dGrid)./denominator;

    basisVx = (-2*x2dGrid.*y2dGrid)./denominator;
    basisVy = (1 - y2dGrid.^2 + x2dGrid.^2)./denominator;
    basisVz = (-2*y2dGrid)./denominator;

    u2d = u3d.*basisUx + v3d.*basisUy + w3d.*basisUz;
    v2d = u3d.*basisVx + v3d.*basisVy + w3d.*basisVz;
end

function validateSameSize(varargin)
    referenceSize = size(varargin{1});
    for idxInput = 2:nargin
        if ~isequal(size(varargin{idxInput}),referenceSize)
            error('velocity3DTo2D:InconsistentSize', ...
                'All velocity and coordinate arrays must have the same size.');
        end
    end
end
