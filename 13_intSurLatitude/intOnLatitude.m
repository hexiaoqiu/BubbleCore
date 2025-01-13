function [A] = intOnLatitude(y)
    resN = numel(y);
    dPhi = pi*2/(resN-1);
    midValue = zeros(1,resN-1);
    midValue(1:end) = 0.5*(y(1:end-1)+y(2:end));
    A = sum(dPhi*midValue,"all");
end

