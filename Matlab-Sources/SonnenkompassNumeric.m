%#ok<*NASGU> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'mue0', ...
          'alphaPlus', 'alphaMinus', 'alphaCond', 'alphaPara', 'y0Strich', ...
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

	% Zahlenwerte bis auf alpha substituieren
    y0 = subs( y0 );

    % numerische Limits für zulässige Zeiten berechnen (Minuten)
    k = sym( 'k', 'integer' );

    k         = subs( 'k', 0 );
    alphaMinus = subs( alphaMinus );
    tStart    = ceil( 60 * 12 * double( alphaMinus ) / pi ) + 10;	% aufrunden

    k         = subs( 'k', 1 );
    alphaPlus = subs( alphaPlus );
    tEnd      = floor( 60 * 12 * double( alphaPlus ) / pi ) - 10;	% abrunden

    % astronomischer Mittag 
    k             = subs( 'k', 1 );
    alphaHighNoon = atan2( tan( omega ), cos( psi ) ) + k * pi;
    tHighNoon     = floor( 60 * 12 * double( alphaHighNoon ) / pi );

    % Überprüfung von alphaHighNoon: Steigung sollte 0 sein
    sPlusHN = subs( y0Strich( 2 ), 'alpha', alphaHighNoon );
	if( double( subs( sPlusHN ) ) > 1e-12 )
        error( 'Interner Fehler: Steigung am astronomischen Mittag ~= 0' )
	end

    tHighNoon = 60 * 12 * double( alphaHighNoon ) / pi;
    if( tStart >= tHighNoon || tEnd < tHighNoon )
        error( 'Interner Fehler: astronomischen Mittag nicht im Zeitintervall' )
    end

	% Steigung und Trajektorienpunkt bei alpha = alphaPlus
    ap = sym( 'ap', 'real' );
    ap = alphaPlus / 2;

    % Steigung
    sPlus = subs( y0Strich, 'alpha', ap );
    sPlus = double( subs( sPlus ) );

    % Trajektorie x-Achse
    y01 = subs( y0( 1 ), 'alpha', ap );
    y01 = double( subs( y01 ) );

    % Trajektorie y-Achse
    y02 = subs( y0( 2 ), 'alpha', ap );
    y02 = double( subs( y02 ) );

    % eins der Zeitsamples soll genau bei t = tHighNoon liegen
    tOffset = fix( tHighNoon ) - tHighNoon;

    % Numerische Auswertung
    N = tEnd - tStart + 1;      % Anzahl der Zeitpunkte
    y = zeros( N, 2 );          % Trajektorie, Asymptote [m]

    % Position und Zeitpunkt berechnen
    for i = 1 : N
        t     = tStart - tOffset + ( i - 1 );	% t in Minuten
        alpha = pi / ( 12 * 60 ) * t;           % zugehöriger Winkel

        yLoc = subs( y0, 'alpha', alpha )';     % in y0 alpha substituieren

        y( i, : ) = [ yLoc( 1 ), yLoc( 2 ) ];
    end

    save( fileName, 'y' )
end