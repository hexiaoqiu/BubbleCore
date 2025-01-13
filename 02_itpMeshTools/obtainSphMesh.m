function [grille] = obtainSphMesh(varargin)
    
    if nargin == 6
        phiMin = varargin{1};
        phiMax = varargin{2};
        thetaMin = varargin{3};
        thetaMax = varargin{4};
        N_phi = varargin{5};
        N_theta = varargin{6};
    elseif nargin == 1
        phiMin = 0;
        phiMax = pi*2;
        thetaMin = 0;
        thetaMax = pi/2;
        N_phi = varargin{1};
        N_theta = varargin{1};
    else
        grille = nan;
        disp('The input is not correct!')
        return
    end

    grille.nPhi = N_phi;
    grille.nTheta = N_theta;
    
    grille.phiMin = phiMin;
    grille.phiMax = phiMax;
    grille.thetaMax = thetaMax;
    grille.thetaMin = thetaMin;

    grille.phiVec = linspace(phiMin,phiMax,N_phi);
    grille.thetaVec = linspace(thetaMin,thetaMax,N_theta)';
    grille.dPhi = (phiMax - phiMin)/(N_phi-1);
    grille.dTheta = (thetaMax - thetaMin)/(N_theta-1);
    [grille.phi, grille.theta] = meshgrid(grille.phiVec,grille.thetaVec);

    [grille.x3d,grille.y3d,grille.z3d] = posSphto3D(grille.phi,grille.theta);
    [grille.x2d, grille.y2d] = pos3Dto2D(grille.x3d,grille.y3d);

end