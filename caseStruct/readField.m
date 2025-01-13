function [field] = readField(lightCase, fieldName, timeStep)
    switch fieldName
    case 'u'
        rootFileName = lightCase.rootFileNameU;
        n_x = lightCase.n1+1;
        n_y = lightCase.n2;
    case 'v'
        rootFileName = lightCase.rootFileNameV;
        n_x = lightCase.n1;
        n_y = lightCase.n2+1;
    case 'tmp'
        rootFileName = lightCase.rootFileNameTmp;
        n_x = lightCase.n1;
        n_y = lightCase.n2;
    case 'prs'
        rootFileName = lightCase.rootFileNamePrs;
        n_x = lightCase.n1;
        n_y = lightCase.n2;
    case 'vor'
        rootFileName = lightCase.rootFileNameVor;
        n_x = lightCase.n1;
        n_y = lightCase.n2;
    otherwise
        disp([fieldName,' is not a correct field name!'])
        return
    end

    fileName = [rootFileName,num2str(timeStep,'%d'),'.bin'];
    filePath = fullfile(lightCase.path,'org',fileName);
    file = fopen(filePath,'r');

    field = fread(file, [n_y,n_x], 'double');
    fclose(file);

end