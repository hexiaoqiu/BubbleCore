function [k,sp_ener,sp_enst,sp_entropy,sp_buoy,flux_ener,flux_enst,flux_entropy,flux_buoy]=getSphFluxHxq(bubble,timeStepStart,timeStepEnd)
    t0_debug = clock;

    % case coefficients
%     St = bubble.St;
%     Ff = bubble.Ff;

    %%% Size of the grid %%%%
    n_cell = bubble.n1;
    n_half = n_cell/2;

    % half size of computational domain
    x2dMax = bubble.x2dDroit;
    x2dMin = bubble.x2dGauche;
    y2dMax = bubble.y2dHaut;
    y2dMin = bubble.y2dBas;
    x2dS = bubble.x2dS;
    y2dS = bubble.y2dS;
    Lx = x2dMax*2;
    Ly = y2dMax*2;
    d_cell=Lx/n_cell;
    maxX2dS = x2dMax - d_cell/2;
    minX2dS = x2dMin + d_cell/2;
    maxY2dS = y2dMax - d_cell/2;
    minY2dS = y2dMin + d_cell/2;

    % distance between mesh nodes 
    invMaxX2dS = 1/(x2dMax-d_cell/2);

    % 2D projection system mesh grid
    [x,y] = meshgrid( minX2dS:d_cell:maxX2dS, ...,
        minY2dS:d_cell:maxY2dS);
    % lines = x direction/ coloumns = y direction
    x=x';
    y=y';
    % coef for transform to 3D Cartesian
    coef = 2./(1 + x.^2 + y.^2);
    % variables for Bouyancy Sp and Flux
    delR = pi/(n_cell);
    delT = 2*pi/n_cell;
    % X_pol,Y_pol,Z_pol是极坐标形式下的坐标举证，_pol代表 polaris极坐标
    % 每一行是一个固定半径旋转一周的网格结点，每一列是同一个极角下的不同半径的结点
    X_pol = zeros(n_half,n_cell);
    Y_pol = zeros(n_half,n_cell);
    Z_pol = zeros(n_half,n_cell);
    for ri = 1:n_half
        % theta就是球坐标下的theta角，变化范围从0到pi/2
        % 对应r从0到1
        theta = (pi/2)/(n_cell) + (ri - 1)*delR;
        % r 是投影坐标系下的极坐标半径
        r = sin(theta)/(1+cos(theta));
        for ti = 1:n_cell
    
            t = (ti - 1)*delT;
            xx = r*cos(t);
            yy = r*sin(t);    
           
            coef2 = 2/(1 + xx^2 + yy^2);
            X_pol(ri,ti)=coef2*xx;
            Y_pol(ri,ti)=coef2*yy;
            Z_pol(ri,ti)=coef2*(1-xx^2-yy^2)/2;
        end
    end
    % acos(Z_pol) = 球坐标下的theta角
    Sin_Theta = sin(acos(Z_pol));

    % disque is a mask to filter the unwanted mesh nodes in projection 2D system
    disque=ones(n_cell,n_cell);
    %%%%%%%
    %%%% Here, another windowing definition
    %%%%%%%
    lim1=0.98;
    lim2=1.002;
    for tx=1:n_cell
        for ty=1:n_cell
            % k is the distance to the origin in 2D system
            % 索引坐标的原点在 [(n_cell-1)/2, (n_cell-1)/2] 而 
            % sqrt( ( tx-(n_cell-1)/2 )^2 + ( ty-(n_cell-1)/2)^2 ) 相当于
            % 到原点有多少个结点
            % 注意： 每个结点对应的长度为 (Lx-d_cell) / n_cell+1 
            % Lx-d_cell 是向量网格最左边结点 到 向量网格最右边结点的距离
            % n_cell+1 向量网格从最左边结点到最右边结点一共有 n_cell-1 个结点
            k = (Lx-d_cell) * sqrt( ( tx-(n_cell-1)/2 )^2 + ( ty-(n_cell-1)/2)^2 ) ...,
                / ...,
                (n_cell+1);
            if (k<=lim1)
                disque(tx,ty)=1;
            elseif (k>lim1) && (k<=lim2)
                disque(tx,ty)=(1+cos((k-lim1)*pi/((lim2-lim1))))/2;
            else
                disque(tx,ty)=0;
            end

        end
    end


    nbtime = timeStepEnd - timeStepStart + 1;
    
    sp_enst=zeros(n_half,nbtime);
    sp_ener=zeros(n_half,nbtime);
    sp_entropy=zeros(n_half,nbtime);
    sp_buoy=zeros(n_half,nbtime);

    transf_enst=zeros(n_half,nbtime);
    transf_ener=zeros(n_half,nbtime);
    transf_entropy=zeros(n_half,nbtime);
    transf_buoy=zeros(n_half,nbtime);


    

    % endtime=10;
    %%%%%%%%
    %%%%  Loop on the files
    %%%%%%%%
    % parallel prepare
    n_x = bubble.n1;
    n_y = bubble.n2;
    caseDir = bubble.path;
    rootFileNameU = bubble.rootFileNameU;
    rootFileNameV = bubble.rootFileNameV;
    rootFileNameTmp = bubble.rootFileNameTmp;
    t1_debug = clock;
    parfor time = timeStepStart:timeStepEnd

        disp(['time = ',num2str(time,'%d')]);
        % fprintf(logFile,'%s\n',['time = ',num2str(time,'%d')]);

        temp = sphParGetTmp(n_x,n_y,time,rootFileNameTmp,caseDir);
        [u] = sphParGetU(n_x,n_y,time,rootFileNameU,caseDir);
        [v] = sphParGetV(n_x,n_y,time,rootFileNameV,caseDir);
        
        temp = temp';
        u = u';
        v = v';
        
        tp_u=u(2:n_cell+1,1:n_cell);
        u_cent=(u(1:n_cell,1:n_cell)+tp_u(1:n_cell,1:n_cell))*0.5;
        
        tp_v=v(1:n_cell,2:n_cell+1);
        v_cent=(v(1:n_cell,1:n_cell)+tp_v(1:n_cell,1:n_cell))*0.5;
        
        extra = y.*u_cent - x.*v_cent;
        
        [duy,dux] = gradient(u_cent,d_cell);
        [dvy,dvx] = gradient(v_cent,d_cell);

        w=(dvx-duy)+2.*coef.*extra;
        [dwy,dwx] = gradient(w,d_cell);
        [dtempy,dtempx] = gradient(temp,d_cell);

        % The Buoyancy field
        U_N= -coef.*(u_cent.*x+v_cent.*y)./sqrt(x.^2+y.^2);% Radial velovity
        imU_N = ImToPolarHxq(U_N,x2dS,y2dS);
        imTemp=ImToPolarHxq(temp,x2dS,y2dS);
        imBuoy = imU_N.*imTemp.*Sin_Theta;
        buoyancy= PolarToIm(imBuoy,0, invMaxX2dS, n_cell, n_cell);
        [dbuoyy,dbuoyx] = gradient(buoyancy,d_cell);

        %----------- Fluxes ------------------------------------------------------
        % res_ 代表的是对流导数，下列对流导数是在投影空间中计算得到
        res_u = coef.*((u_cent.*dux + v_cent.*duy) + coef.*(-x.*u_cent.^2 - 2.*y.*u_cent.*v_cent + x.*v_cent.^2));
        res_v = coef.*((u_cent.*dvx + v_cent.*dvy) + coef.*( y.*u_cent.^2 - 2.*x.*u_cent.*v_cent - y.*v_cent.^2));  
        res_w = (u_cent.*dwx + v_cent.*dwy);
        res_temp = (u_cent.*dtempx + v_cent.*dtempy);
        
        u_cent=coef.*u_cent;
        v_cent=coef.*v_cent;
        res_buoy = (u_cent.*dbuoyx + v_cent.*dbuoyy);

        %% The flux of the F S term and viscous term
%         imFTerm = Ff*(u_cent.^2 + v_cent.^2);
        
        %%%%%% First version with mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        imW=ImToPolarHxq(w,x2dS,y2dS);
        imU=ImToPolarHxq(u_cent,x2dS,y2dS);
        imV=ImToPolarHxq(v_cent,x2dS,y2dS);
        imTemp=ImToPolarHxq(temp,x2dS,y2dS);

        imres_u = ImToPolarHxq(res_u,x2dS,y2dS);
        imres_v = ImToPolarHxq(res_v,x2dS,y2dS);
        imres_w = ImToPolarHxq(res_w,x2dS,y2dS);
        imres_temp = ImToPolarHxq(res_temp,x2dS,y2dS);

        imBuoy=ImToPolarHxq(buoyancy',x2dS,y2dS);
        imres_buoy = ImToPolarHxq(res_buoy',x2dS,y2dS);
        
        %%%%%%%%% Zero padding on the whole sphere

        testimW = [imW' zeros(n_cell,n_half)];
        testimTemp = [imTemp' zeros(n_cell,n_half)];
        testimres_w = [imres_w' zeros(n_cell,n_half)];
        testimres_temp = [imres_temp' zeros(n_cell,n_half)];
        testimU = [imU' zeros(n_cell,n_half)];
        testimV = [imV' zeros(n_cell,n_half)];
        testimres_u = [imres_u' zeros(n_cell,n_half)];
        testimres_v = [imres_v' zeros(n_cell,n_half)];

        testimBuoy = [imBuoy' zeros(n_cell,n_half)];
        testimres_buoy = [imres_buoy' zeros(n_cell,n_half)];

        %%%%%%%%%% Spherical harmonics decompositions   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        coef_W = FSTRep2SphHRep(FST_semi_fly_mex(testimW));
        coef_Temp = FSTRep2SphHRep(FST_semi_fly_mex(testimTemp));
        
        coef_res_w = FSTRep2SphHRep(FST_semi_fly_mex(testimres_w));
        
        coef_res_temp = FSTRep2SphHRep(FST_semi_fly_mex(testimres_temp));

        coef_Buoyancy = FSTRep2SphHRep(FST_semi_fly_mex(testimBuoy));
        coef_res_buoy = FSTRep2SphHRep(FST_semi_fly_mex(testimres_buoy));
        
        %%%%%%%%%% 1st version %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        coef_U = FSTRep2SphHRep(FST_semi_fly_mex(testimU));
        coef_V = FSTRep2SphHRep(FST_semi_fly_mex(testimV));

        coef_res_u = FSTRep2SphHRep(FST_semi_fly_mex(testimres_u));
        coef_res_v = FSTRep2SphHRep(FST_semi_fly_mex(testimres_v));
        
        sp_enst_t=zeros(n_half,1);
        sp_ener_t=zeros(n_half,1);
        sp_entropy_t=zeros(n_half,1);
        sp_buoy_t=zeros(n_half,1);

        transf_enst_t=zeros(n_half,1);
        transf_ener_t=zeros(n_half,1);
        transf_entropy_t=zeros(n_half,1);
        transf_buoy_t=zeros(n_half,1);
    
        for degree = 0:n_half-1            
            degree1 = degree + 1;
            order = -degree:degree;
            index = jm2idx(degree,order);
                        
            sp_enst_t(degree1) = sp_enst_t(degree1) + 0.5*norm(coef_W(index),'fro')^2;
            sp_entropy_t(degree1) = sp_entropy_t(degree1) + 0.5*norm(coef_Temp(index),'fro')^2;
            sp_ener_t(degree1) = sp_ener_t(degree1) + 0.5*(norm(coef_U(index),'fro')^2+ norm(coef_V(index),'fro')^2);
            sp_buoy_t(degree1) = sp_buoy_t(degree1) + 0.5*norm(coef_Buoyancy(index),'fro')^2;

                        
            transf_ener_t(degree1) = transf_ener_t(degree1) - sum(conj(coef_U(index)).*coef_res_u(index) + conj(coef_V(index)).*coef_res_v(index));          
            transf_enst_t(degree1) = transf_enst_t(degree1) - sum(conj(coef_W(index)).*coef_res_w(index));
            transf_entropy_t(degree1) = transf_entropy_t(degree1) - sum(conj(coef_Temp(index)).*coef_res_temp(index));
            transf_buoy_t(degree1) = transf_buoy_t(degree1) - sum(conj(coef_Buoyancy(index)).*coef_res_buoy(index));


        end
        
        sp_enst(:,time) = sp_enst_t;
        sp_ener(:,time) = sp_ener_t;
        sp_entropy(:,time) = sp_entropy_t;
        sp_buoy(:,time) = sp_buoy_t;
        
        transf_ener(:,time) = transf_ener_t;
        transf_enst(:,time) = transf_enst_t;
        transf_entropy(:,time) = transf_entropy_t;
        transf_buoy(:,time) = transf_buoy_t;        
            


    end
    t2_debug = clock;
    tChar = timeInfor(t0_debug,t1_debug,t2_debug,1,1);
    % fprintf(logFile, '%s\n', tChar);
    disp(tChar);
    
    sp_enst = mean(sp_enst,2);
    sp_ener = mean(sp_ener,2);
    sp_entropy = mean(sp_entropy,2);
    sp_buoy = mean(sp_buoy,2);
    
    transf_ener = mean( transf_ener, 2);
    transf_enst = mean( transf_enst, 2);
    transf_entropy = mean( transf_entropy, 2);
    transf_buoy = mean( transf_buoy, 2);
    

    flux_ener = zeros(n_half,1);
    flux_enst = zeros(n_half,1);
    flux_entropy = zeros(n_half,1);
    flux_buoy = zeros(n_half,1);
    for k = 1:n_half
        flux_ener(k) = sum(transf_ener(k:n_half));
        flux_enst(k) = sum(transf_enst(k:n_half));
        flux_entropy(k) = sum(transf_entropy(k:n_half));
        flux_buoy(k) = sum(transf_buoy(k:n_half));
    end
            
    k = (0:n_half-1)';

end