function [field] = itpFieldGPU(lightCase, fieldName, timeStep, itpMesh)

    switch fieldName
    case 'u'
        x2d = gpuArray(lightCase.x2dU);
        y2d = gpuArray(lightCase.y2dU);
    case 'v'
        x2d = gpuArray(lightCase.x2dV);
        y2d = gpuArray(lightCase.y2dV);
    case 'tmp'
        x2d = gpuArray(lightCase.x2dS);
        y2d = gpuArray(lightCase.y2dS);
    case 'prs'
        x2d = gpuArray(lightCase.x2dS);
        y2d = gpuArray(lightCase.y2dS);
    case 'vor'
        x2d = gpuArray(lightCase.x2dS);
        y2d = gpuArray(lightCase.y2dS);
    otherwise
        disp([fieldName,'is not a correct field name!'])
        return
    end

    orgField = gpuArray(readField(lightCase, fieldName, timeStep));
    field = interp2(x2d, y2d, orgField, gpuArray(itpMesh.x2d), gpuArray(itpMesh.y2d),'cubic');

end