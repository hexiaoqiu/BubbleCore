function [A] = intFuncOnBubbleAcc(x,y,field,x2dField,y2dField, r_c)

%     r_c = 1;

    x2dFieldGPU = gpuArray(x2dField);
    y2dFieldGPU = gpuArray(y2dField);
    fieldGPU = gpuArray(field);

    n_x = numel(x);
    n_y = numel(y);

    A = 0;
    parfor i_x = 1:n_x-1
        for j_y = 1:n_y-1
            x_sub = linspace(x(i_x), x(i_x+1),4);
            y_sub = linspace(y(j_y), y(j_y+1),4);

            [xGrid_sub,yGrid_sub] = meshgrid(x_sub,y_sub);
            zGrid_sub = real( sqrt(1-xGrid_sub.^2-yGrid_sub.^2) );
            r_sub = sqrt(xGrid_sub.^2 + yGrid_sub.^2);
            x2d = xGrid_sub./(1 + zGrid_sub);
            y2d = yGrid_sub./(1 + zGrid_sub);
            field_sub = gather( interp2(x2dFieldGPU,y2dFieldGPU,fieldGPU,x2d,y2d,'linear') );
            field_sub(r_sub >= r_c) = 0;
            dS = 1./zGrid_sub;
            dS(r_sub >= r_c) = 0;
            if sum(field_sub.*dS,'all')~=0
                A = A + int2DimSimpsonOrder3(x_sub,y_sub,field_sub.*dS);
            end
        end
    end

end