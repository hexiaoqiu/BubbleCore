function [width] = lscGetRollWidth(roll)
    if roll.head < roll.rear
        width = 2*pi*(roll.rear - roll.head);
    else
        width = 2*pi*(roll.rear + 1 - roll.head);
    end
end

