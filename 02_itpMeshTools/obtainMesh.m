function [net] = obtainMesh(varargin)
    if isa(varargin{1},'double')

        if nargin == 1
            net.N1 = varargin{1};
            net.N2 = varargin{1};
            net.phi = linspace(0,pi*2,net.N1);
            net.theta = linspace(0,pi/2,net.N2)';
        elseif nargin == 3
            net.N1 = varargin{1};
            net.N2 = varargin{1};
            net.phi = linspace(0,varargin{2},net.N1);
            net.theta = linspace(0,varargin{3},net.N2)';
        elseif nargin == 5
            net.N1 = varargin{1};
            net.N2 = varargin{1};
            net.phi = linspace(varargin{2},varargin{3},net.N1);
            net.theta = linspace(varargin{4},varargin{5},net.N2)';
        end

        [phiGrid,thetaGrid] = meshgrid(net.phi,net.theta);
        [net.x3d,net.y3d,net.z3d] = posSphto3D(phiGrid,thetaGrid);
        [net.x2d, net.y2d] = pos3Dto2D(net.x3d,net.y3d);

    elseif isa(varargin{1},'char')

        if strcmp(varargin{1},'sph')
            net.N1 = varargin{2};
            net.N2 = varargin{3};
            phi_0 = varargin{4};
            phi_1 = varargin{5};
            theta_0 = varargin{6};
            theta_1 = varargin{7};

            phi = linspace(phi_0,phi_1,net.N1);
            dPhi = phi(2) - phi(1);
            theta = linspace(theta_0,theta_1,net.N2)';
            dTheta = theta(2) - theta(1);
            
            % x2d = zeros(net.N2,net.N1);
            % y2d = zeros(net.N2,net.N1);
            % N1 = net.N1;
            % N2 = net.N2;
            % parfor i_Phi = 1:N1
            %     for j_theta = 1:N2
            %         x3d = sin(theta(j_theta))*cos(phi(i_Phi));
            %         y3d = sin(theta(j_theta))*sin(phi(i_Phi));
            %         z3d = cos(theta(j_theta));

            %         x2d(j_theta,i_Phi) = x3d / (1 + z3d);
            %         y2d(j_theta,i_Phi) = y3d / (1 + z3d);
            %     end
            % end
            
            [phiGrid,thetaGrid] = meshgrid(phi,theta);
            [x3d,y3d,~] = posSphto3D(phi,theta);
            [x2d, y2d] = pos3Dto2D(x3d,y3d);
            
            net.x2d = x2d;
            net.y2d = y2d;
            net.theta = theta;
            net.phi = phi;
            clear x3d y3d z3d phiGrid thetaGrid

        elseif strcmp(varargin{1},'3d')
            net.N1 = varargin{2};
            net.N2 = varargin{2};
            
            x3dVec = linspace(varargin{3},varargin{4},net.N1)';
            y3dVec = linspace(varargin{5},varargin{6},net.N2)';
            
            [net.x3d,net.y3d] = meshgrid(x3dVec,y3dVec);
            net.z3d = zeros(net.N2,net.N1);
            r = sqrt( net.x3d.^2 + net.y3d.^2 );
            net.z3d( r<1 ) = sqrt(1 - r( r<1 ).^2);

            [net.phi, net.theta] = pos3DtoSph(net.x3d,net.y3d,net.z3d);
            [net.x2d, net.y2d] = pos3Dto2D(net.x3d,net.y3d,net.z3d);

        elseif strcmp(varargin{1},'2d')
            net.N1 = varargin{2};
            net.N2 = varargin{2};

            x2dVec = linspace(varargin{3},varargin{4},net.N1)';
            y2dVec = linspace(varargin{5},varargin{6},net.N2)';

            [net.x2d,net.y2d] = meshgrid(x2dVec,y2dVec);
            [net.x3d,net.y3d,net.z3d] = pos2Dto3D(net.x2d,net.y2d);
            [net.phi, net.theta] = pos3DtoSph(net.x3d,net.y3d,net.z3d);
        end

    end

end