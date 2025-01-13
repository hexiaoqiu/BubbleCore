function [cLSC,aLSC] = lscReLocateByCenter(x,centerCLSC,centerALSC)
    
    length = x(end);
    numCenter = numel(centerCLSC);
    numCenterAll = numCenter * 2;
    centerAll(numCenterAll) = struct( ...
        'x',0, ...
        'direction','c');

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
    
    idxCenter = 0;
    idxCenterAll = 0;
    while idxCenterAll < numCenterAll
        idxCenter = idxCenter + 1;
        if centerCLSC(idxCenter).x > centerALSC(idxCenter).x
            idxCenterAll = idxCenterAll + 1;
            centerAll(idxCenterAll).x = centerALSC(idxCenter).x;
            centerAll(idxCenterAll).direction = 'a';
            idxCenterAll = idxCenterAll + 1;
            centerAll(idxCenterAll).x = centerCLSC(idxCenter).x;
            centerAll(idxCenterAll).direction = 'c';
        else
            idxCenterAll = idxCenterAll + 1;
            centerAll(idxCenterAll).x = centerCLSC(idxCenter).x;
            centerAll(idxCenterAll).direction = 'c';
            idxCenterAll = idxCenterAll + 1;
            centerAll(idxCenterAll).x = centerALSC(idxCenter).x;
            centerAll(idxCenterAll).direction = 'a';
        end
    end
    
    counterCLSC = 0;
    counterALSC = 0;
    if strcmp(centerAll(1).direction,'c')
        counterCLSC = counterCLSC + 1;
        cLSC(counterCLSC).head = 0.5*(length + centerAll(1).x + centerAll(end).x);
        if cLSC(counterCLSC).head > length
            cLSC(counterCLSC).head = cLSC(counterCLSC).head - length;
        end
        cLSC(counterCLSC).rear = 0.5*(centerAll(1).x + centerAll(2).x);
        [cLSC(counterCLSC).head, cLSC(counterCLSC).headIdx] = findClosest(x,cLSC(counterCLSC).head);
        [cLSC(counterCLSC).rear, cLSC(counterCLSC).rearIdx] = findClosest(x,cLSC(counterCLSC).rear);
    else
        counterALSC = counterALSC + 1;
        aLSC(counterALSC).head = 0.5*(length + centerAll(1).x + centerAll(end).x);
        if aLSC(counterALSC).head > length
            aLSC(counterALSC).head = aLSC(counterALSC).head - length;
        end
        aLSC(counterALSC).rear = 0.5*(centerAll(1).x + centerAll(2).x);
        [aLSC(counterALSC).head, aLSC(counterALSC).headIdx] = findClosest(x,aLSC(counterALSC).head);
        [aLSC(counterALSC).rear, aLSC(counterALSC).rearIdx] = findClosest(x,aLSC(counterALSC).rear);
    end

    for idxCenterAll = 2:numCenterAll-1
        if strcmp(centerAll(idxCenterAll).direction,'c')
            counterCLSC = counterCLSC + 1;
            cLSC(counterCLSC).rear = 0.5*(centerAll(idxCenterAll).x + centerAll(idxCenterAll+1).x);
            cLSC(counterCLSC).head = 0.5*(centerAll(idxCenterAll).x + centerAll(idxCenterAll-1).x);
            [cLSC(counterCLSC).head, cLSC(counterCLSC).headIdx] = findClosest(x,cLSC(counterCLSC).head);
            [cLSC(counterCLSC).rear, cLSC(counterCLSC).rearIdx] = findClosest(x,cLSC(counterCLSC).rear);
        else
            counterALSC = counterALSC + 1;
            aLSC(counterALSC).rear = 0.5*(centerAll(idxCenterAll).x + centerAll(idxCenterAll+1).x);
            aLSC(counterALSC).head = 0.5*(centerAll(idxCenterAll).x + centerAll(idxCenterAll-1).x);
            [aLSC(counterALSC).head, aLSC(counterALSC).headIdx] = findClosest(x,aLSC(counterALSC).head);
            [aLSC(counterALSC).rear, aLSC(counterALSC).rearIdx] = findClosest(x,aLSC(counterALSC).rear);
        end
    end

    if strcmp(centerAll(end).direction,'c')
        counterCLSC = counterCLSC + 1;
        cLSC(counterCLSC).head = 0.5*(centerAll(end).x + centerAll(end-1).x);
        cLSC(counterCLSC).rear = 0.5*(length + centerAll(1).x + centerAll(end).x);
        if cLSC(counterCLSC).rear > length
            cLSC(counterCLSC).rear = cLSC(counterCLSC).rear - length;
        end
        
        [cLSC(counterCLSC).head, cLSC(counterCLSC).headIdx] = findClosest(x,cLSC(counterCLSC).head);
        [cLSC(counterCLSC).rear, cLSC(counterCLSC).rearIdx] = findClosest(x,cLSC(counterCLSC).rear);
    else
        counterALSC = counterALSC + 1;
        aLSC(counterALSC).head = 0.5*(centerAll(end-1).x + centerAll(end).x);
        aLSC(counterALSC).rear = 0.5*(length + centerAll(1).x + centerAll(end).x);
        if aLSC(counterALSC).rear > length
            aLSC(counterALSC).rear = aLSC(counterALSC).rear - length;
        end
        
        [aLSC(counterALSC).head, aLSC(counterALSC).headIdx] = findClosest(x,aLSC(counterALSC).head);
        [aLSC(counterALSC).rear, aLSC(counterALSC).rearIdx] = findClosest(x,aLSC(counterALSC).rear);
    end
    
end

function [head, headIdx] = findClosest(x,headTheory)
    diff = abs(x - headTheory);
    [~,headIdx] = min(diff,[],'all');
    head = x(headIdx);
end