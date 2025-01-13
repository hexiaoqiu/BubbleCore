function [storeDir] = makeDir4BubblePlus(rootDir, r_c, Ra)
    vibName = ['r_c_',num2str(r_c,5)];
    caseName = ['Ra_', num2str(Ra, '%1.0e')];
    storeDir = fullfile(rootDir, vibName, caseName); 
end