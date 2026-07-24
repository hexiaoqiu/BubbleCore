function [coordinate] = dnsGet2DCoordinateVec(x2dDroit,x2dGauche,y2dBas,y2dHaut,N)
    coordinate.x2dDroit = x2dDroit;
    coordinate.x2dGauche = x2dGauche;
    coordinate.y2dBas = y2dBas;
    coordinate.y2dHaut = y2dHaut;
    coordinate.h1 = (x2dDroit - x2dGauche) / N;
    coordinate.h2 = (y2dHaut - y2dBas) / N;
    coordinate.x2dS = x2dGauche + coordinate.h1/2 : ...
        coordinate.h1 : ...
        x2dDroit - coordinate.h1/2;
    coordinate.y2dS = (y2dBas + coordinate.h2/2 : ...
        coordinate.h2 : ...
        y2dHaut-coordinate.h2/2)';
    coordinate.x2dU = x2dGauche : coordinate.h1 : x2dDroit;
    coordinate.y2dU = coordinate.y2dS;
    coordinate.x2dV = coordinate.x2dS;
    coordinate.y2dV = (y2dBas : coordinate.h2 : y2dHaut)';
end