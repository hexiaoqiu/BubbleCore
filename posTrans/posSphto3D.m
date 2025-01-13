function [x3d,y3d,z3d] = posSphto3D(phi,theta)

    szPhi = size(phi);
    szTheta = size(theta);

    condition_1 = (numel(szPhi) == 2)&&(numel(szTheta) == 2);
    if condition_1 == false
        disp('Invalid input!')
        disp('The input should be matrix or vector!')
    end

    inputIsMatrix = isempty(find(szPhi == 1,1)) && isempty(find(szTheta == 1,1));
    if inputIsMatrix == true
        r = 1;
        % transform to 3D grid
        x3d = r .* sin(theta) .* cos(phi);
        y3d = r .* sin(theta) .* sin(phi);
        z3d = r .* cos(theta);
    end

    inputIsVetor = ( ~isempty(find(szPhi == 1,1)) )&&( ~isempty(find(szTheta == 1,1)) );
    if inputIsVetor == true
        r = 1;
        numRow = numel(phi);
        numLine = numel(theta);
        x3d = zeros(numLine,numRow);
        y3d = zeros(numLine,numRow);
        z3d = zeros(numLine,numRow);
        % transform to 3D grid
        for i = 1:numLine
            for j = 1:numRow
                x3d(i,j) = r*sin(theta(i))*cos(phi(j));
                y3d(i,j) = r*sin(theta(i))*sin(phi(j));
                z3d(i,j) = r*cos(theta(i));
            end
        end
    end

end