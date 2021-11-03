%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'Q', 'QAlpha', 'S', 'SAlpha', 'R1', 'R2' )

% Erde 'E' oder Sonne 'S' drehen
Drehen = 'S';

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

switch( Drehen )
    case 'E' 
        % Fall: Erde wird gedreht
        vz   = 1;
        mue0 = R1 / ( R1 + 1 );
        x0	 = mue0 * QAlpha + ( 1 - mue0 ) * S;
        x0	 = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)
    case 'S'
        % Fall: Sonne wird gedreht
        vz   = -1;
        mue0 = R2 / ( R2 + 1 );
        x0   = mue0 * Q + ( 1 - mue0 ) * SAlpha;
        x0   = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)
end

% numerische Auswertung, Plot
N = 100;    % Anzahl Punkte

% N soll gerade sein
if( rem( N, 2 ) ~= 0 )
    N = N + 1;
end

% h: Anzahl Stunden (um den Mittag herum)
% Trajektorienlänge in Las Palmas: ca. 3cm/10min. (experimentell ermittelt)
h     = 1 / 6;  % 1/6 h sind 10 min.
delta = ( 2 * pi / 24 * h ) / N;

x = zeros( N + 1, 1 );
y = zeros( N + 1, 3 );

for i = 1 : N + 1
    x( i )    = vz * ( i  - 1 - N / 2 ) * delta;
	alpha     = x( i );
    y( i, : ) = eval( subs( x0 ) )';    % auch noch alpha substituieren
end

% Die Variation des Betrages ist durch die Diskrepanz der Tangentialebene
% zur Kugeloberfläche erklärbar.
betrag          = sqrt( y( :, 1 ).^2 + y( :, 2 ).^2 + y( :, 3 ).^2 );
variationBetrag = max( betrag ) - min( betrag );
variationX1     = max( y( :, 1 ) ) - min( y( :, 1 ) );
variationX2     = max( y( :, 2 ) ) - min( y( :, 2 ) );
variationX3     = max( y( :, 3 ) ) - min( y( :, 3 ) );

hold 'on'
plot( x, y( :, 1 ) - p1 )    % x1
plot( x, y( :, 2 ) - p2 )    % x2
plot( x, y( :, 3 ) - p3 )    % x3

x