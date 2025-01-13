function [B] = lscSmoothing(A,nWin)
    length = numel(A);
    B = zeros(1,length);
    doubleA = [A,A]; 
    for idx = 1:length
        winHead = idx;
        winRear = idx + nWin -1;
        win = doubleA(winHead:1:winRear);
        B(idx) = mean(win,"all");
    end
end

