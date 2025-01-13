
for i = 1:10
    x = rand(10000,10000);
    y = rand(10000,10000);
    z = rand(10000,10000);
    tic
    [a,b]=cPos3Dto2D(x,y,z);
    toc
end

clear

x = rand(10000,10000);
y = rand(10000,10000);
z = rand(10000,10000);
tic
[a1,b1]=pos3Dto2D(x,y,z);
toc

e1 = max(abs(a-a1),[],'all');
