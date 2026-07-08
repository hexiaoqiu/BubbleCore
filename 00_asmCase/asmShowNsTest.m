function [ok] = asmShowNsTest(varargin)
%ASMSHOWNSTEST Plot fused NS test quantities from an ASM/DNS case.
%
% Usage:
%   asmShowNsTest(thisAsm)
%   asmShowNsTest(thisAsm, savePic)
%   asmShowNsTest(thisAsm, savePic, picPath)
%
% The nstest file has five columns:
%   1. time
%   2. NRJ   total kinetic energy
%   3. ENS   total enstrophy
%   4. TEN   total temperature
%   5. ANGM  angular momentum
%
% Robust behavior:
%   1. Empty nstest files are skipped.
%   2. Incomplete/corrupted rows are skipped.
%   3. Empty subcases are skipped during fusion.

    minArgs = 1;
    maxArgs = 3;
    narginchk(minArgs, maxArgs);

    if nargin == 3
        thisAsm = varargin{1};
        savePic = varargin{2};
        picPath = varargin{3};
    elseif nargin == 2
        thisAsm = varargin{1};
        savePic = varargin{2};
        picPath = '.';
    else
        thisAsm = varargin{1};
        savePic = false;
        picPath = '.';
    end

    onlySavedIdx = false;

    [asmTime, nsTest{1}, nsTest{2}, nsTest{3}, nsTest{4}] = ...
        asmFusionNsTest(thisAsm, onlySavedIdx);

    if isempty(asmTime)
        warning('asmShowNsTest:NoValidData', ...
            'No valid nstest data were found. Nothing is plotted.');
        ok = false;
        return;
    end

    LineWidth = 2;
    FontSize = 30;
    legendFontSize = 20;
    labelFontSize = 35;
    titleFontSize = 18;
    pOsItiON = [0, 20, 1024, 768];

    fig_1 = figure();
    set(fig_1, 'position', pOsItiON);

    for i = 1:4
        x = asmTime;
        if i == 4
            y = abs(nsTest{i});
        else
            y = nsTest{i};
        end

        semilogy(x, y, 'LineWidth', LineWidth);
        hold on;
    end

    legendText{1} = '$E_{k}$';
    legendText{2} = '$E_{\omega}$';
    legendText{3} = '$T$';
    legendText{4} = '$J$';

    hold off;

    set(gca, 'FontSize', FontSize);

    legend(legendText, ...
        'interpreter', 'latex', ...
        'FontSize', legendFontSize, ...
        'location', 'best', ...
        'NumColumns', 1, ...
        'Orientation', 'horizontal');
    legend('boxoff');

    ylabel('Total Quantities', ...
        'interpreter', 'latex', ...
        'FontSize', labelFontSize);

    ylim([0.01, 100]);

    xlabel('$t$', ...
        'interpreter', 'latex', ...
        'FontSize', labelFontSize);

    figTitle = asmGetPlotTitle(thisAsm);
    title(figTitle, ...
        'interpreter', 'latex', ...
        'FontSize', titleFontSize);

    grid on;
    drawnow;

    if savePic == true
        if exist(picPath, 'dir') ~= 7
            mkdir(picPath);
        end

        caseName = asmGetSaveName(thisAsm);
        suffix = char(datetime("now", "Format", "uuuu-MM-dd-hh-mm"));
        fileName = ['NsTest_', caseName, '_', suffix];
        fileNameFull = [fileName, '.png'];

        saveas(gcf, fullfile(picPath, fileNameFull));
    end

    ok = true;

end