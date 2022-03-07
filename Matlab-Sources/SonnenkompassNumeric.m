%#ok<*NASGU> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'omegaS', ...
          'mue0', 'alphaPlus', 'alphaMinus', 'y0Strich', 'y0' )

    % Variable Daten
    ort   = 'LasPalmas';
	datum = '12.10.2021';

    fileName = [ ort, '-', datum, '.mat' ];

    switch( ort )
        case 'LasPalmas'
            thetaG = 28.136746041614316 / 180.0 * pi;	% geographische Breite Las Palmas
    end

    % Fixe Daten
	lS  = 1.5;                      % Stablänge [m]
    rE  = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS  = 149597870700.0;           % AE, mittlerer Abstand Erde - Sonne [m]
    psi = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]

    ssw    = datetime( '21.06.2021' );	% Datum SSW
	tag    = datetime( datum );
    T      = days( tag - ssw );         % Jahreszeit [Tage seit SSW]
    omega  = 2 * pi / 365 * T;          % Jahreszeitwinkel ab SSW
    theta  = pi / 2 - (thetaG - psi );	% Polarwinkel in Kugelkoordinaten

    % Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, dabei 
    % Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * sin( theta );         % x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * cos( theta );         % z-Koordinate

	% Zahlenwerte bis auf alpha substituieren
    y0 = subs( y0 );

    % numerische Limits für zulässige Zeiten berechnen (Minuten)
    k = sym( 'k', 'integer' );

    k          = subs( 'k', 0 );
    alphaMinus = double( subs( alphaMinus ) );
    tStart     = ceil( 60 * 12 * alphaMinus / pi ) + 10;	% aufrunden

    k         = subs( 'k', 1 );
    alphaPlus = double( subs( alphaPlus ) );
    tEnd      = floor( 60 * 12 * alphaPlus / pi ) - 10;	% abrunden

    % astronomischer Mittag 
    alphaHighNoon = double( atan2( tan( omega ), cos( psi ) ) + k * pi );
    tHighNoon     = floor( 60 * 12 * alphaHighNoon / pi );

    tHighNoon = 60 * 12 * alphaHighNoon / pi;
    if( tStart >= tHighNoon || tEnd < tHighNoon )
        error( 'Interner Fehler: astronomischen Mittag nicht im Zeitintervall' )
    end

    % Überprüfung von alphaHighNoon: Steigung sollte 0 sein
    sPlusHN = subs( y0Strich( 2 ), 'alpha', alphaHighNoon );
	if( double( subs( sPlusHN ) ) > 1e-12 )
        error( 'Interner Fehler: Steigung am astronomischen Mittag ~= 0' )
	end

    % eins der Zeitsamples soll genau bei t = tHighNoon liegen
    tOffset = fix( tHighNoon ) - tHighNoon;

    % Numerische Auswertung
    N = tEnd - tStart + 1;      % Anzahl der Zeitpunkte
    y = zeros( N, 2 );          % Trajektorie [m]

    % Position und Zeitpunkt berechnen
    for i = 1 : N
        t     = tStart - tOffset + ( i - 1 );	% t in Minuten
        alpha = pi / ( 12 * 60 ) * t;           % zugehöriger Winkel

        yLoc = subs( y0, 'alpha', alpha )';     % in y0 alpha substituieren
        yLoc = double( yLoc );

        y( i, 1 : 2 ) = [ yLoc( 1 ), yLoc( 2 ) ];   % Trajektorie
    end

    save( fileName, 'y' )
end