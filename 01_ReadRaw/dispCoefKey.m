function dispCoefKey(Ra,Pr,R0,Delta,r_c,St,Ff,maxN,dt,dtSave)
    disp( '*************Case Information*************')
    disp(['Ra = ',num2str(Ra,'%1.0E'),' Pr = ',num2str(Pr,'%g')]);
    disp(['1/Ro = ',num2str(R0,'%g'),' Delta = ',num2str(Delta,'%g')]);
    disp(['r_c = ',num2str(r_c,'%g')]);
    disp(['St = ',num2str(St,'%g'),' Ff = ',num2str(Ff,'%g')]);
    disp(['maxN = ',num2str(maxN,'%g'),' dt = ',num2str(dt,'%g')]);
    disp(['dtSave = ',num2str(dtSave,'%g')]);
    disp( '*************Case Information End**********')
end

