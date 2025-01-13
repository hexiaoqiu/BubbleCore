x = rand(10000,10000);
y = rand(10000,10000);
tic
[a,b,c]=cPosSphTo3D(x,y);
toc

tic
[a1,b1,c1]=posSphto3D(x,y);
toc

e1 = max(abs(a-a1),[],'all');
