function [caseDir] = getCaseDir(rootDir, Ra, invRo, Delta)
    deltaName = ['Delta',num2str(Delta,'%d')];
    caseName = ['Ra', num2str(Ra, '%1.0e'), 'Ro', num2str(invRo, '%1.2f')];
    caseDir = fullfile(rootDir, deltaName, caseName); 
end