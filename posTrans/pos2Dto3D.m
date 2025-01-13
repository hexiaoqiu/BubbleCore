function [x3d,y3d,z3d] = pos2Dto3D(x2d,y2d)

    x3d = 2.0 * x2d ./ (1.0 + x2d.^2 + y2d.^2);                
    y3d = 2.0 * y2d ./ (1.0 + x2d.^2 + y2d.^2);               
    z3d = (1.0 - x2d.^2 - y2d.^2) ./ (1.0 + x2d.^2 + y2d.^2);
    
    % situation of escaping the bubble
%     r = sqrt(x2d.^2 + y2d.^2);
%     z3d(r>1) = 0;
%     x3d(r>1) = 1;
%     y3d(r>1) = 1;

end