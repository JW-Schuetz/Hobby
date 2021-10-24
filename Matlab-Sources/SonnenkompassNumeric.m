%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'R', 'QAlpha', 'S' )

% Daten
LP  = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;    % Ortskoordinaten Las Palmas [Breitengrad, Längengrad]
phi = 23.44 / 180 * pi;	% Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
rE  = 6371000.785;        % mittl. Erdradius [m]
rS  = 149597870700;       % Astronomische Einheit, mittl. Abstand Erde - Sonne [m]
l   = 1.5;                % Stablänge [m]

% Neigung der Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + phi;

% Koordinaten des Fusspunkt des Stabes (in Las Palmas)
p1 = rE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = rE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = rE * sin( LP( 1 ) );                  % z-Koordinate

mue0 = R / ( R + 1 );
x0   = mue0 * QAlpha + ( 1 - mue0 ) * S;
x0   = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)

% numerische Auswertung, Plot
N = 100;
x = zeros( N, 1 );
y = zeros( N, 3 );
delta = pi / 2 / N;

for i = 1 : N
	alpha     = ( i - 1 ) * delta;
    x( i )    = alpha;
    y( i, : ) = eval( subs( x0 ) )';    % alpha substituieren
end

hold 'on'
plot( x, y( :, 1 ) )
plot( x, y( :, 2 ) )
plot( x, y( :, 3 ) )
