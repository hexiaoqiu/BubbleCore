function [closestTimeStep, idxClosest] = getClosestTimeStep(dns, time0)
%GETCLOSESTTIMESTEP 找到最近的保存时间步
%   给定一个任意时间 time0，返回 dns.time 中距离 time0 最近的保存时刻及其全局索引

    timeDistance = abs(dns.time - time0);

    [~, idxClosest] = min(timeDistance);

    closestTimeStep = dns.time(idxClosest);

end