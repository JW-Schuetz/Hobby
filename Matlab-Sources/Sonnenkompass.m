%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

% Symbol-Definitionen
Phi = sym( 'Phi' ); % Winkel Erd-Rotationsachse zur Ekliptik
RS  = sym( 'RS' );  % Abstand Erde - Sonne
RE  = sym( 'RE' );  % Erdradius
L   = sym( 'L' );   % Stablänge

% Einheitsvektor Rotationsachse
n      = sym( 'n', [ 3, 1 ] );
n( 1 ) = sin( Phi );
n( 2 ) = 0;
n( 3 ) = cos( Phi );

% Erd-Rotationswinkel (2*pi/24h)
Alpha = sym( 'Alpha' );
ca    = cos( Alpha );
sa    = sin( Alpha );

% Drehmatrix
DAlpha = sym( 'DAlpha', [ 3, 3 ] );

DAlpha( 1, 1 ) = n( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
DAlpha( 2, 1 ) = n( 1 ) * n( 2 ) * ( 1 - ca ) + n( 3 ) * sa;
DAlpha( 3, 1 ) = n( 1 ) * n( 3 ) * ( 1 - ca ) - n( 2 ) * sa;

DAlpha( 1, 2 ) = n( 1 ) * n( 2 ) * ( 1 - ca ) - n( 3 ) * sa;    % 2. Spalte
DAlpha( 2, 2 ) = n( 2 )^2        * ( 1 - ca ) + ca;
DAlpha( 3, 2 ) = n( 2 ) * n( 3 ) * ( 1 - ca ) + n( 1 ) * sa;

DAlpha( 1, 3 ) = n( 1 ) * n( 3 ) * ( 1 - ca ) + n( 2 ) * sa;    % 3. Spalte
DAlpha( 2, 3 ) = n( 2 ) * n( 3 ) * ( 1 - ca ) - n( 1 ) * sa;
DAlpha( 3, 3 ) = n( 3 )^2        * ( 1 - ca ) + ca;

DAlpha = simplify( DAlpha );    % Vereinfachung möglich?

% Fusspunkt des Stabes auf der Erdoberfläche und Stabende
P = sym( 'p', [ 3, 1 ] );
Q = ( 1 + L / RE ) * P;

% rotierte Punkte P und Q
PAlpha = DAlpha * P;
QAlpha = DAlpha * Q;

% Sonne
S = sym( 's', [ 3, 1 ] );
S( 1 ) = RS;
S( 2 ) = 0;
S( 3 ) = 0;

i = 1