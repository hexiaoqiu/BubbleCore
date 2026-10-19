% Author: Xiaoqiu HE
function [numCase, allCaseRawList] = getCaseRawDir(rawRoot)
%GETCASERAWDIR 返回根目录下合规的直接子目录数量和路径列cell。
% 实际搜索深度为一级；保持dir顺序，不进行子case数值排序。
% 只检查rawRoot以下子目录名，包含readme（忽略大小写）就排除整个分支。
% rawRoot自身及其上级名称不参与检查。

    % 显式排除普通文件、点目录和readme子目录。
    subdir = dir(rawRoot);
    names = {subdir.name};
    isDotDir = ismember(names, {'.', '..'});
    isReadMe = contains(names, 'readme', 'IgnoreCase', true);
    subdir = subdir([subdir.isdir] & ~isDotDir & ~isReadMe);

    % 保留相对输入对应相对输出的约定；空目录返回0和0×1 cell。
    numCase = numel(subdir);
    allCaseRawList = cell(numCase, 1);
    for i = 1:numCase
        allCaseRawList{i,1} = fullfile(rawRoot, subdir(i).name);
    end
end
