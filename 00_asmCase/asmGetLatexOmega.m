function [omegaStr] = asmGetLatexOmega(asmCase)
    
    omega = num2str(asmCase.Omega_vib,'%g');
    omegaStr = ['$\omega=',omega,'$'];
    
end