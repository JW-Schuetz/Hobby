%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'omegaS' ) %#ok<NASGU>

    % Variable Daten
    ort   = 'LasPalmas';
	datum = '23.09.2021';

    fileName = [ ort, '-', datum, '.mat' ];

    switch( ort )
        case 'LasPalmas'
            lS        = 1.5;                                % Stablänge [m]
            breiteGeo = 28.136746041614316 / 180.0 * pi;	% Las Palmas de Gran Canaria
    end

    % Fixe Daten
    rE  = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS  = 149597870700.0;           % AE, mittlerer Abstand Erde - Sonne [m]
    psi = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
    ssw = datetime( '21.06.2021' );	% Datum SSW

	tag    = datetime( datum );
    T      = days( tag - ssw );     % Jahreszeit [Tage seit SSW]
    omega  = 2 * pi / 365 * T;      % Jahreszeitwinkel ab SSW
    breite = pi / 2 - breiteGeo;    % Geographische- in Kugelkoordinaten umrechnen
    offset = breiteGeo - psi;       % Elevations-Winkeloffset für die Projektion

    % Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, dabei 
    % Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * sin( breite + psi );	% x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * cos( breite + psi );  % z-Koordinate

    mue0 = omegaS / ( 1 + omegaS );
    x0   = mue0 * q + ( 1 - mue0 ) * sAlpha;

    % Zahlenwerte bis auf alpha substituieren (explizit wg. NotUsed-MatLab-Warnungen)
    mue0 = subs( mue0, 'omega', omega );
    mue0 = subs( mue0, 'rS',    rS );
    mue0 = subs( mue0, 'lS',    lS );
    mue0 = subs( mue0, 'p1',    p1 );
    mue0 = subs( mue0, 'p2',    p2 );
    mue0 = subs( mue0, 'p3',    p3 );
    mue0 = subs( mue0, 'psi',   psi );
    x0   = subs( x0 );  % Zahlenwerte bis auf alpha substituieren

    % Numerische Auswertung
    M = 60 * 24;	% Anzahl Minuten (1 Tag = 60*24 Stunden)
    N = 1 * M + 1;	% Anzahl Punkte

    y = zeros( N, 3 );    % [m]

    delta = M / ( N - 1 );	% Delta Minuten

    % Position und Zeitpunkt berechnen
    for i = 1 : N
        t     = ( i - 1 ) * delta;     % t in Minuten (0 bis 60*24 + 1)
        alpha = 2 * pi / M * t;

        mue = subs( mue0, 'alpha', alpha );  % in mue0 alpha substituieren
        mue = eval( mue );
        if( mue > 1 )
            x    = subs( x0, 'alpha', alpha )';  % in x0 alpha substituieren
            pts  = eval( x );

            pts1 = pts( 1 );
            pts2 = pts( 2 );
            pts3 = pts( 3 );
        else
            pts1 = Inf;
            pts2 = Inf;
            pts3 = Inf;
        end

        % Projektion auf Tangentialebene
        [ y1, y2 ] = MapToTangentialPlane( pts1, pts2, pts3, offset );
        y( i, : )  = [ t, y1, y2 ];
    end

    save( fileName, 'y' )
end

function [ x2, x3 ] = MapToTangentialPlane( x1, x2, x3, theta )
    % Punkt drehen um x2-Achse und den Winkel theta
    if( theta ~= 0 )
        [ x1, x2, x3 ] = rotateX2( theta, x1, x2, x3 );
    end

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0;
          0, 0, 1 ];

    x = A * [ x1; x2; x3 ];

    x2 = x( 1 );
    x3 = x( 2 );
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