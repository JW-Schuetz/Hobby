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
N      = sym( 'n', [ 3, 1 ], 'real' );
N( 1 ) = sin( Phi );
N( 2 ) = 0;
N( 3 ) = cos( Phi );

% Erd-Rotationswinkel (2*pi/24h), alpha=0 -> Mittags d.h.Sonnenhöchststand
Alpha = sym( 'alpha', 'real' );
ca    = cos( Alpha );
sa    = sin( Alpha );

% Drehmatrix
DAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );

DAlpha( 1, 1 ) = N( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
DAlpha( 2, 1 ) = N( 1 ) * N( 2 ) * ( 1 - ca ) + N( 3 ) * sa;
DAlpha( 3, 1 ) = N( 1 ) * N( 3 ) * ( 1 - ca ) - N( 2 ) * sa;

DAlpha( 1, 2 ) = N( 1 ) * N( 2 ) * ( 1 - ca ) - N( 3 ) * sa;    % 2. Spalte
DAlpha( 2, 2 ) = N( 2 )^2        * ( 1 - ca ) + ca;
DAlpha( 3, 2 ) = N( 2 ) * N( 3 ) * ( 1 - ca ) + N( 1 ) * sa;

DAlpha( 1, 3 ) = N( 1 ) * N( 3 ) * ( 1 - ca ) + N( 2 ) * sa;    % 3. Spalte
DAlpha( 2, 3 ) = N( 2 ) * N( 3 ) * ( 1 - ca ) - N( 1 ) * sa;
DAlpha( 3, 3 ) = N( 3 )^2        * ( 1 - ca ) + ca;

DAlpha = simplify( DAlpha );    % evtl. Vereinfachung

% Fusspunkt des Stabes auf der Erdoberfläche und Stabende
P = sym( 'p', [ 3, 1 ], 'real' );
Q = ( 1 + L / RE ) * P;

% rotierte Punkte P und Q
PAlpha = DAlpha * P;
QAlpha = DAlpha * Q;

% Sonne
S = sym( 's', [ 3, 1 ], 'real' );
S( 1 ) = RS;
S( 2 ) = 0;
S( 3 ) = 0;

% Test: ist Matrix DAlpha auch wirklich orthogonal?
if( simplify( DAlpha' * DAlpha ) ~= eye( 3 ) )
    error( 'Diese Meldung sollte NIE angezeigt werden!' )
end

% Ausdruck PAlpha' * S bestimmen, collect: PAlphaS als Koeffizienten des Vektors P ausdrücken
PAlphaS = collect( PAlpha' * S, P );

% Hauptterm der zu lösende Gleichung
R = simplify( RE - PAlphaS / RE );
R = R / L;

save( 'sonnenkompass.mat', 'QAlpha', 'S', 'R' )
