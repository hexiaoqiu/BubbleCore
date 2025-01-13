function [TitleStr] = asmGetPlotTitle(asmCase)
    
    exp = floor(log10(asmCase.realRa));
    expStr = num2str(exp,'%d');
    real = asmCase.realRa/(10^(exp));
    realStr = num2str(real,'%3.2f');
    RaStr = ['$Ra=',realStr,'\times 10^{',expStr,'}$'];
    
    % PrStr = ['$Pr=',num2str(asmCase.Pr,'%g'),'$'];
    
    % WStr = ['$W=',num2str(asmCase.W,'%3.2f'),'$'];

    AStr = ['$A=',num2str(asmCase.A,'%3.2f'),'$'];

    % RcStr = ['$Rc=',num2str(asmCase.r_c,'%3.2f'),'$'];
    
    % TitleStr = [RaStr,' ',PrStr,' ',WStr,' ',AStr,' ',RcStr];
    
    TitleStr = [RaStr,' ',AStr];
end

