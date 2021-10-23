%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'R' )

% Daten
LP    = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;    % Ortskoordinaten Las Palmas [Breitengrad, Längengrad]
phi   = 23.44 / 180 * pi;	% Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
rE    = 6371000.785;        % mittl. Erdradius [m]
rS    = 149597870700;       % Astronomische Einheit, mittl. Abstand Erde - Sonne [m]
l     = 1.5;                % Stablänge [m]
alpha = 0 / 180 * pi;       % Rotationswinkel alpha [rad], alpha=0 -> Mittags d.h.Sonnenhöchststand

% Neigung der Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + phi;

% Koordinaten des Fusspunkt des Stabes (in Las Palmas)
p1 = rE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = rE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = rE * sin( LP( 1 ) );                  % z-Koordinate

% Zahlenwerte substituieren
R = eval( subs( R ) );

% Lösung 
mue0 = R / ( R + 1 );
sprintf( 'Mue0 = %1.20f', mue0 )
