function [parTmpParX3dOut, parTmpParY3dOut, parTmpParZ3dOut] = getDerTmpDerCartesianBad(bubble, timeStep, itpMesh)

    n1 = bubble.n1;
    n2 = bubble.n2;

    x2d  = bubble.x2dS;
    y2d  = bubble.y2dS;
    h1 = (bubble.x2dDroit - bubble.x2dGauche) / n1;
    h2 = (bubble.y2dHaut - bubble.y2dBas) / n2;

    % calculate the local derivative of x2d y2d to x3d y3d z3d
    [x2dGrid, y2dGrid] = meshgrid(x2d,y2d);
    [x3d,y3d,z3d] = pos2Dto3D(x2dGrid,y2dGrid);

    parX2dParX3d = 1./( (1+sqrt(1-x3d.^2-y3d.^2)).^2 ) ...,
                    .* ...,
                    ( 1+sqrt(1-x3d.^2-y3d.^2) + (x3d.^2)./(sqrt(1-x3d.^2-y3d.^2)) );
    parX2dParY3d = (x3d.*y3d) ...,
                    ./ ...,
                    ( ( sqrt(1-x3d.^2-y3d.^2) ) .* (1+sqrt(1-x3d.^2-y3d.^2)).^2  );
    parX2dParZ3d = x3d ./ (1+z3d).^2;

    parY2dParX3d = (x3d.*y3d) ...,
                    ./ ...,
                    ( ( sqrt(1-x3d.^2-y3d.^2) ) .* (1+sqrt(1-x3d.^2-y3d.^2)).^2  );
    parY2dParY3d = 1./( (1+sqrt(1-x3d.^2-y3d.^2)).^2 ) ...,
                    .* ...,
                    ( 1+sqrt(1-x3d.^2-y3d.^2) + (y3d.^2)./(sqrt(1-x3d.^2-y3d.^2)) );
    parY2dParZ3d = y3d ./ (1+z3d).^2;
                    

    tmpOrg = readField(bubble, 'tmp', timeStep);
    
    % calculate the derivative in projection coordinate
    parTmpParX2d = zeros( n2, n1 );
    parTmpParY2d = zeros( n2, n1 );
    

    for j = 2:n1-1
        for i = 2:n2-1
            parTmpParX2d(i,j) = (tmpOrg(i,j+1) - tmpOrg(i,j-1))/(2*h1);
            parTmpParY2d(i,j) = (tmpOrg(i+1,j) - tmpOrg(i-1,j))/(2*h2);
        end
    end

    parTmpParX2d(1,:) = 0;
    parTmpParX2d(n2,:) = 0;
    parTmpParX2d(:,1) = 0;
    parTmpParX2d(:,n1) = 0;

    parTmpParY2d(1,:) = 0;
    parTmpParY2d(n2,:) = 0;
    parTmpParY2d(:,1) = 0;
    parTmpParY2d(:,n1) = 0;


    parTmpParX3d = parTmpParX2d.*parX2dParX3d + parTmpParY2d.*parY2dParX3d;
    parTmpParY3d = parTmpParX2d.*parX2dParY3d + parTmpParY2d.*parY2dParY3d;
    parTmpParZ3d = parTmpParX2d.*parX2dParZ3d + parTmpParY2d.*parY2dParZ3d;

    parTmpParX3dOut = interp2(x2d, y2d, parTmpParX3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parTmpParY3dOut = interp2(x2d, y2d, parTmpParY3d, itpMesh.x2d, itpMesh.y2d,'spline');
    parTmpParZ3dOut = interp2(x2d, y2d, parTmpParZ3d, itpMesh.x2d, itpMesh.y2d,'spline');

end