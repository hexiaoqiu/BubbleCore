function [storeDir] = makeDir(rootDir, Ra, R0, Delta)
    deltaName = ['Delta',num2str(Delta,'%d')];
    caseName = ['Ra', num2str(Ra, '%1.0e'), 'Ro', num2str(R0, '%1.2f')];
    storeDir = fullfile(rootDir, deltaName, caseName); 
end