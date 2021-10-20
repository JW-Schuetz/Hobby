%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

% Symbol-Definitionen
Phi = sym( 'phi', 'real' ); % Komplementwinkel Erd-Rotationsachse zur Ekliptik
RS  = sym( 'rS', 'real' );  % Abstand Erde - Sonne
RE  = sym( 'rE', 'real' );  % Erdradius
L   = sym( 'l', 'real' );   % Stablänge

% Einheitsvektor Rotationsachse
N      = sym( 'n', [ 3, 1 ], 'real' );
N( 1 ) = sin( Phi );
N( 2 ) = 0;
N( 3 ) = cos( Phi );

% Erd-Rotationswinkel (2*pi/24h)
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

x = simplify( DAlpha' * DAlpha );

% Test: ist Matrix DAlpha auch wirklich orthogonal?
if( simplify( DAlpha' * DAlpha ) ~= eye( 3 ) )
    error( 'Das sollte nie passieren!' )
end

% Ausdruck PAlpha' * S bestimmen
res = simplify( PAlpha' * S );

% res als Koeffizienten des Vektors P ausdrücken
collect( res, P )

% dies liefert den Output:
% rS*(cos(alpha) - sin(phi)^2*(cos(alpha) - 1))*p1 + (-rS*cos(phi)*sin(alpha))*p2 + (-rS*cos(phi)*sin(phi)*(cos(alpha) - 1))*p3
