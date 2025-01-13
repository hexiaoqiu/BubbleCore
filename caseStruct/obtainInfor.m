function [msg] = obtainInfor(lightCase)
    msg = { ...,
    'The case is of:'; ..., 
    ['Ra=',num2str(lightCase.Ra,'%2.1e'),' ','Pr=', num2str(lightCase.Pr,'%d'),' Delta=', num2str(lightCase.Delta), ' ', '1/Ro=',num2str(lightCase.Ro,'%3.2f')]; ...,
    ['r_c=', num2str(lightCase.r_c),' St=',num2str(lightCase.St,'%3.2f'),' ','Ff=', num2str(lightCase.Ff,'%3.2f')]; ..., 
    ['n1=',num2str(lightCase.n1,'%3.2f'),' ','n2=', num2str(lightCase.n2,'%3.2f'),' maxN=',num2str(lightCase.maxN,'%3.2f')]; ...,
    ['In the dir: ', lightCase.path] ...,
    };
end