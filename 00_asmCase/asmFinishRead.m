function [asmCase] = asmFinishRead(asmCase)
    if asmCase.readNowSubCaseIdx ~= -1
        disp(['Now closing the nssave.bin of subCase:',asmCase.subCaseDir{asmCase.readNowSubCaseIdx}])
        disp(['Sub Case Idx = ',num2str(asmCase.readNowSubCaseIdx,'%g')])
        disp(['Last Read Step''s time: ',num2str(asmCase.lastReadTime,'%g')])
        disp(['Total read times: ',num2str(asmCase.readCounter,'%g')])
        fclose(asmCase.readNowFileID);
        asmCase.lastReadTime = -1;
        asmCase.nextReadTime = -1;
        asmCase.readNowSubCaseIdx = -1;
        asmCase.readNowFileID = -1;
        asmCase.readCounter = 0;
    else
        disp('Case is already well closed!')
    end
end

