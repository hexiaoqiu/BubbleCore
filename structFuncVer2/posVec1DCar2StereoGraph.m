function [x2d, y2d] = posVec1DCar2StereoGraph(x3d,y3d,z3d)
%POSVEC1DCAR2STEREO 一列空间点的笛卡尔坐标转换为球极投影坐标
%   输入必须是列向量


x2d = x3d ./ (1 + z3d);
y2d = y3d ./ (1 + z3d);


end