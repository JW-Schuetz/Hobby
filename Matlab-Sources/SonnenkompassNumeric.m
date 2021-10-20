%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu numerischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

% Daten
LP    = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;    % Ortskoordinaten Las Palmas [Breitengrad, Längengrad]
Phi   = 23.44 / 180 * pi;	% Komplementwinkel Erd-Rotationsachse zur Ekliptik [rad]
RE    = 6371000;            % Erdradius [m]
RS    = 149600 * 10^6;      % Abstand Erde - Sonne [m]
L     = 1.5;                % Stablänge [m]
Alpha = 0 / 180 * pi;       % Rotationswinkel alpha [rad], alpha=0 -> Mittags d.h.Sonnenhöchststand

% Debugging
LP    = [ 0, 0 ] / 180 * pi;	% Ortskoordinaten
Phi   = 0 / 180 * pi;           % Komplementwinkel Erd-Rotationsachse zur Ekliptik [rad]
RE    = 10;                     % Erdradius [m]
RS    = 100;                    % Abstand Erde - Sonne [m]
L     = 1;                      % Stablänge [m]
Alpha = 0 / 180 * pi;           % Rotationswinkel alpha [rad], alpha=0 -> Mittags d.h.Sonnenhöchststand

% Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + Phi;

% Koordinaten des Stabes (in Las Palmas)
p1 = RE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = RE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = RE * sin( LP( 1 ) );                  % z-Koordinate

% Fusspunkt Stab
P = [ p1; p2; p3 ];
% Ende Stab
Q = ( 1 + L / RE ) * P;
% Sonne
S = [ RS, 0, 0 ];

% Gerade
N = 100;
delta = 1 / N;
G = zeros( 3, N );
for n = 1 : N + 1
    mue = ( n - 1 ) * delta;
    G( :, n ) = mue * Q + ( 1 - mue ) * P;
end

a1 = sin( Phi )^2 * ( cos( Alpha ) - 1 ) - cos( Alpha );
a2 = cos( Phi ) * sin( Alpha );
a3 = cos( Phi ) * sin( Phi ) * ( cos( Alpha ) - 1 );
A  = [ a1; a2; a3 ];

% Geraden-Parameter mue bestimmen, NB: mue > 1
arg1 = L;
arg2 = RE + RS / RE * A' * P;

arg1 / ( arg1 + arg2 )

% options = optimset( 'Display', 'iter', 'TolX', 1e-10 );
% x = fminbnd( @fun, 0.99, 10, options, arg1, arg2 );
% x

function f = fun( mue, arg1, arg2 )
    f = mue * ( arg1 + arg2 ) - arg2;
end