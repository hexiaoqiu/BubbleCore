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

function [result] = cpyParameters(asmCase,result,idx)
        
    % the physical non-dimensional parameters for all configurations
    result(idx).Ra = asmCase.Ra;
    result(idx).Pr = asmCase.Pr;
    result(idx).invRo = asmCase.invRo;
    result(idx).St = asmCase.St;
    result(idx).Ff = asmCase.Ff;
    result(idx).Delta = asmCase.Delta;
    % the numerical coefficients for all configurations
    result(idx).x2dGauche = asmCase.x2dGauche;
    result(idx).x2dDroit = asmCase.x2dDroit;
    result(idx).y2dBas = asmCase.y2dBas;
    result(idx).y2dHaut = asmCase.y2dHaut;
    result(idx).n1 = asmCase.n1;
    result(idx).n2 = asmCase.n2;
    result(idx).maxN = asmCase.maxN;
    result(idx).dt = asmCase.dt;
    result(idx).dtSave = asmCase.dtSave;
    result(idx).dnsBeginTime = asmCase.dnsBeginTime;
    result(idx).dnsStopTime = asmCase.dnsStopTime;
    result(idx).totalN = asmCase.totalN;
    % the physical parameters for bubble+
    if isfield(asmCase, 'r_c') == true
            result(idx).r_c = asmCase.r_c;
            result(idx).theta_c = asmCase.theta_c;
            result(idx).theta_c_deg = asmCase.theta_c_deg;
            result(idx).H = asmCase.H ;
            result(idx).W = asmCase.W ;
            result(idx).realRa = asmCase.realRa;   
    end
    
    

end