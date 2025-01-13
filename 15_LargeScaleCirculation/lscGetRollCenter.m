function [centerX,centerZ] = lscGetRollCenter(LSC)
    centerZ = 0.5;
    length = 1;
    if LSC.head < LSC.rear
        centerX = 0.5*(LSC.head + LSC.rear);
    else
        centerX = 0.5*(LSC.head + length + LSC.rear);
        if centerX > length
            centerX = centerX - length;
        end
    end
end

