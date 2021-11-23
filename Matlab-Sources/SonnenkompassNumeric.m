%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#ok<*UNRCH>
function SonnenkompassNumeric
    clc
    clear

    format long

    load( 'sonnenkompass.mat', 'alpha', 'dAlpha', 'q', 'sAlpha', 'omegaS' ) %#ok<NASGU>

    % variable Daten
    ort = 'LasPalmas';

    switch( ort )
        case 'Hoechst'
            lS     = 1.76;                              % Stablänge [m]
            breite = 49.800760064804244 / 180.0 * pi;	% Höchst/Odenwald
            datum  = '06.11.2021';                      % Datum
        case 'LasPalmas'
            lS     = 1.5;                               % Stablänge [m]
            breite = 28.136746041614316 / 180.0 * pi;	% Las Palmas de Gran Canaria
            datum  = '12.10.2021';                      % Datum
    end

    fileName = [ ort, '-', datum, '.mat' ];
    if( isfile( fileName ) )
        error( 'File "%s" existiert bereits!', fileName )
    end

    % fixe Daten
    rE  = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS  = 149597870700.0;           % AE, mittlerer Abstand Erde - Sonne [m]
    psi = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]
    ssw = datetime( '21.06.2021' );	% Datum Sommersonnenwende

	tag    = datetime( datum );
    T      = days( tag - ssw );	% Jahreszeit [Tage seit Sommersonnenwende]
    omega  = 2 * pi / 365 * T;	% Jahreszeitwinkel
    breite = pi / 2 - breite;	% Geographische- in Kugelkoordinaten umrechnen

    % Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, 
    % dabei Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * sin( breite + psi );	% x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * cos( breite + psi );  % z-Koordinate

    % Substitution
    mue0 = omegaS / ( 1 + omegaS );

    mue0 = subs( mue0, 'omega', omega );	% Zahlenwert für omega substituieren
    mue0 = subs( mue0, 'rS', rS );          % Zahlenwert für rS substituieren
    mue0 = subs( mue0, 'lS', lS );          % Zahlenwert für lS substituieren
    mue0 = subs( mue0, 'p1', p1 );          % Zahlenwert für p1 substituieren
    mue0 = subs( mue0, 'p2', p2 );          % Zahlenwert für p2 substituieren
    mue0 = subs( mue0, 'p3', p3 );          % Zahlenwert für p3 substituieren
    mue0 = subs( mue0 );                    % Zahlenwerte substituieren (alle anderen bis auf alpha)

    x0 = mue0 * q + ( 1 - mue0 ) * sAlpha;
    x0 = subs( x0 );      % Zahlenwerte substituieren (alle bis auf alpha)

    % Trajektorie in Las Palmas ca.: ds = 3cm/10min. (experimentell ermittelt)
    % numerische Auswertung, Plotten
    minutes = 60 * 24;      % Anzahl Minuten
    N       = minutes;      % Anzahl Punkte

    pts     = zeros( N + 1, 3 );    % [m]
    y       = zeros( N + 1, 2 );    % [m]
    t       = zeros( N + 1, 1 );    % [min]
    abstand = zeros( N + 1, 1 );    % [m]

    delta = minutes / N;	% Delta Minuten
    % Position und Zeitpunkt berechnen
    for i = 1 : N + 1
        t( i ) = ( i - 1 ) * delta;     % t in Minuten 
        alpha  = t( i ) / ( 720 * pi ); % 2*pi[rad]=60*24[min], [rad]=60*24/(2*pi)[min]

        mue = subs( mue0, 'alpha', alpha );  % in mue0 alpha substituieren
        mue = eval( mue );
        if( mue > 1 )
            x           = subs( x0, 'alpha', alpha )';  % in x0 alpha substituieren
            pts( i, : ) = eval( x )';
        else
            pts( i, : ) = [ Inf, Inf, Inf ];
        end
    end

    % Projektion auf Tangentialebene
    for i = 1 : N + 1
        [ a, b ] = MapToTangentialPlane( pts( i, 1 ), pts( i, 2 ), ...
                        pts( i, 3 ), 0, pi / 2 - ( breite + psi ) );

        y( i, : )    = [ a, b ];
        abstand( i ) = sqrt( a^2 + b^2 );
    end

    save( fileName, 'y', 'abstand' )
end

function [ x2, x3 ] = MapToTangentialPlane( x1, x2, x3, phi, theta )
    % Punkt drehen um x3-Achse um den Winkel phi
    if( phi ~= 0 )
        [ x1, x2, x3 ] = rotateX3( phi, x1, x2, x3 );
    end

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