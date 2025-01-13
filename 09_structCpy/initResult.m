% *************************************************************************
% 函数名：initResult()
% 功能简介：创建一个初始的结构体用于存储后处理的结果，这个结构体不仅要包含后处理的
% 结果，还要包含算例的全部基本信息，这样才能对后处理结果进行区分
% Xiaoqiu HE Institut de Mathematique de Bordeaux 11/10/2023
% *************************************************************************
% 输入：
% 1. 无 : 
% 输出：
% 1. result : 存放后处理结果的容器结构体
% *************************************************************************

function [result] = initResult()
    
    result = struct([]);
    
    result(1).Ra = 1;
    result(1).Pr = 1;
    result(1).Ro = 1;
    result(1).St = 1;
    result(1).Ff = 1;
    result(1).Delta = 1;
    result(1).x2dGauche = 1;
    result(1).x2dDroit = 1;
    result(1).y2dBas = 1;
    result(1).y2dHaut = 1;
    result(1).n1 = 1;
    result(1).n2 = 1;
    result(1).totalN = 1;
    result(1).maxN = 1;
    result(1).dt = 1;
    result(1).dtSave = 1;

end