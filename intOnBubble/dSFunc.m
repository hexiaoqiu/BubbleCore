function dS = dSFunc(x,y)
    a = 0.5*1./sqrt(1-x.^2-y.^2);
    b = -2*x;
    c = -2*y;
    parZParX = b.*a;
    parZParY = c.*a;
    dS = sqrt( 1 + parZParX.^2 + parZParY.^2 );
end