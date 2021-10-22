%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu numerischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

load( 'sonnenkompass.mat', 'R' )

% Daten
LP    = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;    % Ortskoordinaten Las Palmas [Breitengrad, Längengrad]
phi   = 23.44 / 180 * pi;	% Komplementwinkel Erd-Rotationsachse zur Ekliptik [rad]
rE    = 6371000;            % Erdradius [m]
rS    = 149600 * 10^6;      % Abstand Erde - Sonne [m]
L     = 1.5;                % Stablänge [m]
alpha = 0 / 180 * pi;       % Rotationswinkel alpha [rad], alpha=0 -> Mittags d.h.Sonnenhöchststand

% Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + phi;

% Koordinaten des Fusspunkt des Stabes (in Las Palmas)
p1 = rE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = rE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = rE * sin( LP( 1 ) );                  % z-Koordinate

% Zahlenwerte substituieren
R = eval( subs( R ) );

fun( 0.999999999999999, L, R )
fun( 1.000000000000001, L, R )

% Geraden-Parameter mue bestimmen
options = optimset( 'Display', 'iter', 'TolX', 1e-60 );
mue0 = fzero( @fun, 1, options, L, R )


function f = fun( mue, arg1, arg2 )
    f = mue * ( arg1 + arg2 ) - arg2;
end