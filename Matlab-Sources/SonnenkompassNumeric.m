%#ok<*NASGU> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'mue0', ...
          'alphaPlus', 'alphaMinus', 'sPlus', 'alphaHighNoon', ...
          'x0', 'y0' )

    % Variable Daten
    ort   = 'LasPalmas';
	datum = '12.10.2021';

    fileName = [ ort, '-', datum, '.mat' ];

    switch( ort )
        case 'LasPalmas'
            lS     = 1.5;                               % Stablänge [m]
            thetaG = 28.136746041614316 / 180.0 * pi;	% geographische Breite Las Palmas
    end

    % Fixe Daten
    rE  = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS  = 149597870700.0;           % AE, mittlerer Abstand Erde - Sonne [m]
    psi = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
    ssw = datetime( '21.06.2021' );	% Datum SSW

	tag    = datetime( datum );
    T      = days( tag - ssw );     % Jahreszeit [Tage seit SSW]
    omega  = 2 * pi / 365 * T;      % Jahreszeitwinkel ab SSW
    offset = thetaG - psi;          % Elevations-Winkeloffset für die Projektion

    % Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, dabei 
    % Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * cos( offset );        % x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * sin( offset );        % z-Koordinate

    % numerische Limits für zulässige Zeiten berechnen (Minuten)
    k = 0;
    tStart = ceil( 60 * 12 * eval( alphaPlus ) / pi ) + 10;     % aufrunden
    k = 1;
    tEnd   = floor( 60 * 12 * eval( alphaMinus ) / pi ) - 10;	% abrunden

    % Zeit des astronomischen Mittags bestimmen
    tHighNoon = 60 * 12 * eval( alphaHighNoon + k * pi ) / pi;
    if( tStart >= tHighNoon || tEnd < tHighNoon )
        error( 'Interner Fehler!' )
    end

    % eins der Zeitsamples soll genau bei t = tHighNoon liegen
    tOffset = fix( tHighNoon ) - tHighNoon;

    % Numerische Auswertung
    N = tEnd - tStart + 1;	% Anzahl der Zeitpunkte
    y = zeros( N, 2 );      % Trajektorie [m]

	% Zahlenwerte bis auf alpha substituieren
    y0 = subs( y0 );

    % Position und Zeitpunkt berechnen
    for i = 1 : N
        t     = tStart - tOffset + ( i - 1 );	% t in Minuten
        alpha = pi / ( 12 * 60 ) * t;           % zugehöriger Winkel

        yLoc = subs( y0, 'alpha', alpha )';     % in x0 alpha substituieren
        yLoc = eval( yLoc );

        y( i, : ) = [ yLoc( 1 ), yLoc( 2 ) ];
    end

    save( fileName, 'y' )
end