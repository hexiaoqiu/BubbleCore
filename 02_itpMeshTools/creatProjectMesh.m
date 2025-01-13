function [projectMesh] = createProjectMesh(x2dLim,y2dLim,N_x,N_y)
    
    x2dMin = x3dLim(1);
    x2dMax = x3dLim(2);
    y2dMin = y3dLim(1);
    y2dMax = y3dLim(2);

    projectMesh.x2d = linspace(x2dMin,x2dMax,N_x);
    projectMesh.y2d = linspace(y2dMin,y2dMax,N_y)';
    projectMesh.dx = (x2dMax - x2dMin)/(N_x-1);
    projectMesh.dy = (y2dMax - y2dMin)/(N_y-1);

end