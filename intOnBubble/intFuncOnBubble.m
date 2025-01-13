function [A] = intFuncOnBubble(x,y,field,x2dField,y2dField)

        n_x = numel(x);
        n_y = numel(y);
        dx = x(2)-x(1);
        dy = y(2)-y(1);

        
%         [xGrid,yGrid] = meshgrid(x,y);
%         r = sqrt(xGrid.^2 + yGrid.^2);
%         dS = zeros(n_y,n_x);
%         dS(r<=r_1) = dSFunc(xGrid(r<=1),yGrid(r<=1));
%         dA =  dx*dy*dS.*Func;
%         A = sum(dA,'all');
         
        dA = zeros(n_y,n_x);
        for i = 1:n_x
            for j = 1:n_y
                r = sqrt( x(i)^2 + y(j)^2 );
                if r > 1
                    dA(j,i) = 0;
                elseif r <= 1
                    a = 0.5*1./sqrt(1-x(i)^2-y(j)^2);
                    b = -2*x(i);
                    c = -2*y(j);
                    parZParX = b*a;
                    parZParY = c*a;
                    dS = sqrt( 1 + parZParX.^2 + parZParY.^2 );
                    z = sqrt(1-x(i)^2-y(j)^2);
                    x2d = x(i)/(1 + z);
                    y2d = y(j)/(1 + z);
                    fieldOnThisPoint = interp2(x2dField,y2dField,field,x2d,y2d);
                    dA(j,i) = dx*dy*dS*fieldOnThisPoint;
                end
            end
        end
        A = sum(dA,'all');
end