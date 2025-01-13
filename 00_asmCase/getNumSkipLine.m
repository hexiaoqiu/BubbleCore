function [numSkipLine] = getNumSkipLine(asmCase,localTimeStepIdx)
    idxSelectedSubCase = asmCase.readNowSubCaseIdx;
    numTimeStepToSkip = localTimeStepIdx - 1;
    n1 = asmCase.n1(idxSelectedSubCase);
    n2 = asmCase.n2(idxSelectedSubCase);

    % calculate the quntity of numbers in one timeStep
    % tmpOrg        u2dOrg(staggered)       v2dOrg(staggered)       prsOrg
    % n1*n2         n2*(n1+1)               (n2+1)*n1               n1*n2;
    numFloatInOneTimeStep = n1 * n2 + (n1 + 1) * n2 + n1 * (n2 + 1) + n1 * n2;
    numLineOneStepData = ceil(numFloatInOneTimeStep / 5) + 1;

    if numTimeStepToSkip == 0
        % nssave.dat 文件头5行是header，不是数据块，一打开文件读取焦点在第一行，
        % 然后跳5行到第6行，开始读取焦点到达第一个数据块
        numSkipLine = 5;
    else
        % calculate the numbers of lines to skip if there n step to skip
        %     n steps    +  the n+1 step to read 
        % header   data           header   
        %   5     numLine           5    
        %       OneStepData
        numSkipLine = numTimeStepToSkip*(numLineOneStepData+5) + 5;
    end
end

