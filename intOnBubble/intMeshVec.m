function [x,y] = intMeshVec(xMax,xMin,yMax,yMin,N)
    
    dx = (xMax - xMin)/N;
    dy = (yMax - yMin)/N;
    x = (xMin+dx/2):dx:(xMax-dx/2);
    y = (yMin+dy/2):dy:(yMax-dy/2);

end
