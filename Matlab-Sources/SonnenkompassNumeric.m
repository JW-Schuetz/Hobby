%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    format long

    load( 'SonnenkompassSymbolic.mat', 'alpha', 'dAlpha', ...
          'q', 'sAlpha', 'omegaS' ) %#ok<NASGU>

    % Variable Daten
    ort = 'LasPalmas';

    switch( ort )
        case 'Hoechst'
            lS        = 1.76;                               % Stablänge [m]
            breiteGeo = 49.800760064804244 / 180.0 * pi;	% Höchst/Odenwald
            datum     = '06.11.2021';                       % Datum
        case 'LasPalmas'
            lS        = 1.5;                                % Stablänge [m]
            breiteGeo = 28.136746041614316 / 180.0 * pi;	% Las Palmas de Gran Canaria
            datum     = '12.10.2021';                       % Datum
    end

    fileName = [ ort, '-', datum, '.mat' ];
    if( isfile( fileName ) )
%         error( 'File "%s" existiert bereits!', fileName )
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    % Drehwinkel bestimmen für Sonnenhöchststand bei alpha=0
%     alphaShift = calculateShiftAngle( dAlpha, alpha, psi, omega, p1, p2, p3 );
% 
%     % Ort der Jahreszeit entsprechend drehen
%     [ p1, p2, p3 ] = RotateDAlpha( dAlpha, psi, p1, p2, p3, alphaShift );
% 
% 	% Überprüfung des gefundenen Winkels
%     if( abs( omega - atan2( p2, p1 ) ) > 0.0001 )
%         error( 'Wrong shift angle' )
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function alphaShift = calculateShiftAngle( dAlpha, alpha, psi, omega, p1, p2, p3 )
    % Drehwinkel bestimmen, abhängig von Jahreszeit
    dAlpha = subs( dAlpha, 'psi', psi );    % psi substituieren

    x = dAlpha * [ p1; p2; p3 ];

    solution = solve( x( 2 ) == tan( omega ) * x( 1 ), alpha, 'real', true );
    if( ~isempty( solution ) )
        alphaShift = eval( solution );

        % Es gibt 2 Lösungen, sie unterscheiden sich nach RotateDAlpha() um pi:
        % 1. Lösung: omega - atan2( p2, p1 ) = 0
        % 2. Lösung: omega - atan2( p2, p1 ) = pi
        alphaShift = sort( alphaShift, 'descend' );
        alphaShift = alphaShift( 1 );
    else
        error( 'No solution found' )
    end
end

function [ x1, x2, x3 ] = RotateDAlpha( dAlpha, psi, x1, x2, x3, alpha )
    % Punkt um den Winkel alpha drehen um Erdrotations-Achse 
    if( alpha ~= 0 )
        dAlpha = subs( dAlpha, 'psi', psi );
        dAlpha = eval( subs( dAlpha ) );

        x  = dAlpha * [ x1; x2; x3 ];

        x1 = x( 1 );
        x2 = x( 2 );
        x3 = x( 3 );
    end
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

function [ x1, x2, x3 ] = rotateX3( phi, x1, x2, x3 )
    % Punkt drehen um x3-Achse um den Winkel phi
    c = cos( phi );
    s = sin( phi );

    D = [ c, -s, 0;
          s,  c, 0;
          0,  0, 1 ];

    x = D * [ x1; x2; x3 ];

    x1 = x( 1 );
    x2 = x( 2 );
    x3 = x( 3 );
end