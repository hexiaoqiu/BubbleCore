% Author: Xiaoqiu HE
% Purpose: 
% this function select all the folder which contains raw data of one case
% then read them and restore them into binary form
% Input:
%       rawPath: the path of the folder in which all second level folders contains
%                one case's raw data
%       storePath: the path to store binary form of raw data
function transAllInsideDir(rawPath, storePath)

    [numCase, allCaseList] = getCaseRawDir(rawPath);
    caseDirList = cell(numCase,1);
    disp(['There are ', num2str(numCase,'%d'), ' cases!']);
    for index = 1:numCase
        disp(['Reading ', num2str(index,'%d'), ' / ', num2str(numCase,'%d')]);
        caseDirList{index} = readOneCase(allCaseList{index}, storePath);
    end

end