function [linesX,linesZ] = lscLagranTraceCube(x,z,LSC)
    topValue = z(end);
    bottomValue = z(1);
    dx = x(2) - x(1);
    length = x(end);
    decalage = dx;
    
    if LSC.head + decalage < length
        head = LSC.head + decalage;
    else
        head = LSC.head + decalage - length;
    end
    
    if LSC.rear - decalage > 0
        rear = LSC.rear - decalage;
    else
        rear = LSC.rear - decalage + length;
    end

    headLineZ = linspace(-100,100,100)';
    headLineX = ones(100,1)*head;
    rearLineZ = linspace(-100,100,100)';
    rearLineX = ones(100,1)*rear;
    if head < rear
        topLineX = linspace(head,rear,100);
        topLineZ = ones(100,1)*topValue;
        bottomLineX = topLineX;
        bottomLineZ = zeros(100,1)*bottomValue;
    else
        topLineX = linspace(head,x(end),100);
        topLineX2 = linspace(x(1),rear,100);
        topLineZ = ones(100,1)*topValue;
        topLineZ2 = ones(100,1)*topValue;
        bottomLineX = topLineX;
        bottomLineX2 = topLineX2;
        bottomLineZ = zeros(100,1)*bottomValue;
        bottomLineZ2 = zeros(100,1)*bottomValue;
    end
    
    
    if head < rear
        linesX = cell(4,1);
        linesX{1} = headLineX;
        linesX{2} = rearLineX;
        linesX{3} = topLineX;
        linesX{4} = bottomLineX;
    
        linesZ = cell(4,1);
        linesZ{1} = headLineZ;
        linesZ{2} = rearLineZ;
        linesZ{3} = topLineZ;
        linesZ{4} = bottomLineZ;
    else
        linesX = cell(4,1);
        linesX{1} = headLineX;
        linesX{2} = rearLineX;
        linesX{3} = topLineX;
        linesX{4} = bottomLineX;
        linesX{5} = topLineX2;
        linesX{6} = bottomLineX2;
    
        linesZ = cell(4,1);
        linesZ{1} = headLineZ;
        linesZ{2} = rearLineZ;
        linesZ{3} = topLineZ;
        linesZ{4} = bottomLineZ;
        linesZ{5} = topLineZ2;
        linesZ{6} = bottomLineZ2;
    end
end

