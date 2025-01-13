function [x3d,y3d,z3d] = posVec1DSph2Car(phi,theta)
% POSVECSPH2CAR 将球坐标转换为三维笛卡尔坐标
%   输入必须为列向量，每一行对应一个空间点

x3d = sin(theta) .* cos(phi);
y3d = sin(theta) .* sin(phi);
z3d = cos(theta);


end

