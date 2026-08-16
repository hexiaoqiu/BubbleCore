function figPosition = parseOutputResolution(outputResolution)
    if numel(outputResolution) ~= 2
        error('showTmpAnimation4Views:BadOutputResolution', ...
            'outputResolution must be a two-element vector: [width, height].')
    end

    figWidth = outputResolution(1);
    figHeight = outputResolution(2);
    if figWidth <= 0 || figHeight <= 0
        error('showTmpAnimation4Views:BadOutputResolution', ...
            'outputResolution values must be positive.')
    end

    figPosition = [0, 0, figWidth, figHeight];
end