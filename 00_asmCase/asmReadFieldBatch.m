function [dns, batch] = asmReadFieldBatch(dns, readTime0, readTime1, maxNumStepsPerBatch, fieldList)
%ASMREADFIELDBATCH Read a block of DNS snapshots into memory.
%   The low-level DNS reader always reads tmp, u2d, v2d, and prs together.
%   fieldList only controls which fields are kept in the returned batch.

    if nargin < 5 || isempty(fieldList)
        fieldList = {'tmp', 'u2d', 'v2d', 'prs'};
    end
    keepTmp = any(strcmp(fieldList, 'tmp'));
    keepU2d = any(strcmp(fieldList, 'u2d'));
    keepV2d = any(strcmp(fieldList, 'v2d'));
    keepPrs = any(strcmp(fieldList, 'prs'));

    if keepTmp
        batch.tmpOrg = cell(maxNumStepsPerBatch, 1);
    end
    if keepU2d
        batch.u2dOrg = cell(maxNumStepsPerBatch, 1);
    end
    if keepV2d
        batch.v2dOrg = cell(maxNumStepsPerBatch, 1);
    end
    if keepPrs
        batch.prsOrg = cell(maxNumStepsPerBatch, 1);
    end

    batch.time = zeros(maxNumStepsPerBatch, 1);
    batch.n1 = zeros(maxNumStepsPerBatch, 1);
    batch.n2 = zeros(maxNumStepsPerBatch, 1);
    batch.subCaseIdx = zeros(maxNumStepsPerBatch, 1);
    batch.fieldList = fieldList;

    counterStep = 0;
    while counterStep < maxNumStepsPerBatch
        counterStep = counterStep + 1;

        if dns.readCounter == 0
            [dns, tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmInitRead(dns, readTime0);
        else
            [dns, tmpOrg, u2dOrg, v2dOrg, prsOrg] = asmReadOneStepForward(dns);
        end

        if keepTmp
            batch.tmpOrg{counterStep} = tmpOrg;
        end
        if keepU2d
            batch.u2dOrg{counterStep} = u2dOrg;
        end
        if keepV2d
            batch.v2dOrg{counterStep} = v2dOrg;
        end
        if keepPrs
            batch.prsOrg{counterStep} = prsOrg;
        end

        batch.time(counterStep) = dns.lastReadTime;
        batch.subCaseIdx(counterStep) = dns.readNowSubCaseIdx;
        batch.n1(counterStep) = dns.n1(dns.readNowSubCaseIdx);
        batch.n2(counterStep) = dns.n2(dns.readNowSubCaseIdx);

        disp([ ...
            'Loading: A = ', num2str(dns.A, '%g'), ...
            ' Ra = ', num2str(dns.realRa, '%3.2e'), ...
            ' time = ', num2str(dns.lastReadTime, '%g'), ...
            ' batchIdx = ', num2str(counterStep, '%d'), ...
            ' in ', dns.subCaseDir{dns.readNowSubCaseIdx} ...
            ])

        if dns.nextReadTime > readTime1
            disp('Reach the end of the case!')
            break
        end
    end
    
    % 在最后一次读取时，batch的容量不一定达到预设值
    batch.numSteps = counterStep;
    batch.time = batch.time(1:counterStep);
    batch.n1 = batch.n1(1:counterStep);
    batch.n2 = batch.n2(1:counterStep);
    batch.subCaseIdx = batch.subCaseIdx(1:counterStep);

    if keepTmp
        batch.tmpOrg = batch.tmpOrg(1:counterStep);
    end
    if keepU2d
        batch.u2dOrg = batch.u2dOrg(1:counterStep);
    end
    if keepV2d
        batch.v2dOrg = batch.v2dOrg(1:counterStep);
    end
    if keepPrs
        batch.prsOrg = batch.prsOrg(1:counterStep);
    end
end
