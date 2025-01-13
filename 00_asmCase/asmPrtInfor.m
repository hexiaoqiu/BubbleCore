function asmPrtInfor(asmCase)
    disp( '*************Assemble Case Information*************')
    disp(['real Ra =',num2str(asmCase.realRa,'%3.2e'),' A = ',num2str(asmCase.A,'%3.2f')])
    disp(['Ra = ',num2str(asmCase.Ra,'%1.0E'),' Pr = ',num2str(asmCase.Pr,'%g')]);
    disp(['1/Ro = ',num2str(asmCase.invRo,'%g'),' Delta = ',num2str(asmCase.Delta,'%g')]);
    disp(['r_c = ',num2str(asmCase.r_c,'%g')]);
    disp(['Number Sub Cases: ',num2str(asmCase.numSubCase,'%g')])
    for idxSubCase = 1:asmCase.numSubCase
        disp(['No. ',num2str(idxSubCase,'%g'),' sub case: ',asmCase.subCaseDir{idxSubCase}]);
        disp(['St = ',num2str(asmCase.St(idxSubCase),'%g'),' Ff = ',num2str(asmCase.Ff(idxSubCase),'%g')]);
        disp(['maxN = ',num2str(asmCase.maxN(idxSubCase),'%g'),' dt = ',num2str(asmCase.dt(idxSubCase),'%g')]);
        disp(['dtSave = ',num2str(asmCase.dtSave(idxSubCase),'%g')]);
    end
    disp( '*************Assemble Case Information End**********')
end
