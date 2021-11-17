%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'Q', 'SAlpha', 'OmegaS' )

% fixe Daten
rE  = 6371000.8;            % mittlerer Erdradius [m] (GRS 80, WGS 84)
rS  = 149597870700;         % AE, mittlerer Abstand Erde - Sonne [m]
psi = 23.44 / 180.0 * pi;	% Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
ssw = datetime( '21.06.2021' ); % Datum Sommersonnenwende

% variable Daten
lS  = 1.5;                      % Stablänge [m]
tag = datetime( '12.10.2021' ); % Datum
% Ort: Las Palmas de Gran Canaria, P.º las Canteras, 74
breite  = 28.136746041614316 / 180.0 * pi;

breite = pi / 2 - breite;	% Geographische- in Kugelkoordinaten umrechnen
T      = days( tag - ssw );	% Jahreszeit [Tage seit Sommersonnenwende]
omega  = 2 * pi / 365 * T;  % Jahreszeitwinkel

% Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, 
% dabei Neigung der Erd-Rotationsachse berücksichtigen
p1 = rE * sin( breite + psi );	% x-Koordinate
p2 = rE * sin( omega );         % y-Koordinate
p3 = rE * cos( breite + psi );	% z-Koordinate

% Substitution
mue0 = OmegaS / ( 1 + OmegaS );
x0   = mue0 * Q + ( 1 - mue0 ) * SAlpha;
x0   = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)

% numerische Auswertung, Plot
N = 50;    % Anzahl Punkte

% N soll gerade sein
N = fix( N );
if( rem( N, 2 ) ~= 0 )
    N = N + 1;
end

% minutes: Anzahl Minuten (um den Mittag herum)
% Trajektorie in Las Palmas: ds = 3cm/10min. (ca., experimentell ermittelt)
minutes = 60;    % 24 Stunden
delta   = ( pi / 720 * minutes ) / N;	% Winkel-Delta

pts     = zeros( N + 1, 3 );    % [m]
y       = zeros( N + 1, 2 );    % [m]
t       = zeros( N + 1, 2 );    % [h]
abstand = zeros( N + 1, 2 );    % [m]

% Zeitpunkte berechnen
for i = 1 : N + 1
	t( i ) = -( i - 1 - N / 2 ) * delta;    % Stunden
    alpha  = 12 * t( i ) / pi;

    mue = eval( subs( mue0 ) );  % in mue0 alpha substituieren
    if( mue > 1 )
        pts( i, : ) = eval( subs( x0 ) )';  % in x0 alpha substituieren
    else
        pts( i, : ) = [ Inf, Inf, Inf ];
    end
end

% Koordinatentransformation
for i = 1 : N + 1
    [ a, b ] = MapToTangentialPlane( pts( i, 1 ), pts( i, 2 ), pts( i, 3 ), ...
                    0, pi / 2 - ( breite + psi ) );
    abstand( i ) = sqrt( a^2 + b^2 );
    y( i, : )    = [ a, b ];
end

[ minAbstand, ndx ] = min( abstand );
mint               = t( ndx( 1 ) )

% Plotten der Ergebnisse
figure
title( 'Trajektorie des Schattenendes' )

hold 'on'
box 'on'
grid 'on'
axis( 'equal' )

squareSize = 3; % [m]
xlim( squareSize * [ -1, 1 ] );
ylim( squareSize * [ -1, 1 ] );

xlabel( 'West-Ost [m]' )
ylabel( 'Süd-Nord [m]' )

% Ort des Stabes plotten
plot( 0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r' )
% Schatten-Trajektorie plotten
plot( y( :, 1 ), y( :, 2 ), 'Color', 'k', 'LineWidth', 2 )
% Parameter plotten
% plot( 0, 0, 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b' )

legend( 'Stabposition' )