function [timeStable] = asmGetStableStateTime(asmCase)
    [asmTime,~,~,asmTEN,~] = asmFusionNsTest(asmCase);
    
    [timeStable] = getNsArrayStableTime(asmTime, asmTEN);
%     [timeStableENS] = getNsArrayStableTime(asmTime, asmENS);
%     [timeStableNRJ] = getNsArrayStableTime(asmTime, asmNRJ);
%     [timeStableANGM] = getNsArrayStableTime(asmTime, asmANGM);
    
%     timeStable = max([timeStableTEN,timeStableENS,timeStableNRJ,timeStableANGM],[],"all");

end

function [timeStable] = getNsArrayStableTime(asmTime, NSArray)

    searchStart = 10;
    searchStep = 100;
    dt = asmTime(2) - asmTime(1);
    idxSearch= searchStart/dt ;
    keepSearch = true;
    while keepSearch == true
        meanHead = mean(NSArray(1:idxSearch),"all");
        meanRear = mean(NSArray(idxSearch:end),"all");
        diff = abs(meanHead - meanRear)/meanRear;
        if  diff <= 0.16
            keepSearch = false;
        else
            keepSearch = true;
            idxSearch = idxSearch + searchStep;
        end
    end
    disp(['T_search = ',num2str(asmTime(idxSearch),'%g'),' diff = ',num2str(diff,'%g')])
    timeStable = asmTime(idxSearch);

end

% function [timeStable] = getNsArrayStableTime(asmTime, NSArray)
% 
%     filterTimeWindow = 10;
%     dt = asmTime(2) - asmTime(1);
%     filterIdxNum = round(filterTimeWindow / dt);
%     idxWindow = 1:1:numel(asmTime)-filterIdxNum+1;
%     counter = 0;
% %     maxSigmaCriterion = 0;
%     avgMeanWindow = 0;
%     for idxStep = idxWindow(end):-1:idxWindow(1)
%         window = NSArray(idxStep:1:idxStep+filterIdxNum-1);
%         meanWindow = mean(window,"all");
%         avgMeanWindow = avgMeanWindow + meanWindow;
% %         sigmaWindow = sqrt( (window - meanWindow).^2);
% %         maxSigmaCriterion = maxSigmaCriterion + max(sigmaWindow,[],"all");
%         counter = counter + 1;
%         if counter == 9*filterIdxNum
%             break
%         end
%     end
%     avgMeanWindow = avgMeanWindow/counter;
% %     maxSigmaCriterion = maxSigmaCriterion/counter;
% %     maxSigmaCriterion = maxSigmaCriterion*1.1;
%     for idxStep = idxWindow(end):-1:idxWindow(1)
%         window = NSArray(idxStep:1:idxStep+filterIdxNum-1);
%         meanWindow = mean(window,"all");
% %         sigmaWindow = sqrt( (window - meanWindow).^2);
% %         maxSigma = max(sigmaWindow,[],"all");
%         if (abs(meanWindow - avgMeanWindow)/avgMeanWindow > 0.01)
%             idxStable = idxStep;
%             break
%         end
%     end
%     timeStable = asmTime(idxStable);
% 
% end

