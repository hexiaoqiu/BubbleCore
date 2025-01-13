function [oneline] = asmOneLineInfor(asmCase)
    text_1 = ['Ra=',num2str(asmCase.Ra,'%1.0E'),' realRa=',num2str(asmCase.realRa,'%3.2e'),' A=',num2str(asmCase.A,'%3.2f')];
    if asmCase.readNowSubCaseIdx == -1
        text_2 = 'Not Reading';
    else
        text_2 = ['subCase=',num2str(asmCase.readNowSubCaseIdx,'%d')];
    end
    oneline = append(text_1,' ',text_2);
end

