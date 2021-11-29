function SonnenkompassPlot()
    clc
    clear

    ort    = 'LasPalmas';
    datum  = '21.06.2021';

	switch( ort )
        case 'LasPalmas'
            switch datum
                case '12.10.2021'
                    arrowType  = '\downarrow';
                    yArrow     = 1.3;
                    yUhrZeit   = 1.4;
                    squareSize = 2;

                case '21.06.2021'
                    arrowType  = '\downarrow';
                    yArrow     = 0.3;
                    yUhrZeit   = 0.35;
                    squareSize = 1;

                case '21.12.2021'
                    arrowType  = '\uparrow';
                    yArrow     = 1.7;
                    yUhrZeit   = 1.4;
                    squareSize = 6;
            end
	end

    % Ergebnisdaten laden
    load( [ ort, '-', datum, '.mat' ], 'y' )

    % NaN-Elemente entfernen
    ndx = ~isnan( y( :, 2 ) );
    y   = y( ndx, : );

    % nach y( :, 2 ) aufsteigend sortieren
    [ ~, ndx ] = sort( y( :, 2 ) );
    y          = y( ndx, : );

    % evtl. doppelte Abszissenwerte entfernen
    [ ~, ndx ] = unique( y( :, 2 ) );
    y          = y( ndx, : );

    N = size( y, 1 );

    % Minimaler Abstand Stab <-> Schattenende
    [ minimum, minNdx ] = min( sqrt( y( :, 2 ).^2 + y( :, 3 ).^2 ) );
    minH                = y( minNdx, 2 ); % y1 des Minimums
    % y1-Achse verschieben um minH, d.h. Minimum ist damit bei y1=0 und
    % lineare Interpolation der y2-Werte
	y( :, 3 ) = interp1( y( :, 2 ), y( :, 3 ), y( :, 2 ) + minH );

    sprintf( 'Minimum des Abstandes zum Stab: %1.4f', minimum )

    figure
    title( 'Schattentrajektorie' )
    hold( 'on' )
    box( 'on' )
    grid( 'on' )
    axis( 'equal' )
    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Darstellungsbereich in Metern
    xlim( squareSize * [ -1,   1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r' )
    % Schatten-Trajektorie plotten, Markerindizes zentrisch ausrichten
    if( minNdx ~= 0 )
        mndx = [ minNdx : -10 : 1, minNdx + 10 : 10 : N ];
    else
        mndx = 1 : 10 : N;
    end
    plot( y( :, 2 ), y( :, 3 ), '-o', 'MarkerSize', 3, 'MarkerIndices', mndx, ...
        'Color', 'k', 'LineWidth', 1 )
    % Markierung 12 Uhr
	text( 0, yArrow, arrowType, 'HorizontalAlignment', 'center' )
	text( 0, yUhrZeit, '12:00 Uhr', 'HorizontalAlignment', 'center' )

    legend( 'Stabposition', 'Trajektorie, 10 Minuten-Intervalle' )
end