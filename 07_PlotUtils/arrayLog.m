function [array] = arrayLog(N1,N2)

numOrder = N2 - N1 + 1;
order = N1:1:N2;
k = 0;
array = zeros(1,(numOrder-1)*9);
for i = 1:numOrder
    if order(i) ~= N2
        startTick = 10^(order(i));
        arraySub = (1:1:9)*startTick;
        k = k + 1;
        array(1+(k-1)*9:9+(k-1)*9) = arraySub;
    else
        startTick = 10^(order(i));
        array = [array,startTick];
    end
end

end

