%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

format long

load( 'sonnenkompass.mat', 'Q', 'QAlpha', 'S', 'SAlpha', 'R_S', 'R_E' )

% Erde 'E' oder Sonne 'S' drehen
Drehen = 'S';

% Daten
% Strand vor "Las Palmas, P.º las Canteras, 74"
LP  = [ 28.136746041614316, -15.438275482887885 ] / 180.0 * pi;    % [Breite, Länge]
psi = 23.44 / 180.0 * pi;	% Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]

rE  = earthRadius;          % mittlerer Erdradius [m]
rS  = 149597870700;         % AE, mittlerer Abstand Erde - Sonne [m]
l   = 1.5;                  % Stablänge [m]

% Umrechnung geographische Koordinaten in Kugelkoordinaten
LP = [ pi / 2 - LP( 1 ), LP( 2 ) ];

% Kugelkoordinaten des Fusspunkt des Stabes (in Las Palmas), dabei Neigung der 
% Erd-Rotationsachse berücksichtigen
p1 = rE * sin( LP( 1 ) + psi ) * cos( LP( 2 ) ); % x-Koordinate
p2 = rE * sin( LP( 1 ) + psi ) * sin( LP( 2 ) ); % y-Koordinate
p3 = rE * cos( LP( 1 ) + psi );                  % z-Koordinate

% Test: Punkt P wird abgebildet auf (0,0), warum pi/2-... ???
% [ a, b ] = Maptangential( p1, p2, p3, 0, 0, ...
%                           -LP( 2 ), pi / 2 - ( LP( 1 ) + psi ) );

switch( Drehen )
    case 'E'
        % Fall: Erde wird gedreht
        vz   = 1;
        mue0 = R_E / ( 1 + R_E );
        x0	 = mue0 * QAlpha + ( 1 - mue0 ) * S;
        x0	 = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)
    case 'S'
        % Fall: Sonne wird gedreht
        vz   = -1;
        mue0 = R_S / ( 1 + R_S );
        x0   = mue0 * Q + ( 1 - mue0 ) * SAlpha;
        x0   = subs( x0 );    % Zahlenwerte substituieren (bis auf alpha)
end

% Test: 
% alpha = 1;
% x0    = eval( subs( x0 ) );

% numerische Auswertung, Plot
N = 50;    % Anzahl Punkte

% N soll gerade sein
if( rem( N, 2 ) ~= 0 )
    N = N + 1;
end

% min: Anzahl Minuten (um den Mittag herum)
% Trajektorienlänge in Las Palmas: ca. 3cm/10min. (experimentell ermittelt)
minutes = 60;
delta   = ( pi / 720 * minutes ) / N;    % Winkel-Delta

pts  = zeros( N + 1, 3 );    % [m]
y    = zeros( N + 1, 2 );    % [m]
t    = zeros( N + 1, 1 );    % [min]
alph = zeros( N + 1, 1 );    % [rad]

for i = 1 : N + 1
	alph( i ) = vz * ( i - 1 - N / 2 ) * delta;
    t( i )    = alph( i ) * 720 / pi;

    alpha       = alph( i );
    pts( i, : ) = eval( subs( x0 ) )';    % auch noch alpha substituieren
end

switch( Drehen )
    case 'E'
        for i = 1 : N + 1
            [ a, b ] = Maptangential( pts( i, 1 ), pts( i, 2 ), pts( i, 3 ), ...
                            psi, -alph( i ), -LP( 2 ), pi / 2 - ( LP( 1 ) + psi ) );
            y( i, : ) = [ a, b ];
        end
    case 'S'
        for i = 1 : N + 1
            [ a, b ] = Maptangential( pts( i, 1 ), pts( i, 2 ), pts( i, 3 ), ...
                            0, 0, -LP( 2 ), pi / 2 - ( LP( 1 ) + psi ) );
            y( i, : ) = [ a, b ];
        end
end

% Plotten der Ergebnisse
figure
title( 'Trajektorie Schattenende' )

hold 'on'
box 'on'
grid 'on'
axis( 'equal' )

txt = text( -0.02, -0.02, 'Stab' );
txt.FontSize   = 13;
txt.FontWeight = 'bold';
txt.FontName   = 'FixedWidth';

xlim( 1.2 * [ min( y( :, 1 ) ), max( y( :, 1 ) ) ] )
ylim( 1.2 * [ min( -0.1, min( y( :, 2 ) ) ),  max( 0.1, max( y( :, 2 ) ) ) ] )

xlabel( 'West-Ost [m]' )
ylabel( 'Süd-Nord [m]' )

% Ort des Stabes plotten
plot( 0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r' )

% Schatten-Trajektorie plotten
plot( y( :, 1 ), y( :, 2 ), 'Color', 'k', 'LineWidth', 2 )

% Die Variation des Betrages ist durch die Diskrepanz der Tangentialebene
% zur Kugeloberfläche erklärbar.
% betrag          = sqrt( y( :, 1 ).^2 + y( :, 2 ).^2 + y( :, 3 ).^2 );
% variationBetrag = max( betrag ) - min( betrag );
% variationX1     = max( y( :, 1 ) ) - min( y( :, 1 ) );
% variationX2     = max( y( :, 2 ) ) - min( y( :, 2 ) );
% variationX3     = max( y( :, 3 ) ) - min( y( :, 3 ) );
