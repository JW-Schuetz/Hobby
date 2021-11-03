%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

% Symbol-Definitionen
Phi = sym( 'phi', 'real' );      % Komplementwinkel Erd-Rotationsachse zur Ekliptik
RS  = sym( 'rS', 'real' );       % Abstand Erde - Sonne
RE  = sym( 'rE', 'real' );       % Erdradius
L   = sym( 'l', 'real' );        % Stablänge

% Einheitsvektor Rotationsachse
E      = sym( 'n', [ 3, 1 ], 'real' );
E( 1 ) = sin( Phi );
E( 2 ) = 0;
E( 3 ) = cos( Phi );

% Erd-Rotationswinkel (2*pi/24h), alpha=0 -> Mittags d.h.Sonnenhöchststand
Alpha = sym( 'alpha', 'real' );
ca    = cos( Alpha );
sa    = sin( Alpha );

% Drehmatrix
DAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );

DAlpha( 1, 1 ) = E( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
DAlpha( 2, 1 ) = E( 1 ) * E( 2 ) * ( 1 - ca ) + E( 3 ) * sa;
DAlpha( 3, 1 ) = E( 1 ) * E( 3 ) * ( 1 - ca ) - E( 2 ) * sa;

DAlpha( 1, 2 ) = E( 1 ) * E( 2 ) * ( 1 - ca ) - E( 3 ) * sa;    % 2. Spalte
DAlpha( 2, 2 ) = E( 2 )^2        * ( 1 - ca ) + ca;
DAlpha( 3, 2 ) = E( 2 ) * E( 3 ) * ( 1 - ca ) + E( 1 ) * sa;

DAlpha( 1, 3 ) = E( 1 ) * E( 3 ) * ( 1 - ca ) + E( 2 ) * sa;    % 3. Spalte
DAlpha( 2, 3 ) = E( 2 ) * E( 3 ) * ( 1 - ca ) - E( 1 ) * sa;
DAlpha( 3, 3 ) = E( 3 )^2        * ( 1 - ca ) + ca;

DAlpha = simplify( DAlpha );    % evtl. Vereinfachung

% Fusspunkt des Stabes auf der Erdoberfläche und Stabende
P = sym( 'p', [ 3, 1 ], 'real' );
Q = ( 1 + L / RE ) * P;

% Sonne
S = sym( 's', [ 3, 1 ], 'real' );
S( 1 ) = RS;
S( 2 ) = 0;
S( 3 ) = 0;

% rotierte Punkte P, Q und S
PAlpha = DAlpha * P;
QAlpha = DAlpha * Q;
SAlpha = DAlpha * S;

% Test: ist Matrix DAlpha auch wirklich orthogonal?
if( simplify( DAlpha' * DAlpha ) ~= eye( 3 ) )
    error( 'Diese Meldung sollte NIE angezeigt werden!' )
end

% Ausdruck PAlpha' * S bestimmen, collect: PAlphaS als Koeffizienten des Vektors P ausdrücken
PAlphaS = collect( PAlpha' * S, P );

% Ausdruck P' * SAlpha bestimmen, collect: PSAlpha als Koeffizienten des Vektors P ausdrücken
PSAlpha = collect( P' * SAlpha, P );

% Hauptterm der zu lösende Gleichung (Erde wird gedreht)
R1 = simplify( RE - PAlphaS / RE );
R1 = R1 / L;

% Hauptterm der zu lösende Gleichung (Sonne wird gedreht)
R2 = simplify( RE - PSAlpha / RE );
R2 = R2 / L;

save( 'sonnenkompass.mat', 'Q', 'QAlpha', 'S', 'SAlpha', 'R1', 'R2' )
