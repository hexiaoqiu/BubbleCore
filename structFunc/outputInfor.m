function  outputInfor(logFile,structF)
    
    msg = { ...,
        ['Ra=',num2str(structF.Ra,'%g'),' ','Pr=', num2str(structF.Pr,'%g'),' Delta=', num2str(structF.Delta,'%g'), ' ', '1/Ro=',num2str(structF.Ro,'%g')]; ...,
        ['r_c=', num2str(structF.r_c,'%g'),' St=',num2str(structF.St,'%g'),' ','Ff=', num2str(structF.Ff,'%g')]; ..., 
    };
    for iWrite = 1:numel(msg)
        fprintf(logFile, '%s \n', msg{iWrite});
        disp(msg{iWrite});
    end
    
end