%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'R', 'QAlpha', 'S' )

% Daten
% Strand vor "Las Palmas, P.º las Canteras, 74"
LP  = [ 28.136746041614316, -15.438275482887885 ] / 180.0 * pi;    % [Breite, Länge]
phi = 23.44 / 180.0 * pi;	% Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
rE  = 6371000.785;          % mittlerer Erdradius [m]
rS  = 149597870700;         % AE, mittlerer Abstand Erde - Sonne [m]
l   = 1.5;                  % Stablänge [m]

% Neigung der Erd-Rotationsachse berücksichtigen
LP( 1 ) = LP( 1 ) + phi;

% Koordinaten des Fusspunkt des Stabes (in Las Palmas)
p1 = rE * cos( LP( 1 ) ) * cos( LP( 2 ) ); % x-Koordinate
p2 = rE * cos( LP( 1 ) ) * sin( LP( 2 ) ); % y-Koordinate
p3 = rE * sin( LP( 1 ) );                  % z-Koordinate

mue0 = R / ( R + 1 );

x0 = mue0 * QAlpha + ( 1 - mue0 ) * S;
x0 = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)

% numerische Auswertung, Plot
N = 100;    % Anzahl Punkte

% N soll gerade sein
if( rem( N, 2 ) ~= 0 )
    N = N + 1;
end

h     = 5;      % Anzahl Stunden (um den Mittag herum)
delta = ( 2 * pi / 24 * h ) / N;

x = zeros( N + 1, 1 );
y = zeros( N + 1, 3 );

for i = 1 : N + 1
	alpha = ( i  - 1 - N / 2 ) * delta;

    x( i )    = alpha;
    y( i, : ) = eval( subs( x0 ) )';    % auch noch alpha substituieren
end

betrag          = sqrt( y( :, 1 ).^2 + y( :, 2 ).^2 + y( :, 3 ).^2 );
variationBetrag = max( betrag ) - min( betrag );
variationX1     = max( y( :, 1 ) ) - min( y( :, 1 ) );
variationX2     = max( y( :, 2 ) ) - min( y( :, 2 ) );
variationX3     = max( y( :, 3 ) ) - min( y( :, 3 ) );

hold 'on'
plot( x, y( :, 1 ) )    % x1
plot( x, y( :, 2 ) )    % x2
plot( x, y( :, 3 ) )    % x3
