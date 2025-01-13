function [cLSC,aLSC] = lscLocate(peak,bottom)
    numLSC = numel(peak);
    cLSC = struct(...
        'head',0, ...
        'rear',0, ...
        'headIdx',0, ...
        'rearIdx',0, ...
        'tmpCut',0, ...
        'tmpScale',0, ...
        'uPhiCut',0, ...
        'uPhiScale',0, ...
        'vThetaCut',0, ...
        'vThetaScale',0 ...
        );
    aLSC = cLSC;

    if peak(1).idxPosition < bottom(1).idxPosition
        startWithCLSC = true;
    else
        startWithCLSC = false;
    end
    if startWithCLSC == true
        for idxLSC = 1:numLSC
            cLSC(idxLSC).head = peak(idxLSC).position;
            cLSC(idxLSC).rear = bottom(idxLSC).position;
            cLSC(idxLSC).headIdx = peak(idxLSC).idxPosition;
            cLSC(idxLSC).rearIdx = bottom(idxLSC).idxPosition;
            % cLSC(idxLSC).direction = 'c';
        end
        for idxLSC = 1:numLSC-1
            aLSC(idxLSC).head = bottom(idxLSC).position;
            aLSC(idxLSC).rear = peak(idxLSC+1).position;
            aLSC(idxLSC).headIdx = bottom(idxLSC).idxPosition;
            aLSC(idxLSC).rearIdx = peak(idxLSC+1).idxPosition;
            % aLSC(idxLSC).direction = 'a';
        end
        aLSC(numLSC).head = bottom(numLSC).position;
        aLSC(numLSC).rear = peak(1).position;
        aLSC(numLSC).headIdx = bottom(numLSC).idxPosition ;
        aLSC(numLSC).rearIdx = peak(1).idxPosition;
        % aLSC(numLSC).direction = 'a';
    else
        for idxLSC = 1:numLSC
            aLSC(idxLSC).head = bottom(idxLSC).position;
            aLSC(idxLSC).rear = peak(idxLSC).position;
            aLSC(idxLSC).headIdx = bottom(idxLSC).idxPosition;
            aLSC(idxLSC).rearIdx = peak(idxLSC).idxPosition;
            % aLSC(idxLSC).direction = 'a';
        end
        for idxLSC = 1:numLSC-1
            cLSC(idxLSC).head = peak(idxLSC).position;
            cLSC(idxLSC).rear = bottom(idxLSC+1).position;
            cLSC(idxLSC).headIdx = peak(idxLSC).idxPosition ;
            cLSC(idxLSC).rearIdx = bottom(idxLSC+1).idxPosition;
            % cLSC(idxLSC).direction = 'c';
        end
        cLSC(numLSC).head = peak(numLSC).position;
        cLSC(numLSC).rear = bottom(1).position;
        cLSC(numLSC).headIdx = peak(numLSC).idxPosition ;
        cLSC(numLSC).rearIdx = bottom(1).idxPosition;
        % cLSC(numLSC).direction = 'c';
    end
end

