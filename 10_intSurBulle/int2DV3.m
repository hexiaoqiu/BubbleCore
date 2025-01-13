function [I] = int2DV3(dx,dy,field)
    [n,m] = size(field);
    
    c = 4*ones(n,m);
    c(1,:) = 2;
    c(end,:) = 2;
    c(:,1) = 2;
    c(:,end) = 2;
    c(1,1) = 1;
    c(1,end) = 1;
    c(end,1) = 1;
    c(end,end) = 1;
    
    I = sum(0.25*dx*dy*(c.*field),'all');

end