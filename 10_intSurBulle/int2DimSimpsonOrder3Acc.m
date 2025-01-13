function [I] = int2DimSimpsonOrder3Acc(dx, dy, f)
% input is the dx and dy which is interval between les position vector x and y
% the read position is not needed since the integral do not need them
% because the integral do not depends on the position if the function shape
% is fixed

%     dx = x(2) - x(1);
%     x_0 = x(1);
%     x_1 = x(2);
%     x_2 = x(3);
%     x_3 = x(4);

%     dy = y(2) - y(1);
%     y_0 = y(1);
%     y_1 = y(2);
%     y_2 = y(3);
%     y_3 = y(4);

%     f_x0_y0 = f(1,1);
%     f_x1_y0 = f(1,2);
%     f_x2_y0 = f(1,3);
%     f_x3_y0 = f(1,4);
% 
%     f_x0_y1 = f(2,1);
%     f_x1_y1 = f(2,2);
%     f_x2_y1 = f(2,3);
%     f_x3_y1 = f(2,4);
%     
%     f_x0_y2 = f(3,1);
%     f_x1_y2 = f(3,2);
%     f_x2_y2 = f(3,3);
%     f_x3_y2 = f(3,4);
% 
%     f_x0_y3 = f(4,1);
%     f_x1_y3 = f(4,2);
%     f_x2_y3 = f(4,3);
%     f_x3_y3 = f(4,4);

    % L_y_0 = @(y) (y-y_1)/(y_0-y_1) * (y-y_2)/(y_0-y_2) * (y-y_3)/(y_0-y_3);
    % L_y_1 = @(y) (y-y_0)/(y_1-y_0) * (y-y_2)/(y_1-y_2) * (y-y_3)/(y_1-y_3);
    % L_y_2 = @(y) (y-y_0)/(y_2-y_0) * (y-y_1)/(y_2-y_1) * (y-y_3)/(y_2-y_3);
    % L_y_3 = @(y) (y-y_0)/(y_3-y_0) * (y-y_1)/(y_3-y_1) * (y-y_2)/(y_3-y_2);

    % L_y_0(y_0) = (y_0-y_1)/(y_0-y_1) * (y_0-y_2)/(y_0-y_2) * (y_0-y_3)/(y_0-y_3) = 1
    % L_y_1(y_0) = (y_0-y_0)/(y_1-y_0) * (y_0-y_2)/(y_1-y_2) * (y_0-y_3)/(y_1-y_3) = 0
    % L_y_2(y_0) = (y_0-y_0)/(y_2-y_0) * (y_0-y_1)/(y_2-y_1) * (y_0-y_3)/(y_2-y_3) = 0
    % L_y_3(y_0) = (y_0-y_0)/(y_3-y_0) * (y_0-y_1)/(y_3-y_1) * (y_0-y_2)/(y_3-y_2) = 0
    % in the same way
    % L_y_0(y_1) = 0
    % L_y_1(y_1) = 1
    % L_y_2(y_1) = 0
    % L_y_3(y_1) = 0

    % L_y_0(y_2) = 0
    % L_y_1(y_2) = 0
    % L_y_2(y_2) = 1
    % L_y_3(y_2) = 0

    % L_y_0(y_3) = 0
    % L_y_1(y_3) = 0
    % L_y_2(y_3) = 0
    % L_y_3(y_3) = 1


    % g_0 = @(y) L_y_0(y)*f_x0_y0 + L_y_1(y)*f_x0_y1 + L_y_2(y)*f_x0_y2 + L_y_3(y)*f_x0_y3;
    % g_1 = @(y) L_y_0(y)*f_x1_y0 + L_y_1(y)*f_x1_y1 + L_y_2(y)*f_x1_y2 + L_y_3(y)*f_x1_y3;
    % g_2 = @(y) L_y_0(y)*f_x2_y0 + L_y_1(y)*f_x2_y1 + L_y_2(y)*f_x2_y2 + L_y_3(y)*f_x2_y3;
    % g_3 = @(y) L_y_0(y)*f_x3_y0 + L_y_1(y)*f_x3_y1 + L_y_2(y)*f_x3_y2 + L_y_3(y)*f_x3_y3;

    % g_0(y_0) = L_y_0(y_0)*f_x0_y0 = f_x0_y0
    % g_0(y_1) = L_y_1(y_1)*f_x0_y1 = f_x0_y1
    % g_0(y_2) = f_x0_y2
    % g_0(y_3) = f_x0_y3

    % g_1(y_0) = f_x1_y0
    % g_1(y_1) = f_x1_y1
    % g_1(y_2) = f_x1_y2
    % g_1(y_3) = f_x1_y3

    % g_2(y_0) = f_x2_y0
    % g_2(y_1) = f_x2_y1
    % g_2(y_2) = f_x2_y2
    % g_2(y_3) = f_x2_y3

    % g_3(y_0) = f_x3_y0
    % g_3(y_1) = f_x3_y1
    % g_3(y_2) = f_x3_y2
    % g_3(y_3) = f_x3_y3

    % So the following expression is evaluated as
    % h_0 = (3*dy/8)*(g_0(y_0) + 3*g_0(y_1) + 3*g_0(y_2) + g_0(y_3));
    % h_1 = (3*dy/8)*(g_1(y_0) + 3*g_1(y_1) + 3*g_1(y_2) + g_1(y_3));
    % h_2 = (3*dy/8)*(g_2(y_0) + 3*g_2(y_1) + 3*g_2(y_2) + g_2(y_3));
    % h_3 = (3*dy/8)*(g_3(y_0) + 3*g_3(y_1) + 3*g_3(y_2) + g_3(y_3));

%     h_0 = (3*dy/8)*(f_x0_y0 + 3*f_x0_y1 + 3*f_x0_y2 + f_x0_y3);
%     h_1 = (3*dy/8)*(f_x1_y0 + 3*f_x1_y1 + 3*f_x1_y2 + f_x1_y3);
%     h_2 = (3*dy/8)*(f_x2_y0 + 3*f_x2_y1 + 3*f_x2_y2 + f_x2_y3);
%     h_3 = (3*dy/8)*(f_x3_y0 + 3*f_x3_y1 + 3*f_x3_y2 + f_x3_y3);

    h_0 = (3*dy/8)*(f(1,1) + 3*f(2,1) + 3*f(3,1) + f(4,1));
    h_1 = (3*dy/8)*(f(1,2) + 3*f(2,2) + 3*f(3,2) + f(4,2));
    h_2 = (3*dy/8)*(f(1,3) + 3*f(2,3) + 3*f(3,3) + f(4,3));
    h_3 = (3*dy/8)*(f(1,4) + 3*f(2,4) + 3*f(3,4) + f(4,4));


    % L_x_0 = @(x) (x-x_1)/(x_0-x_1) * (x-x_2)/(x_0-x_2) * (x-x_3)/(x_0-x_3);
    % L_x_1 = @(x) (x-x_0)/(x_1-x_0) * (x-x_2)/(x_1-x_2) * (x-x_3)/(x_1-x_3);
    % L_x_2 = @(x) (x-x_0)/(x_2-x_0) * (x-x_1)/(x_2-x_1) * (x-x_3)/(x_2-x_3);
    % L_x_3 = @(x) (x-x_0)/(x_3-x_0) * (x-x_1)/(x_3-x_1) * (x-x_2)/(x_3-x_2);
    % L_x_0(x_0) = 1, others = 0
    % L_x_1(x_1) = 1, others = 0
    % L_x_2(x_2) = 1, others = 0
    % L_x_3(x_3) = 1, others = 0

    % J = @(x) L_x_0(x)*h_0 + L_x_1(x)*h_1 + L_x_2(x)*h_2 + L_x_3(x)*h_3;
    % So
    % J(x_0) = h_0;
    % J(x_1) = h_1;
    % J(x_2) = h_2;
    % J(x_3) = h_3;

    I = (3*dx/8)*(h_0 + 3*h_1 + 3*h_2 + h_3);
end