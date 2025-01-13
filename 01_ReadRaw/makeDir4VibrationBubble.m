function [storeDir] = makeDir4VibrationBubble(rootDir, A, Omega, Ra)
    vibName = ['Omega_',num2str(Omega,5),'_A_',num2str(A,5)];
    caseName = ['Ra_', num2str(Ra, '%1.0e')];
    storeDir = fullfile(rootDir, vibName, caseName); 
end