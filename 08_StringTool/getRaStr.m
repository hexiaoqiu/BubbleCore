function [RaStr] = getRaStr(Ra)
    exp = floor(log10(Ra));
    expStr = num2str(exp,'%d');
    real = Ra/(10^(exp));
    realStr = num2str(real,'%g');
    RaStr = [realStr,'\times 10^{',expStr,'}'];
end

