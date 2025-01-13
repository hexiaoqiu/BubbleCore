function [field] = itpField(lightCase, fieldName, timeStep, itpMesh)

    switch fieldName
    case 'u'
        x2d = lightCase.x2dU;
        y2d = lightCase.y2dU;
    case 'v'
        x2d = lightCase.x2dV;
        y2d = lightCase.y2dV;
    case 'tmp'
        x2d = lightCase.x2dS;
        y2d = lightCase.y2dS;
    case 'prs'
        x2d = lightCase.x2dS;
        y2d = lightCase.y2dS;
    case 'vor'
        x2d = lightCase.x2dS;
        y2d = lightCase.y2dS;
    otherwise
        disp([fieldName,' is not a correct field name!'])
        return
    end

    orgField = readField(lightCase, fieldName, timeStep);
    field = interp2(x2d, y2d, orgField, itpMesh.x2d, itpMesh.y2d,'linear');

end