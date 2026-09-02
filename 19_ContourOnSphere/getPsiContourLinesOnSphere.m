function lineData = getPsiContourLinesOnSphere( ...
    phiVec, thetaVec, psi, radius, numLevels)
%GETPSICONTOURLINESONSPHERE Compute streamfunction contour-line geometry.
%   LINEDATA = GETPSICONTOURLINESONSPHERE(PHIVEC, THETAVEC, PSI, RADIUS,
%   NUMLEVELS) returns one structure per contour segment. Each structure
%   contains xData, yData, and zData vectors on a sphere slightly outside
%   RADIUS to avoid z-fighting with a surface plotted at RADIUS.

    if nargin < 4 || isempty(radius)
        radius = 1;
    end
    if nargin < 5 || isempty(numLevels)
        numLevels = 30;
    end

    validateattributes(radius, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'}, mfilename, 'radius', 4);
    validateattributes(numLevels, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'integer', 'positive'}, ...
        mfilename, 'numLevels', 5);

    thetaVec = thetaVec(:);
    phiVec = phiVec(:).';
    [numTheta, numPhi] = size(psi);

    if numel(thetaVec) ~= numTheta
        error('getPsiContourLinesOnSphere:ThetaSizeMismatch', ...
            'Length of thetaVec must match the number of rows of psi.');
    end
    if numel(phiVec) ~= numPhi
        error('getPsiContourLinesOnSphere:PhiSizeMismatch', ...
            'Length of phiVec must match the number of columns of psi.');
    end
    if any(diff(thetaVec) <= 0)
        error('getPsiContourLinesOnSphere:InvalidTheta', ...
            'thetaVec must be strictly increasing.');
    end
    if any(diff(phiVec) <= 0)
        error('getPsiContourLinesOnSphere:InvalidPhi', ...
            'phiVec must be strictly increasing.');
    end

    tolerancePhi = 1e-12 * 2*pi;
    hasDuplicateEndpoint = ...
        abs((phiVec(end) - phiVec(1)) - 2*pi) < tolerancePhi;
    if hasDuplicateEndpoint
        phiWork = phiVec;
        psiWork = psi;
        psiWork(:, end) = psiWork(:, 1);
    else
        phiWork = [phiVec, phiVec(1) + 2*pi];
        psiWork = [psi, psi(:, 1)];
    end

    psiMin = min(psiWork(:), [], 'omitnan');
    psiMax = max(psiWork(:), [], 'omitnan');
    lineData = struct('xData', {}, 'yData', {}, 'zData', {});
    if isempty(psiMin) || isempty(psiMax) || ...
            ~isfinite(psiMin) || ~isfinite(psiMax) || psiMin == psiMax
        return
    end

    levels = linspace(psiMin, psiMax, numLevels + 2);
    levels = levels(2:end-1);
    [phiContour, thetaContour, psiContour] = ...
        buildPoleRegularizedContourGrid(phiWork, thetaVec, psiWork);
    contourMatrix = contourc( ...
        phiContour, thetaContour, psiContour, levels);

    idxColumn = 1;
    numLines = 0;
    while idxColumn < size(contourMatrix, 2)
        numPoints = contourMatrix(2, idxColumn);
        numLines = numLines + 1;
        idxColumn = idxColumn + numPoints + 1;
    end

    lineData = repmat( ...
        struct('xData', [], 'yData', [], 'zData', []), numLines, 1);
    lineRadius = radius * 1.003;
    idxColumn = 1;
    idxLine = 0;
    while idxColumn < size(contourMatrix, 2)
        numPoints = contourMatrix(2, idxColumn);
        idxPoint = idxColumn + (1:numPoints);
        phiLine = contourMatrix(1, idxPoint);
        thetaLine = contourMatrix(2, idxPoint);

        idxLine = idxLine + 1;
        lineData(idxLine).xData = ...
            lineRadius * sin(thetaLine) .* cos(phiLine);
        lineData(idxLine).yData = ...
            lineRadius * sin(thetaLine) .* sin(phiLine);
        lineData(idxLine).zData = lineRadius * cos(thetaLine);
        idxColumn = idxColumn + numPoints + 1;
    end
end

function [phiContour, thetaContour, psiContour] = ...
    buildPoleRegularizedContourGrid(phiWork, thetaVec, psiWork)

    thetaVec = thetaVec(:);
    phiWork = phiWork(:).';
    [numTheta, numPhiInput] = size(psiWork);
    if numel(thetaVec) ~= numTheta || numel(phiWork) ~= numPhiInput
        error('getPsiContourLinesOnSphere:InternalSizeMismatch', ...
            'The periodic contour grid has incompatible dimensions.');
    end

    tolerancePhi = 1e-12 * 2*pi;
    hasDuplicateEndpoint = ...
        abs((phiWork(end) - phiWork(1)) - 2*pi) < tolerancePhi;
    if hasDuplicateEndpoint
        phiNoDuplicate = phiWork(1:end-1);
        psiNoDuplicate = psiWork(:, 1:end-1);
    else
        phiNoDuplicate = phiWork;
        psiNoDuplicate = psiWork;
    end

    numPhi = numel(phiNoDuplicate);
    thetaExtended = thetaVec;
    psiExtended = psiNoDuplicate;
    poleTolerance = 1e-12;
    numGhostRows = min(3, numTheta - 1);

    if abs(thetaVec(1)) < poleTolerance && numGhostRows >= 1
        thetaGhostNorth = zeros(numGhostRows, 1);
        psiGhostNorth = zeros(numGhostRows, numPhi);
        for idxGhost = 1:numGhostRows
            idxSource = numGhostRows - idxGhost + 2;
            thetaGhostNorth(idxGhost) = -thetaVec(idxSource);
            psiGhostNorth(idxGhost, :) = shiftScalarRowByPi( ...
                psiNoDuplicate(idxSource, :), phiNoDuplicate);
        end
        thetaExtended = [thetaGhostNorth; thetaExtended];
        psiExtended = [psiGhostNorth; psiExtended];
    end

    if abs(thetaVec(end) - pi) < poleTolerance && numGhostRows >= 1
        thetaGhostSouth = zeros(numGhostRows, 1);
        psiGhostSouth = zeros(numGhostRows, numPhi);
        for idxGhost = 1:numGhostRows
            idxSource = numTheta - idxGhost;
            thetaGhostSouth(idxGhost) = 2*pi - thetaVec(idxSource);
            psiGhostSouth(idxGhost, :) = shiftScalarRowByPi( ...
                psiNoDuplicate(idxSource, :), phiNoDuplicate);
        end
        thetaExtended = [thetaExtended; thetaGhostSouth];
        psiExtended = [psiExtended; psiGhostSouth];
    end

    phiContour = [phiNoDuplicate, phiNoDuplicate(1) + 2*pi];
    thetaContour = thetaExtended;
    psiContour = [psiExtended, psiExtended(:, 1)];
end

function shiftedRow = shiftScalarRowByPi(row, phiNoDuplicate)
    row = row(:).';
    phiNoDuplicate = phiNoDuplicate(:).';
    if numel(row) ~= numel(phiNoDuplicate)
        error('getPsiContourLinesOnSphere:InternalRowSizeMismatch', ...
            'The scalar row and longitude vector must have equal lengths.');
    end

    phi0 = phiNoDuplicate(1);
    phiExtended = [phiNoDuplicate, phiNoDuplicate(1) + 2*pi];
    rowExtended = [row, row(1)];
    phiQuery = mod(phiNoDuplicate + pi - phi0, 2*pi) + phi0;
    shiftedRow = interp1(phiExtended, rowExtended, phiQuery, 'linear');
end
