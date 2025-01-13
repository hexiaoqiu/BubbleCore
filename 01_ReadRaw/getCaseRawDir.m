% Author: Xiaoqiu HE
% Purpose: Find the level 2 folders which is supposed to contain raw data.

function [numCase, allCaseRawList] = getCaseRawDir(rawRoot)
    subdir = dir(rawRoot);
    k = 0;
    for i = 1:length(subdir)
        if( isequal(subdir(i).name, '.') || ...,
            isequal(subdir(i).name, '..') || ...,
            ~subdir(i).isdir )
            continue;
        else
            k = k+1;
            subPathLevel0{k,1} = fullfile(rawRoot,subdir(i).name);
        end
    end

%     m = 0;
%     for i = 1:k
%         subdir2 = dir(subPathLevel0{i});
%         for j = 1:length(subdir2)
%             if( isequal(subdir2(j).name, '.') || ...,
%                 isequal(subdir2(j).name, '..') || ...,
%                 ~subdir2(j).isdir )
%                 continue;
%             else
%                 m = m+1;
%                 subPathLevel1{m,1} = fullfile(subPathLevel0{i},subdir2(j).name);
%             end
%         end
%     end
    numCase = k;
    allCaseRawList = subPathLevel0;
end
