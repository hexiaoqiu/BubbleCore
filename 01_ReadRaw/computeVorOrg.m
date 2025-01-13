function computeVorOrg(caseOrgDir, x2dGauche, x2dDroit, y2dBas, n1, n2, maxN)

    rootFileNameU = 'u_';
    rootFileNameV = 'v_';
    rootFileNameVor = 'vor_';

    h = (x2dDroit - x2dGauche) / n1;
    vorOrg = zeros(n2,n1);
    for k = 1:maxN
        
        
        uFileName = [rootFileNameU,num2str(k,'%d'),'.bin'];
        vFileName = [rootFileNameV,num2str(k,'%d'),'.bin'];
        vorFileName = [rootFileNameVor,num2str(k,'%d'),'.bin'];
        
        uFilePath = fullfile(caseOrgDir,uFileName);
        vFilePath = fullfile(caseOrgDir,vFileName);
        vorFilePath = fullfile(caseOrgDir,vorFileName);

        uFile = fopen(uFilePath,'r');
        vFile = fopen(vFilePath,'r');

        u2dOrg = fread(uFile,[n2,n1+1],'double');
        v2dOrg = fread(vFile,[n2+1,n1],'double');
        
        fclose(uFile);
        fclose(vFile);

        for i=1:n1
            for j=1:n2
                xx=x2dGauche + (i-1)*h;
                yy=y2dBas + (j-1)*h;    
                if ((i<=n1-1)&&(j<=n1-1)&&((xx^2+yy^2) <= 1))
                    vorOrg(j,i)= 0.25*(1.0+xx^2+yy^2)*(( v2dOrg(j+1,i+1)-v2dOrg(j+1,i))/h-(u2dOrg(j+1,i+1)-u2dOrg(j,i+1))/h)+0.25*yy*(u2dOrg(j,i+1)+u2dOrg(j+1,i+1))-0.25*xx*(v2dOrg(j+1,i) +v2dOrg(j+1,i+1));
                else
                    vorOrg(j,i)=0;
                end      
            end
        end

        vorFile = fopen(vorFilePath,'w');
        fwrite(vorFile,vorOrg,'double');
        fclose(vorFile);

    end

end