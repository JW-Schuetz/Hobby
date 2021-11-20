%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerische Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassNumeric
    clc
    clear

    format long

    load( 'sonnenkompass.mat', 'Alpha', 'DAlpha', 'Q', 'SAlpha', 'OmegaS' )

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
    % dabei Neigung der Erd-Rotationsachse psi berücksichtigen
    p1 = rE * sin( breite + psi );	% x-Koordinate
    p2 = 0;                         % y-Koordinate
    p3 = rE * cos( breite + psi );  % z-Koordinate

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drehwinkel bestimmen für Sonnenhöchststand bei alpha=0
    alphaShift = calculateShiftAngle( Alpha, DAlpha, psi, omega, p1, p2, p3 );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Ort der Jahreszeit entsprechend drehen
    [ p1, p2, p3 ] = RotateDAlpha( DAlpha, psi, p1, p2, p3, alphaShift );

	% Überprüfung des gefundenen Winkels
    if( abs( omega - atan2( p2, p1 ) ) > 0.01 )
        error( 'Wrong shift angle' )
    end

    % Substitution
    mue0 = OmegaS / ( 1 + OmegaS );
    x0   = mue0 * Q + ( 1 - mue0 ) * SAlpha;
    x0   = subs( x0 );    % Zahlenwerte substituieren (alle bis auf alpha)

    % Trajektorie in Las Palmas ca.: ds = 3cm/10min. (experimentell ermittelt)
    % numerische Auswertung, Plotten
    N       = 100;          % Anzahl Punkte
    minutes = 120;          % Anzahl Minuten (ab Mittags Sonnenhöchststand =12Uhr?)
    delta   = minutes / N;	% Delta Minuten

    pts     = zeros( N, 3 );    % [m]
    y       = zeros( N, 2 );    % [m]
    t       = zeros( N, 1 );    % [h]
    abstand = zeros( N, 1 );    % [m]

    % Zeitpunkte berechnen
    for i = 1 : N
        t( i ) = ( i - 1 ) * delta;     % t in Minuten 
        alfa   = pi / 720 * t( i );

        mue = eval( subs( mue0 ) );  % in mue0 alpha substituieren
        if( mue > 1 )
            pts( i, : ) = eval( subs( x0 ) )';  % in x0 alpha substituieren
        else
            pts( i, : ) = [ Inf, Inf, Inf ];
        end
    end

    % Koordinatentransformation
    for i = 1 : N
        % Ort der Jahreszeit entsprechend zurückdrehen
        [ x1, x2, x3 ] = RotateDAlpha( DAlpha, psi, pts( i, 1 ), ...
                            pts( i, 2 ), pts( i, 3 ), -alphaShift );

        [ a, b ] = MapToTangentialPlane( x1, x2, x3, 0, ...
                        pi / 2 - ( breite + psi ) );

        abstand( i ) = sqrt( a^2 + b^2 );
        y( i, : )    = [ a, b ];
    end

    [ minAbstand, ndx ] = min( abstand );
    mint                = t( ndx( 1 ) );
    sprintf( 'Minimaler Abstand: %1.2f m\tZeitpunkt: %1.1f min', ...
        minAbstand( 1 ) , abs( mint ) )

    % Plotten der Ergebnisse
    figure
    title( 'Trajektorie des Schattenendes' )

    hold 'on'
    box 'on'
    grid 'on'
    axis( 'equal' )

    squareSize = 2; % [m]
    xlim( squareSize * [ -1, 1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r' )
    % Schatten-Trajektorie plotten
    plot( y( :, 1 ), y( :, 2 ), 'Color', 'k', 'LineWidth', 2 )
    % Parameter plotten
    % plot( 0, 0, 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b' )

    legend( 'Stabposition', 'Trajektorie' )
end

function alphaShift = calculateShiftAngle( Alpha, DAlpha, psi, omega, p1, p2, p3 )
    % Drehwinkel bestimmen
    tOmega = tan( omega );

    u1 = sym( 'p1' );
    u2 = sym( 'p2' );
    u3 = sym( 'p3' );

    x = DAlpha * [ u1; u2; u3 ];
    x = subs( x );

    solution = solve( x( 2 ) == tOmega * x( 1 ), Alpha, 'real', true );
    if( ~isempty( solution ) )
        alphaShift = eval( solution );

        % falls mehrere Lösungen gefunden werden: die grösste nehmen
        alphaShift = sort( alphaShift, 'descend' );
        alphaShift = alphaShift( 1 );
    else
        error( 'No solution found' )
    end
end