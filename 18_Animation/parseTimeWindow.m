function [animationStartTime, animationEndTime] = parseTimeWindow(dns, timeWindow)
    if numel(timeWindow) ~= 2
        error('showTmpAnimation4Views:BadTimeWindow', ...
            'timeWindow must be a two-element vector: [startTime, endTime].')
    end

    animationStartTime = timeWindow(1);
    animationEndTime = timeWindow(2);

    if animationStartTime > animationEndTime
        error('showTmpAnimation4Views:BadTimeWindow', ...
            'timeWindow(1) must be smaller than or equal to timeWindow(2).')
    end
    if animationStartTime < dns.dnsBeginTime || animationEndTime > dns.dnsStopTime
        error('showTmpAnimation4Views:TimeOutOfRange', ...
            'The requested animation time window is outside the DNS time range.')
    end
end