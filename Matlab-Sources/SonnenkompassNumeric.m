%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu numerischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

Phi = 23.44 / 180 * pi;     % Komplementwinkel Erd-Rotationsachse zur Ekliptik [rad]
RS  = 149600 * 10^6;        % Abstand Erde - Sonne [m]
RE  = 6371000;              % Erdradius [m]
L   = 1.5;                  % Stablänge [m]

% Ortskoordinaten Las Palmas [Breitengrad, Längengrad]
LP = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;

% Komplementwinkel Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + Phi;

% Koordinaten des Stabes (in Las Palmas)
p1 = RE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = RE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = RE * sin( LP( 1 ) );                  % z-Koordinate

% Punkt P
P  = [ p1; p2; p3 ];

Alpha = 0 / 180 * pi;       % Rotationswinkel [rad]

a1 = sin( Phi )^2 * ( cos( Alpha ) - 1 ) - cos( Alpha );
a2 = cos( Phi ) * sin( Alpha );
a3 = cos( Phi ) * sin( Phi ) * ( cos( Alpha ) - 1 );
A  = [ a1; a2; a3 ];

% Geraden-Parameter mue bestimmen, NB: mue > 1
arg1 = L;
arg2 = RE + RS * A' * P / RE;

% options = optimset( 'Display', 'iter' );
% x = fminbnd( @fun, 1, Inf, options, arg1, arg2 );
% x

function f = fun( mue, arg1, arg2 )
    f = mue * ( arg1 + arg2 ) - arg2;
end