function asmShowNumIter(varargin)
    minArgs = 1;
    maxArgs = 3;
    narginchk(minArgs,maxArgs);
    if nargin == 3
        ns = varargin{1};
        idxSubCaseStart = varargin{2};
        idxSubCaseEnd = varargin{3};
    elseif nargin == 1
        ns = varargin{1};
        idxSubCaseStart = 1;
        idxSubCaseEnd = ns.numSubCase;
    else
        disp('Wrong Input!')
        return
    end
    [time,numIter] = asmGetNumIter(ns,idxSubCaseStart,idxSubCaseEnd);

    % size of fig
    pOsItiON = [0,0,1024,768];
    
    % Font size
    LineWidth = 2.5;
    labelFontSize = 25;
    titleFontSize = 30;
    
    fig_1 = figure();
    set(fig_1,'position',pOsItiON);
    semilogy(time, numIter,'x','LineWidth',LineWidth)
    % axis
    ylabel('No. Iteration','interpreter','latex','FontSize',labelFontSize)
    ylim([1,5000]);
    xlabel('$t$','interpreter','latex','FontSize',labelFontSize)
    xlim([time(1),time(end)]);

    title(asmGetPlotTitle(ns),'interpreter','latex','FontSize',titleFontSize);

    grid on;

end