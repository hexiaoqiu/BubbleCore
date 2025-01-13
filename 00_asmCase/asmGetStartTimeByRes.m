function [startTime] = asmGetStartTimeByRes(asm,res)
%asmGetStartTimeByRes 通过分辨率选取读取的起始时间
%   09/01/2024 IMB Bordeaux France

    for idxSubCase = 1:asm.numSubCase
        if asm.n1(idxSubCase) >= res
            startTime = asm.startTime(idxSubCase);
            return
        end
    end
    
    disp('Do not find the sub case fullfil the condition of resolution!')
    startTime = -1;
end

