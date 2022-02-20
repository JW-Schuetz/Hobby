%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'mue0', ...
          'alphaPlus', 'alphaMinus', 'sPlus', 'alphaHighNoon', ...
          'chi2', 'f' ) %#ok<NASGU>

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
    tStart = ceil( 60 * 12 * eval( alphaPlus ) / pi ) + 10;     % aufrunden
    tEnd   = floor( 60 * 12 * eval( alphaMinus ) / pi ) - 10;	% abrunden

    % numerisch Grenz-Steigungswerte bestimmen, es gilt sPlus == sMinus
	sPlus = eval( subs( sPlus, 'alpha', 'alphaPlus' ) );
    sPlus = eval( sPlus );

    % Symptotenparameter bestimmen
    xPlus = eval( subs( chi2, 'alpha', 'alphaPlus' ) );
    xPlus = eval( xPlus );
    yPlus = eval( subs( f, 'alpha', 'alphaPlus' ) );
    yPlus = eval( yPlus );
    bPlus = yPlus - sPlus * xPlus;

    % Zeit des astronomischen Mittags bestimmen
    tHighNoon = 60 * 12 * ( eval( alphaHighNoon ) + pi ) / pi;
    if( tStart >= tHighNoon || tEnd < tHighNoon )
        error( 'Interner Fehler!' )
    end

    % eins der Zeitsamples soll genau bei t = tHighNoon sein
    tOffset = fix( tHighNoon ) - tHighNoon;

    % Ausdrücke für mue0, x0
    x0 = mue0 * q + ( 1 - mue0 ) * sAlpha;

    % Zahlenwerte bis auf alpha substituieren, explizit wegen
	% NotUsed MatLab-Warnungen
    mue0 = subs( mue0, 'omega', omega );
    mue0 = subs( mue0, 'rS',    rS );
    mue0 = subs( mue0, 'lS',    lS );
    mue0 = subs( mue0, 'p1',    p1 );
    mue0 = subs( mue0, 'p2',    p2 );
    mue0 = subs( mue0, 'p3',    p3 );
    mue0 = subs( mue0, 'rE',    rE );
    mue0 = subs( mue0, 'psi',   psi );

	% Zahlenwerte bis auf alpha substituieren (implizit)
    x0 = subs( x0 );

    % Numerische Auswertung
    N = tEnd - tStart + 1;	% Anzahl der Zeitpunkte

    y = zeros( N, 4 );      % Trajektorie und Asymptote [m]

    % Position und Zeitpunkt berechnen
    for i = 1 : N
        t     = tStart - tOffset + ( i - 1 );	% t in Minuten
        alpha = pi / ( 12 * 60 ) * t;           % zugehöriger Winkel

        mue = subs( mue0, 'alpha', alpha );     % in mue0 alpha substituieren
        mue = eval( mue );
        if( mue > 1 )
            x = subs( x0, 'alpha', alpha )';	% in x0 alpha substituieren
            x = eval( x );

            pts1 = x( 1 );  % x1-Koordinate
            pts2 = x( 2 );  % x2-Koordinate
            pts3 = x( 3 );  % x3-Koordinate
        else
            error( 'SonnenkompassNumeric: Keine Lösung!' )
        end

        % Projektion der Trajektorie auf die Tangentialebene
        [ y1, y2 ] = MapTrajektoryToTangentialPlane( pts1, pts2, pts3, offset );
        [ y3, y4 ] = Asymptote( pts1, sPlus, bPlus );
        y( i, : )  = [ y1, y2, y3, y4 ];
    end

    save( fileName, 'y' )
end

function [ y1, y2 ] = Asymptote( x1, sPlus, bPlus )
    y1 = 0;
    y2 = 0;
end

function [ y1, y2 ] = MapTrajektoryToTangentialPlane( x1, x2, x3, theta )
    % Punkt drehen um x2-Achse und den Winkel theta
    if( theta ~= 0 )
        [ ~, y1, y2 ] = rotateX2( theta, x1, x2, x3 );
    end

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0;
          0, 0, 1 ];

    x = A * [ x1; x2; x3 ];

    y1 = x( 1 );
    y2 = x( 2 );
end

function [ x1, x2, x3 ] = rotateX2( theta, x1, x2, x3 )
    % Punkt drehen um x2-Achse und den Winkel theta
    c = cos( theta );
    s = sin( theta );

    D = [  c, 0, s;
           0, 1, 0;
          -s, 0, c ];

    x = D * [ x1; x2; x3 ];

    x1 = x( 1 );
    x2 = x( 2 );
    x3 = x( 3 );
end