clc
clear

Phi = sym( 'Phi' ); % Winkel Erd-Rotationsachse zur Ekliptik

n      = sym( 'n', [ 3, 1 ] );	% Einheitsvektor Rotationsachse 
n( 1 ) = sin( Phi );
n( 2 ) = 0;
n( 3 ) = cos( Phi );

Alpha = sym( 'Alpha' );	% Erd-Rotationswinkel (2*pi/24h)
ca    = cos( Alpha );
sa    = sin( Alpha );

DAlpha = sym( 'DAlpha', [ 3, 3 ] );	% Drehmatrix
DAlpha( 1, 1 ) = n( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
DAlpha( 2, 1 ) = n( 1 ) * n( 2 ) * ( 1 - ca ) + n( 3 ) * sa;
DAlpha( 3, 1 ) = n( 1 ) * n( 3 ) * ( 1 - ca ) - n( 2 ) * sa;

DAlpha( 1, 2 ) = n( 1 ) * n( 2 ) * ( 1 - ca ) - n( 3 ) * sa;    % 2. Spalte
DAlpha( 2, 2 ) = n( 2 )^2        * ( 1 - ca ) + ca;
DAlpha( 3, 2 ) = n( 2 ) * n( 3 ) * ( 1 - ca ) + n( 1 ) * sa;

DAlpha( 1, 3 ) = n( 1 ) * n( 3 ) * ( 1 - ca ) + n( 2 ) * sa;    % 3. Spalte
DAlpha( 2, 3 ) = n( 2 ) * n( 3 ) * ( 1 - ca ) - n( 1 ) * sa;
DAlpha( 3, 3 ) = n( 3 )^2        * ( 1 - ca ) + ca;

P = sym( 'P', [ 3, 1 ] );	% Punkt P der Erdoberfläche
