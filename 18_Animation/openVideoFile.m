function videoFile = openVideoFile(dns, storePath, frameRate,tag)
    suffix = char(datetime("now", "Format", "uuuu-MM-dd"));
    caseName = asmGetSaveName(dns);
    fileName = fullfile(storePath, [tag,'_', caseName, '_', suffix]);

    % MATLAB's MPEG-4 writer is not consistently available on Linux.
    % Use Motion JPEG AVI there, and keep MPEG-4 on Windows/macOS.
    if isunix && ~ismac
        videoProfile = 'Motion JPEG AVI';
    else
        videoProfile = 'MPEG-4';
    end

    videoFile = VideoWriter(fileName, videoProfile);
    videoFile.FrameRate = frameRate;
    open(videoFile);
end