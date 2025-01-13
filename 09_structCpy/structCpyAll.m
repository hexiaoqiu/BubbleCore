% *************************************************************************
% 函数名：structCpyAll()
% 功能简介：将算例结构体的参数拷贝到存储后处理结果的结构体中
% Xiaoqiu HE Institut de Mathematique de Bordeaux 03/15/2024
% *************************************************************************
% 输入：
% 1. bubble : bubble
% 输出：
% 1. result : 存放后处理结果的容器结构体,在实际使用中，是结构体数组的某一个元素
% *************************************************************************

function [result] = structCpyAll(bubble,result)
    
    keys = fieldnames(bubble); % 获得bubble的所有字段
    for i = 1:length(keys)
        cur_key = keys{i};
        if isfield(result, cur_key) == false
            result.(cur_key) = [];
        end
    end
    for i = 1:length(keys)
        cur_key = keys{i};
        % 2017年后支持: structName.(dynamicExpression)
        % dynamicExpression 是一个变量或表达式，返回字符串标量（结构体字段）
        % 类似于 getfield() 和 setfield() 功能
        result.(cur_key) = bubble.(cur_key);
    end

end