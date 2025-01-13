function [startFromZero] = ifStartFromZero(bubble)
    [~,NRJ,~,TEN,~] = obtainNsTest(bubble);
    startFromZero = ( round(NRJ(1),2)==0 )&&( round(TEN(1),2)==0 ) ;
end