function [] = dnsRestartBinScaleFromLatestSolu(N, coef, flowSnapshot, outputPath)


    % mesh vector orthogonal in 2D system
    [coordinateOrg] = ...
        dnsGet2DCoordinateVec(coef.x2dDroit, coef.x2dGauche, ...
        coef.y2dBas, coef.y2dHaut,coef.n1);

    [coordinate] = ...
        dnsGet2DCoordinateVec(coef.x2dDroit, coef.x2dGauche, ...
        coef.y2dBas, coef.y2dHaut, N);
    
    % 当输出分辨率高于原始分辨率时，第一个和最后一个网格点可能落在原始网格之外，因此
    % 需要外插值
    % 温度原始网格外都是1（物理支撑：恒温边界条件）
    tmp = interp2(coordinateOrg.x2dS, coordinateOrg.y2dS, ...
        flowSnapshot.tmpOrg, ...
        coordinate.x2dS, ...
        coordinate.y2dS,'spline',1);
    % 速度原始网格外都是0（物理支撑：无滑移边界条件）
    u2d = interp2(coordinateOrg.x2dU, coordinateOrg.y2dU, ...
        flowSnapshot.u2dOrg, ...
        coordinate.x2dU, coordinate.y2dU,'spline',0);
    v2d = interp2(coordinateOrg.x2dV,coordinateOrg.y2dV, ...
        flowSnapshot.v2dOrg, ...
        coordinate.x2dV, coordinate.y2dV,'spline',0);
    % 压强最复杂，难以找到合理的恒定外插值，无物理条件支撑
    % 因此必须使用外插算法，spline可以自动使用样条函数外插
    prs = interp2(coordinateOrg.x2dS, coordinateOrg.y2dS, ...
        flowSnapshot.prsOrg, ...
        coordinate.x2dS, coordinate.y2dS, 'spline');


    writeRestartSolutionBin(coef, outputPath, N, N, tmp, u2d, v2d, prs);

end

function [] = writeRestartSolutionBin(coef, outputPath, n1, n2, tmp, u2d, v2d, prs)
%WRITERESTARTSOLUTIONBIN Write restart fields with Fortran index order.

    fileDir = fullfile(outputPath,'restartSolution.bin');
    fid = fopen(fileDir,'w');
    % 写入文件头1
    fwrite(fid, coef.x2dGauche, 'double');
    fwrite(fid, coef.x2dDroit, 'double');
    fwrite(fid, coef.y2dBas, 'double');
    fwrite(fid, coef.y2dHaut, 'double');
    % 写入文件头2
    fwrite(fid, n1,'int');
    fwrite(fid, n2,'int');
    % 在matlab中，我默认第一个索引对应y方向，第二个索引对应x方向
    % 在fortran中，默认第一个索引对应x方向，第二个索引对应y方向
    % 所以需要交换两个索引的顺序！
    tmp = tmp';
    u2d = u2d';
    v2d = v2d';
    prs = prs';

    % 写入流场
    fwrite(fid,tmp,'double');
    fwrite(fid,u2d,'double');
    fwrite(fid,v2d,'double');
    fwrite(fid,prs,'double');
    fclose(fid);

end
