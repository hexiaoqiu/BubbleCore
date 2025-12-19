% trackLagranLSC
% 这个函数通过比较上一个时刻的Lagrangian Roll和当前时刻Euler Roll的中心点的距离，
% 来确定此时刻的Euler Roll所对应的Lagrangian Roll。
% 这一版本的函数实现传入了x也就是横向坐标的位置向量！
% 需要这个向量的原因在于要知道空间周期的长度：
%   如果是无量纲的坐标，周期长度就是1
%   如果是有量纲的坐标，周期长度就是2*pi
% 但是这一算法不好，应该统一为使用无量纲的空间坐标，使算法更加清晰
function [lagranLSC] = trackLagranLSC(x,lagranLSCOld,LSC)
    lagranLSC = lagranLSCOld;
    numLagrangLSC = numel(lagranLSCOld);
    idxLagranLSCToLSC = zeros(numLagrangLSC,1);
    length = x(end);%周期的长度

    for i = 1:numLagrangLSC
        [center] = getIntervalCenter(length,lagranLSCOld(i));
        numCLSC = numel(LSC);
        distance = zeros(numCLSC,1);
        for idxEulerLSC = 1:numCLSC
            centerEuler = getIntervalCenter(length,LSC(idxEulerLSC));
            distance(idxEulerLSC) = getDistanceShortest(center, centerEuler, length);
        end
        [~,idxCorrespond] = min(distance,[],"all",'linear');
        lagranLSC(i) = LSC(idxCorrespond);
        idxLagranLSCToLSC(i) = idxCorrespond;
    end

    idxCheck = unique(idxLagranLSCToLSC);
    if numel(idxCheck) < numel(idxLagranLSCToLSC)
        disp('Wrong track! Two or more Euler is correspond to one Lagran')
    end
end

function [center] = getIntervalCenter(length,LSC)
    if LSC.headIdx < LSC.rearIdx
        center = 0.5*(LSC.head + LSC.rear);
    else
        center = 0.5*(LSC.head + length + LSC.rear);
        if center > length
            center = center - length;
        end
    end
end

function [shortest] = getDistanceShortest(center1, center2, length)
    if center1 < center2
        distance1 = center2 - center1;
        distance2 = center1 + length - center2;
        shortest = min(distance1, distance2);
    else
        distance1 = center1 - center2;
        distance2 = center2 + length - center1;
        shortest = min(distance1, distance2);
    end
end
