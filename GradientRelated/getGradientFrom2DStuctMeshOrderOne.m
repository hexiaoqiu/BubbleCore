% 2023/03/25
% 之前计算二维球面上三维笛卡尔坐标系下梯度的函数
% 	getGrad(bubble,field2D)
% 存在许多不方便性，事实上，当利用二维投影坐标系下正交结构化网格的数据计算三维笛卡尔坐标系下的梯度时，这一网格不一定是要和DNS原始数据的网格保持一致。
% 其实，只需要需要指明二维投影坐标系下结构化正交网格的dx、dy即可。
% 因而创造一个新的计算梯度的函数
% 	getGradientFrom2DStuctMesh(xVec,yVec,field2D)
% 输入：
% 	1. xVec ： x方向的坐标向量
% 	2. yVec :  y方向的坐标向量
% 	3. field2D : 2D空间中的场量，其每个元素的坐标由 xVec yVec确定
% 其余部分算法与getGrad相同

% 2023/03/27
% 对肥皂泡外面的导数全部按照0来处理

% 2023/04/07
% 采用一阶导数
function gradient3D = getGradientFrom2DStuctMeshOrderOne(xVec,yVec,field2D)
    
    [x2d,y2d] = meshgrid(xVec,yVec);
    h1 = xVec(2) - xVec(1);
    h2 = yVec(2) - yVec(1);

    gradX2d = zeros( size(field2D) );
    gradY2d = zeros( size(field2D) );

    gradX2d(:,2:end-1) = (field2D(:,2:end-1) - field2D(:,1:end-2)) ./ (h1);
    gradY2d(2:end-1,:) = (field2D(2:end-1,:) - field2D(1:end-2,:)) ./ (h2);

    gradient3D.gradX3d = (-x2d.^2 + y2d.^2 + 1)./2.*gradX2d - x2d.*y2d.*gradY2d;
    gradient3D.gradY3d = - x2d.*y2d.*gradX2d + (x2d.^2 - y2d.^2 + 1)./2.*gradY2d;
    gradient3D.gradZ3d = - x2d.*gradX2d - y2d.*gradY2d;
    
end