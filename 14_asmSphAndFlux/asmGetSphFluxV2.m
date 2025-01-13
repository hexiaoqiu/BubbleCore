function [k,sp_ener,sp_enst,sp_entropy,sp_buoy,flux_ener,flux_enst,flux_entropy,flux_buoy]=asmGetSphFluxV2(asmCase,t0,t1,r2D_max,r2D_min)

    %%% Size of the grid %%%%
    [idxSubCase] = asmGetSubCaseIdxByTime(asmCase,t0);
    n = asmCase.n1(idxSubCase);
    nn=n/2;

    % half size of computational domain
    n1= asmCase.x2dDroit;
    % distance between mesh nodes
    nn1=2*n1/n; 
    nn2 = 1/(n1-nn1/2);

    % 2D projection system mesh grid
    [x,y] = meshgrid(-n1+nn1/2:nn1:n1-nn1/2,-n1+nn1/2:nn1:n1-nn1/2);
    % lines = x direction/ coloumns = y direction
    x=x';
    y=y';
    % coef for transform to 3D Cartesian
    coef = 2./(1 + x.^2 + y.^2);
    % variables for Bouyancy Sp and Flux
    delR = pi/(2*nn);
    delT = 2*pi/n;

    X_pol = zeros(nn,n);
    Y_pol = zeros(nn,n);
    Z_pol = zeros(nn,n);
    for ri = 1:nn
        theta = pi/(4*nn) + (ri - 1)*delR;   
        r = sin(theta)/(1+cos(theta));
        for ti = 1:n
    
            t = (ti - 1)*delT;
            xx = r*cos(t);
            yy = r*sin(t);    
           
            coef2 = 2/(1 + xx^2 + yy^2);
            X_pol(ri,ti)=coef2*xx;
            Y_pol(ri,ti)=coef2*yy;
            Z_pol(ri,ti)=coef2*(1-xx^2-yy^2)/2;
        end
   end
   Sin_Theta = sin(acos(Z_pol));

    % disque is a mask to filter the unwanted mesh nodes in projection 2D system
    disque=ones(n,n);
    %%%%%%%
    %%%% Here, another windowing definition
    %%%%%%%
    lim0 = r2D_min;
    lim1=0.98;
    lim2=1.002;
    lim3 = r2D_max;
    for tx=1:n
        for ty=1:n
            % k is the distance to the origin in 2D system
            k=(2*n1-nn1)*(sqrt((tx-(2*nn-1)/2)^2+(ty-(2*nn-1)/2)^2))/(n+1);
            if (k<=lim3) && (k>=lim0)
                if (k<=lim1)
                    disque(tx,ty)=1;
                elseif (k>lim1) && (k<=lim2)
                    disque(tx,ty)=(1+cos((k-lim1)*pi/((lim2-lim1))))/2;
                else
                    disque(tx,ty)=0;
                end
            else
                disque(tx,ty)=0;
            end
        end
    end

    
    sp_enst=zeros(nn,1);
    sp_ener=zeros(nn,1);
    sp_entropy=zeros(nn,1);
    sp_buoy=zeros(nn,1);

    transf_enst=zeros(nn,1);
    transf_ener=zeros(nn,1);
    transf_entropy=zeros(nn,1);
    transf_buoy=zeros(nn,1);


    
    %%%%%%%%
    %%%%  Loop on the files
    %%%%%%%
    idxG0 = asmGetGlobalIdx(asmCase,t0);
    idxG1 = asmGetGlobalIdx(asmCase,t1);
    numStep = idxG1 - idxG0 + 1;
    numStepOneRun = 100;
    numRun = floor(numStep/numStepOneRun);
    numStepLastRun = rem(numStep,numStepOneRun);
    if numStepLastRun == 0
        numStepList = ones(numRun,1)*numStepOneRun;
    else
        numRun = numRun + 1;
        numStepList = ones(numRun,1)*numStepOneRun;
        numStepList(numRun) = numStepLastRun;
    end
        
        
    for idxRun = 1:numRun
        tmpOrg = zeros(n,n,numStepList(idxRun));
        u2dOrg = zeros(n+1,n,numStepList(idxRun));
        v2dOrg = zeros(n,n+1,numStepList(idxRun));
        
        idxTimeStep = 0;
        while asmCase.nextReadTime <= t1

            idxTimeStep = idxTimeStep + 1;

            if asmCase.readCounter == 0
                [asmCase,tmpOrgOneStep, u2dOrgOneStep, v2dOrgOneStep, ~] = asmInitRead(asmCase,t0);
            else
                [asmCase,tmpOrgOneStep, u2dOrgOneStep, v2dOrgOneStep, ~] = asmReadOneStepForward(asmCase);
            end
            disp(['In sub case:',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}])
            disp(['time = ',num2str(asmCase.lastReadTime,'%g')])
            tmpOrg(:,:,idxTimeStep) = tmpOrgOneStep';
            u2dOrg(:,:,idxTimeStep) = u2dOrgOneStep';
            v2dOrg(:,:,idxTimeStep) = v2dOrgOneStep';
            if idxTimeStep == numStepList(idxRun)
                disp('Reach the limit, turn to calculation parallel!')
                break
            end
        end
        
        workingPath = asmCase.subCaseDir{asmCase.readNowSubCaseIdx};
        parfor idxTimeStep = 1:numStepList(idxRun)
            disp(['In sub case:',workingPath])
            disp(['Parallel Processing time step idx = ',num2str(idxTimeStep,'%d')])
            temp = tmpOrg(:,:,idxTimeStep);
            u = u2dOrg(:,:,idxTimeStep);
            v = v2dOrg(:,:,idxTimeStep);

            tp_u=u(2:n+1,1:n);
            u_cent=(u(1:n,1:n)+tp_u(1:n,1:n))*0.5;

            tp_v=v(1:n,2:n+1);
            v_cent=(v(1:n,1:n)+tp_v(1:n,1:n))*0.5;

            extra = y.*u_cent - x.*v_cent;

            [duy,dux] = gradient(u_cent,nn1);
            [dvy,dvx] = gradient(v_cent,nn1);

            w=(dvx-duy)+2.*coef.*extra;
            [dwy,dwx] = gradient(w,nn1);
            [dtempy,dtempx] = gradient(temp,nn1);

            % The Buoyancy field
            U_N= -coef.*(u_cent.*x+v_cent.*y)./sqrt(x.^2+y.^2);% Radial velovity
            imU_N = ImToPolarAcc(U_N,0,nn2,nn,n);
            imTemp=ImToPolarAcc(temp,0,nn2,nn,n);
            imBuoy = imU_N.*imTemp.*Sin_Theta;
            buoyancy= PolarToImAcc(imBuoy,0, nn2, n, n);
            [dbuoyy,dbuoyx] = gradient(buoyancy,nn1);

            %----------- Fluxes ------------------------------------------------------
            res_u = coef.*((u_cent.*dux + v_cent.*duy) + coef.*(-x.*u_cent.^2 - 2.*y.*u_cent.*v_cent + x.*v_cent.^2));
            res_v = coef.*((u_cent.*dvx + v_cent.*dvy) + coef.*( y.*u_cent.^2 - 2.*x.*u_cent.*v_cent - y.*v_cent.^2));  
            res_w = (u_cent.*dwx + v_cent.*dwy);
            res_temp = (u_cent.*dtempx + v_cent.*dtempy);

            u_cent=coef.*u_cent;
            v_cent=coef.*v_cent;
            res_buoy = (u_cent.*dbuoyx + v_cent.*dbuoyy);


            %%%%%% First version with mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            imW=ImToPolarAcc(disque.*w',0,nn2,nn,n);
            imU=ImToPolarAcc(disque.*u_cent',0,nn2,nn,n);
            imV=ImToPolarAcc(disque.*v_cent',0,nn2,nn,n);
            imTemp=ImToPolarAcc(disque.*temp',0,nn2,nn,n);

            imres_u = ImToPolarAcc(disque.*res_u',0,nn2,nn,n);
            imres_v = ImToPolarAcc(disque.*res_v',0,nn2,nn,n);
            imres_w = ImToPolarAcc(disque.*res_w',0,nn2,nn,n);
            imres_temp = ImToPolarAcc(disque.*res_temp',0,nn2,nn,n);

            imBuoy=ImToPolarAcc(buoyancy',0,nn2,nn,n);
            imres_buoy = ImToPolarAcc(res_buoy',0,nn2,nn,n);

            %%%%%%%%% Zero padding on the whole sphere

            testimW = [imW' zeros(n,nn)];
            testimTemp = [imTemp' zeros(n,nn)];
            testimres_w = [imres_w' zeros(n,nn)];
            testimres_temp = [imres_temp' zeros(n,nn)];
            testimU = [imU' zeros(n,nn)];
            testimV = [imV' zeros(n,nn)];
            testimres_u = [imres_u' zeros(n,nn)];
            testimres_v = [imres_v' zeros(n,nn)];

            testimBuoy = [imBuoy' zeros(n,nn)];
            testimres_buoy = [imres_buoy' zeros(n,nn)];

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

            sp_enst_t=zeros(nn,1);
            sp_ener_t=zeros(nn,1);
            sp_entropy_t=zeros(nn,1);
            sp_buoy_t=zeros(nn,1);

            transf_enst_t=zeros(nn,1);
            transf_ener_t=zeros(nn,1);
            transf_entropy_t=zeros(nn,1);
            transf_buoy_t=zeros(nn,1);

            for degree = 0:nn-1            
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

            sp_enst = sp_enst + sp_enst_t;
            sp_ener = sp_ener + sp_ener_t;
            sp_entropy = sp_entropy + sp_entropy_t;
            sp_buoy = sp_buoy + sp_buoy_t;

            transf_ener = transf_ener + transf_ener_t;
            transf_enst = transf_enst + transf_enst_t;
            transf_entropy = transf_entropy + transf_entropy_t;
            transf_buoy = transf_buoy + transf_buoy_t;        

        end
    end
    
    sp_enst = sp_enst./numStep;
    sp_ener = sp_ener./numStep;
    sp_entropy = sp_entropy./numStep;
    sp_buoy = sp_buoy./numStep;
    
    transf_ener = transf_ener./numStep;
    transf_enst = transf_enst./numStep;
    transf_entropy = transf_entropy./numStep;
    transf_buoy = transf_buoy./numStep;
    

    flux_ener = zeros(nn,1);
    flux_enst = zeros(nn,1);
    flux_entropy = zeros(nn,1);
    flux_buoy = zeros(nn,1);
    for k = 1:nn
        flux_ener(k) = sum(transf_ener(k:nn));
        flux_enst(k) = sum(transf_enst(k:nn));
        flux_entropy(k) = sum(transf_entropy(k:nn));
        flux_buoy(k) = sum(transf_buoy(k:nn));
    end
            
    k = (0:nn-1)';
    [asmCase] = asmFinishRead(asmCase);
end