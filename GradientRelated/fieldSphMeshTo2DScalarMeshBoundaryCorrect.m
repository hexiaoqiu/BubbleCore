% 2023/03/23
% 求半球面上场量的三维笛卡尔空间梯度都使用getGrad函数，它的位置在
% BubbleProcessLib\GradientRelated\
% 计算半球面上场量的三维笛卡尔空间梯度需要这个场（温度T,速度U）的网格是原始DNS数据的标量网格。
% 这个网格在二维投影坐标系中为结构化且正交的。
% 对于一些已经后处理后的平均场，如平均温度场<T>、平均速度场<U>，这样的物理场的网格是球坐标下的结构化正交网格，
% 如果需要求这些平均场的网格，则需要将其重新投射到原始DNS数据的标量网格中，因而需要开发一个函数来完成此任务。
% 这个函数的名字为
% 	fieldSphMeshTo2DScalarMesh
% 输入为球坐标系下的平均场，是一个一维列向量：球坐标系下的平均场不依赖phi经度坐标，所以每一行对应一个纬度。
% 注意：球坐标系下的纬度是0度处于球顶，90度（或pi/2）处于赤道
% 这个函数也放在一下目录中
% 	BubbleProcessLib\GradientRelated\

% 2023/03/24
% 继续编写函数
% 	[field2D] = fieldSphMeshTo2DScalarMesh(fieldSph,M,type)
% 函数功能描述：
% 输入： 
% 	1.fieldSph 一个N行*1列的列向量，每一行对应一个纬度值（theta）
% 输出：
% 	1.field2D: 一个M行*M列的矩阵，对应2维投影向量上的一个M*M的正交结构化网格上每个节点的场值
% 	2.M: 正整数，输出矩阵的尺寸，物理含义为DNS在2D投影坐标系中x和y个方向上网格节点数
% 	3.type: 输出的类型，存在两个类型：tmp和vel
% 		3.1 tmp：温度类型，在2D网格中但处于肥皂泡外的点的值均为1
% 		3.2 vel: 速度类型，在2D网格中但处于肥皂泡外的点的值均为0
% 算法Ver0：
% 	step.0. 生成一个M*M的空矩阵 
% 	step.1. if type == tmp 
% 			outValue = 1
% 		  if type == vel
% 			outValue = 0
% 	step.2. 生成M*M的矩阵的网格的位置向量：找到每一个元素的二维投影空间的坐标
% 	step.3.  for M*M的矩阵的每一个元素
% 				if 在肥皂泡外
% 					赋值为outValue
% 				if 在肥皂泡内
% 					计算元素在球坐标中的坐标theta和phi值
% 					根据theta值对fieldSph插值得到元素值
% 算法Ver1：
% 解说：算法Ver0中的判断太多了，而且所有的元素挨个遍历，串行执行，太慢了。
% 改用空间换时间，将M*M矩阵的空间坐标网格生成，并求出对应的球坐标系下的空间坐标网格
% 再利用matlab内置函数插值，求得每个元素的值
% 最后利用逻辑下标，对肥皂泡外的元素赋值为outValue
% 	step.0. 生成一个M*M的空矩阵 
% 	step.1. if type == tmp 
% 			outValue = 1
% 		  if type == vel
% 			outValue = 0
% 	step.2. 生成M*M的矩阵的网格的坐标向量：找到每一个元素的二维投影空间的坐标
% 	step.3. 生成M*M矩阵在球坐标系下的坐标矩阵，theta，phi坐标矩阵都是M*M的矩阵
% 	step.4. 利用interp1插值获得field2D的值，使用theta坐标矩阵，如果纬度坐标落在[0,pi/2]之外，就直接
% 		    赋值为outValue

% 2023/03/27
% 修改1：把一个问题想通了：某一个场量在肥皂泡之外的值，应该与肥皂泡赤道的值相同，
% 这样能最大程度的减少求的导数没有奇异性。
% 所以去掉type这个输入量
% 修改2： 在外面的赋值并没有实际的数学和物理的合理性，会使得在赤道处的导数产生奇异性。
% 解决方案：将外面的值均设置为NaN，并且将球面坐标系的网格不断加密，使最近的边界值趋近于赤道处的值

function [field2D] = fieldSphMeshTo2DScalarMeshBoundaryCorrect(fieldSphVec,M)

    outValue = fieldSphVec(end);
    x2dVec = linspace(-1.02,1.02,M);
    y2dVec = linspace(-1.02,1.02,M);
    [x2dMatrix,y2dMatrix] = meshgrid(x2dVec,y2dVec);
    [x3dMatrix, y3dMatrix, z3dMatrix] = pos2Dto3D(x2dMatrix,y2dMatrix);
    [~, thetaMatrix] = pos3DtoSph(x3dMatrix, y3dMatrix, z3dMatrix);


    numTheta = numel(fieldSphVec);
    thetaPositionVec = linspace(0,pi/2,numTheta)';
    [field2D] = interp1(thetaPositionVec,fieldSphVec,thetaMatrix,'cubic',outValue);    
    
end