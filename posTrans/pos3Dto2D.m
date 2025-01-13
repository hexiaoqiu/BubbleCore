function [x2d, y2d] = pos3Dto2D(x3d,y3d)

    szX3d = size(x3d);
    szY3d = size(y3d);

    condition_1 = (numel(szX3d) == 2)&&(numel(szY3d) == 2);
    if condition_1 == false
        disp('Invalid input!')
        disp('The input should be matrix or vector!')
    end
    
    X3dIsVector =  (szX3d(1) == 1)||(szX3d(2) == 1);
    Y3dIsVector =  (szY3d(1) == 1)||(szY3d(2) == 1);
    X3dIsMatrix =  (szX3d(1) > 1)&&(szX3d(2) > 1);
    Y3dIsMatrix =  (szY3d(1) > 1)&&(szY3d(2) > 1);

    if  X3dIsVector&&Y3dIsVector
        numLine = numel(y3d);
        numColumn = numel(x3d);
        x2d = zeros(numLine,numColumn);
        y2d = zeros(numLine,numColumn);
        for i = 1:numLine
            for j = 1:numColumn
                x2d(i,j) = x3d(j)/(1 + real( sqrt(1-x3d(j)^2 - y3d(i)^2)) );
                y2d(i,j) = y3d(i)/(1 + real( sqrt(1-x3d(j)^2 - y3d(i)^2)) );
            end
        end
    end

    if X3dIsMatrix&&Y3dIsMatrix
        z3d = real( sqrt(1- x3d.^2 - y3d.^2) );
        x2d = x3d ./ (1 + z3d);
        y2d = y3d ./ (1 + z3d);
    end
    
end