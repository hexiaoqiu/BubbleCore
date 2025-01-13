function [good] = asmOpen(asmCase)
    numFileIDNaN = 0;
    for idxSubCase = 1:asmCase.numSubCase
        if asmCase.fileID(idxSubCase) == -1
            numFileIDNaN = numFileIDNaN + 1;
        end
    end
    
    if numFileIDNaN == asmCase.numSubCase
        for idxSubCase = 1:asmCase.numSubCase
            nssaveDir = fullfile(asmCase.subCaseDir(idxSubCase),'nssave.bin');
            asmCase.fileID(idxSubCase) = fopen(nssaveDir, 'r','n');
        end
        for idxSubCase = 1:asmCase.numSubCase
            if asmCase.fileID(idxSubCase) >= 3
                good = true;
            else
                good = false;
                disp(['The subCase in ',asmCase.subCaseDir(idxSubCase),' cannot be openned! Check it!'])
                return
            end
        end
    else
        disp('some nssave.bin is opened, some is not! This is wrong!')
        disp('Now close it all!')
        asmClose(asmCase);
        good = false;
    end
end

