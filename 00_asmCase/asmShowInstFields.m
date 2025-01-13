function [figHandle] = asmShowInstFields(varargin)
    narginchk(1,2);
    if nargin == 1
        ns = varargin{1};
        time = ns.dnsStopTime;
    elseif nargin == 2
        ns = varargin{1};
        time = varargin{2};
    else
        disp('Wrong input')
        return
    end

    % mesh for the post processing = la maillage
    nMesh = 1024;
    maillage = obtainSphMesh(0,2*pi,0,pi/2,nMesh,nMesh);
    x3d = maillage.x3d;
    y3d = maillage.y3d;
    z3d = maillage.z3d;
    x2d = maillage.x2d;
    y2d = maillage.y2d;
    phi = maillage.phi;
    theta = maillage.theta;
    
    LineWidth = 2.5;
    MarkerSize = 5;
    FontSizeLgd = 5;
    FontSize = 20;
    legendFontSize = 5;
    labelFontSize = 25;
    titleFontSize = 30;
    colorBarTextSize = 25;
    pOsItiON = [0,0,1027,768];

    [ns,tmpOrg, u2dOrg, v2dOrg, ~] = asmInitRead(ns,time);
    tmp = interp2(ns.x2dS{ns.readNowSubCaseIdx}, ...
            ns.y2dS{ns.readNowSubCaseIdx},tmpOrg, x2d, y2d,"linear");
    % u2d v2d on maillage
    u2d = interp2(ns.x2dU{ns.readNowSubCaseIdx}, ...
        ns.y2dU{ns.readNowSubCaseIdx},...
        u2dOrg,...
        maillage.x2d,...
        maillage.y2d,'spline');
    v2d = interp2(ns.x2dV{ns.readNowSubCaseIdx}, ...
        ns.y2dV{ns.readNowSubCaseIdx},...
        v2dOrg,...
        maillage.x2d,...
        maillage.y2d,'spline');
    % transform to Cartesian velocity
    [u3d, v3d, w3d] = velocity2DTo3D(u2d, v2d, maillage.x2d, maillage.y2d);
    [uPhi, vTheta] = velocity3DToSpherical(u3d, v3d, w3d, phi, theta);
    
    [ns] = asmFinishRead(ns);

    fig_1 = figure();
    set(fig_1,'position',pOsItiON);
    surf(y3d,x3d,z3d,tmp);
    view(3)
    colormap jet
    shading interp
    grid on
    caxis([0,1])
    colorbar
    set(gca,'FontSize',FontSize);
    xlabel('$x_2$','FontSize',labelFontSize,'interpreter','latex');
    ylabel('$x_1$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex');  
    zlabel('$x_3$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex')
    set(gca,'YDir','reverse');
    xlim([-1 1]) ;
    xticks([-1,-0.5,0,0.5,1]);
    ylim([-1 1]) ;
    yticks([-1,-0.5,0,0.5,1]);
    zlim([0,1])
    zticks([0 0.4 0.7 1])
    title('$T$','Interpreter','latex','FontSize',titleFontSize);

    fig_2 = figure();
    set(fig_2,'position',pOsItiON);
    surf(y3d,x3d,z3d,uPhi);
    view(3)
    colormap jet
    shading interp
    grid on
    caxis auto
    colorbar
    set(gca,'FontSize',FontSize);
    xlabel('$x_2$','FontSize',labelFontSize,'interpreter','latex');
    ylabel('$x_1$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex');  
    zlabel('$x_3$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex')
    set(gca,'YDir','reverse');
    xlim([-1 1]) ;
    xticks([-1,-0.5,0,0.5,1]);
    ylim([-1 1]) ;
    yticks([-1,-0.5,0,0.5,1]);
    zlim([0,1])
    zticks([0 0.4 0.7 1])
    title('$u_{\phi}$','Interpreter','latex','FontSize',titleFontSize);

    fig_3 = figure();
    set(fig_3,'position',pOsItiON);
    surf(y3d,x3d,z3d,vTheta);
    view(3)
    colormap jet
    shading interp
    grid on
    caxis auto
    colorbar
    set(gca,'FontSize',FontSize);
    xlabel('$x_2$','FontSize',labelFontSize,'interpreter','latex');
    ylabel('$x_1$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex');  
    zlabel('$x_3$','Rotation',0,'FontSize',labelFontSize,'interpreter','latex')
    set(gca,'YDir','reverse');
    xlim([-1 1]) ;
    xticks([-1,-0.5,0,0.5,1]);
    ylim([-1 1]) ;
    yticks([-1,-0.5,0,0.5,1]);
    zlim([0,1])
    zticks([0 0.4 0.7 1])
    title('$v_{\theta}$','Interpreter','latex','FontSize',titleFontSize);

end