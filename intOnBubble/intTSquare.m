function [A] = intTSquare(bubble,theta,timeStep,N)

    % form the mesh
    % N = 1000;
    xMax = 1;
    xMin = -1;
    yMax = 1;
    yMin = -1;
    [x,y] = intMeshVec(xMax,xMin,yMax,yMin,N);
    [xMesh,yMesh]=meshgrid(x,y);
    zMesh = zeros(N,N);
    for i = 1:N
        for j = 1:N
            r = sqrt( xMesh(j,i).^2  + yMesh(j,i).^2 );
            if r <= 1
                zMesh(j,i) = sqrt(1 - xMesh(j,i).^2 - yMesh(j,i).^2);
            else
                zMesh(j,i) = 0;
            end
        end
    end
    [x2dMesh,y2dMesh] = pos3Dto2D(xMesh,yMesh,zMesh);
    
    % interpolate ST
    tmpOrg = readField(bubble,'tmp',timeStep);
    tmp = interp2(bubble.x2dS,bubble.y2dS,tmpOrg,x2dMesh,y2dMesh);
    r_1 = 1*tan(theta/2);
    [A] = intFuncOnBubble(x,y,tmp.^2,r_1);
end
