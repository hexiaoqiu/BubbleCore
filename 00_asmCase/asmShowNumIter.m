function asmShowNumIter(varargin)
    minArgs = 1;
    maxArgs = 3;
    narginchk(minArgs,maxArgs);
    if nargin == 3
        ns = varargin{1};
        idxSubCaseStart = varargin{2};
        idxSubCaseEnd = varargin{3};
        savePic = false;
    elseif nargin == 1
        ns = varargin{1};
        idxSubCaseStart = 1;
        idxSubCaseEnd = ns.numSubCase;
        savePic = false;
    elseif nargin == 2
        ns = varargin{1};
        picPath = varargin{2};
        idxSubCaseStart = 1;
        idxSubCaseEnd = ns.numSubCase;
        savePic = true;
    else
        disp('Wrong Input!')
        return
    end

    maxIterNum = 2000;
    [time,numIter] = asmGetNumIter(ns,idxSubCaseStart,idxSubCaseEnd);
    redline = ones(size(time))*maxIterNum;

    % size of fig
    pOsItiON = [0,0,1024,768];
    
    % Font size
    LineWidth = 2.5;
    labelFontSize = 25;
    titleFontSize = 30;
    
    fig_1 = figure();
    set(fig_1,'position',pOsItiON);
    semilogy(time, redline,'-r','LineWidth',LineWidth)
    hold on
    semilogy(time, numIter,'.k','LineWidth',LineWidth)
    % axis
    ylabel('No. Iteration','interpreter','latex','FontSize',labelFontSize)
    ylim([1,5000]);
    xlabel('$t$','interpreter','latex','FontSize',labelFontSize)
    xlim([time(1),time(end)]);

    title(asmGetPlotTitle(ns),'interpreter','latex','FontSize',titleFontSize);

    grid on;

    % save config
    if savePic == true
        caseName = asmGetSaveName(ns);
        suffix = char(datetime("now","Format","uuuu-MM-dd"));
        fileName = ['IterNum_',caseName,'_',suffix];
        fileNameFull = [fileName,'.png'];
        saveas(gcf,fullfile(picPath,fileNameFull));
    end

end