%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#ok<*UNRCH>
function SonnenkompassNumeric
    clc
    clear

    format long

    load( 'sonnenkompass.mat', 'alpha', 'dAlpha', 'q', 'sAlpha', 'omegaS' ) %#ok<NASGU>

    % fixe Daten
    rE  = 6371000.8;                % mittlerer Erdradius [m] (GRS 80, WGS 84)
    rS  = 149597870700;             % AE, mittlerer Abstand Erde - Sonne [m]
    psi = 23.44 / 180.0 * pi;       % Winkel Erd-Rotationsachse senkrecht zur Ekliptik [rad]

    ssw    = datetime( '21.06.2021' );	% Datum Sommersonnenwende
    tag    = datetime( '12.10.2021' );	% Datum
    T      = days( tag - ssw );         % Jahreszeit [Tage seit Sommersonnenwende]
	omega  = 2 * pi / 365 * T;          % Jahreszeitwinkel

    % variable Daten
    lS  = 1.5;                      % Stablänge [m]
    % Ort: Las Palmas de Gran Canaria, P.º las Canteras, 74
    breite  = 28.136746041614316 / 180.0 * pi;
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
    N       = minutes / 10;	% Anzahl Punkte
    delta   = minutes / N;	% Delta Minuten

    pts     = zeros( N + 1, 3 );    % [m]
    y       = zeros( N + 1, 2 );    % [m]
    t       = zeros( N + 1, 1 );    % [h]
    abstand = zeros( N + 1, 1 );    % [m]

    % Zeitpunkte berechnen
    for i = 1 : N + 1
        t( i ) = ( i - 1 ) * delta;     % t in Minuten 
        alpha  = pi / 720 * t( i );

        mue = subs( mue0, 'alpha', alpha );  % in mue0 alpha substituieren
        mue = eval( mue );
        if( mue > 1 )
            x           = subs( x0, 'alpha', alpha )';  % in x0 alpha substituieren
            pts( i, : ) = eval( x )';
        else
            pts( i, : ) = [ Inf, Inf, Inf ];
        end
    end

    % Koordinatentransformation
    for i = 1 : N + 1
        [ a, b ] = MapToTangentialPlane( pts( i, 1 ), pts( i, 2 ), ...
                        pts( i, 3 ), 0, pi / 2 - ( breite + psi ) );

        abstand( i ) = sqrt( a^2 + b^2 );
        y( i, : )    = [ a, b ];
    end

    [ minAbstand, ndx ] = min( abstand );
    mint                = t( ndx );
    sprintf( 'Minimaler Abstand: %1.2f m\tZeitpunkt: %1.1f min', ...
        minAbstand( 1 ) , abs( mint ) )

    plotIt( t, y )
end

function plotIt( t, y )
    % Plotten der Ergebnisse
    figure

    title( 'Trajektorie des Schattenendes' )

    hold 'on'
    box 'on'
    grid 'on'
    axis( 'equal' )

    squareSize = 2;     % [m]
    xlim( squareSize * [ -1, 1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r' )
    % Schatten-Trajektorie plotten
    plot( y( :, 1 ), y( :, 2 ), '-o', 'MarkerSize', 2, 'Color', 'k', 'LineWidth', 1 )

    legend( 'Stabposition', 'Trajektorie, 10 Minuten-Intervalle' )
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