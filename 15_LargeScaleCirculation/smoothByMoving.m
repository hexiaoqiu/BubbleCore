function [B] = smoothByMoving(A,nWin)
    length = numel(A);
    sizeWin = nWin*2+1;
    for idx = 1:length
        winHead = idx - nWin;
        winRear = idx + nWin;
        win = winHead:1:winRear;
        for idxWin = 1:sizeWin
            if win(idxWin) <= 0
                win(idxWin) = win(idxWin) + length;
            elseif win(idxWin) > length
                win(idxWin) = win(idxWin) - length;
            end
        end
        B(idx) = mean(A(win),"all");
    end
end

