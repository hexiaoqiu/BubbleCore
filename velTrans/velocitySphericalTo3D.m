function [u3d,v3d,w3d] = velocitySphericalTo3D( ...
    uPhi,vTheta,phiGrid,thetaGrid)
%VELOCITYSPHERICALTO3D Convert tangential spherical velocity to Cartesian.
%   UPHI is the azimuthal component and VTHETA is the polar component.
%   A radial component is not present because the flow is constrained to
%   the unit spherical surface.

    validateSameSize(uPhi,vTheta,phiGrid,thetaGrid);

    u3d = vTheta.*cos(thetaGrid).*cos(phiGrid) ...
        - uPhi.*sin(phiGrid);
    v3d = vTheta.*cos(thetaGrid).*sin(phiGrid) ...
        + uPhi.*cos(phiGrid);
    w3d = -vTheta.*sin(thetaGrid);
end

function validateSameSize(varargin)
    referenceSize = size(varargin{1});
    for idxInput = 2:nargin
        if ~isequal(size(varargin{idxInput}),referenceSize)
            error('velocitySphericalTo3D:InconsistentSize', ...
                'All velocity and coordinate arrays must have the same size.');
        end
    end
end
