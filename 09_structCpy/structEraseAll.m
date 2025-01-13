% *************************************************************************
% 函数名：structEraseAll()
% 功能简介：将结构体的所有字段都设置为空
% Xiaoqiu HE Institut de Mathematique de Bordeaux 03/15/2024
% *************************************************************************
% 输入：
% 1. result : 结构体
% 输出：
% 1. result : 存放后处理结果的容器结构体,在实际使用中，是结构体数组的某一个元素
% *************************************************************************

function [result] = structEraseAll(result)
    % get all components of a structure
    keys = fieldnames(result); 

    for i = 1:length(keys)
        cur_key = keys{i};
        result.(cur_key) = [];
    end

end

