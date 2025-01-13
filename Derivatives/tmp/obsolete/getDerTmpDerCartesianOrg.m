function [parTmpParX3d, parTmpParY3d, parTmpParZ3d] = getDerTmpDerCartesianOrg(bubble, timeStep)

    n1 = bubble.n1;
    n2 = bubble.n2;

    x2d  = bubble.x2dS;
    y2d  = bubble.y2dS;
    h1 = (bubble.x2dDroit - bubble.x2dGauche) / n1;
    h2 = (bubble.y2dHaut - bubble.y2dBas) / n2;

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3d,y3d,z3d] = pos2Dto3D(x2dGrid,y2dGrid);
%     radius = sqrt(x2dGrid.^2 + y2dGrid.^2);

    parX2dParX3d = 1 ./ (1+z3d);
    parX2dParY3d = zeros(size(x3d));
    parX2dParZ3d = -1*x3d ./ (1+z3d).^2;

    parY2dParX3d = zeros(size(y3d));
    parY2dParY3d = 1 ./ (1+z3d);
    parY2dParZ3d = -1*y3d ./ (1+z3d).^2;

                    
    tmpOrg = readField(bubble, 'tmp', timeStep);
%     tmpOrg(radius>=1) = 1;

    % calculate the derivative in projection coordinate
    parTmpParX2d = zeros( n2, n1 );
    parTmpParY2d = zeros( n2, n1 );
    

    parTmpParX2d(:,2:n1-1) = (tmpOrg(:,3:n1) - tmpOrg(:,1:n1-2)) ./ (2*h1);
    parTmpParY2d(2:n2-1,:) = (tmpOrg(3:n2,:) - tmpOrg(1:n2-2,:)) ./ (2*h2);


    parTmpParX3d = parTmpParX2d.*parX2dParX3d + parTmpParY2d.*parY2dParX3d;
    parTmpParY3d = parTmpParX2d.*parX2dParY3d + parTmpParY2d.*parY2dParY3d;
    parTmpParZ3d = parTmpParX2d.*parX2dParZ3d + parTmpParY2d.*parY2dParZ3d;


end