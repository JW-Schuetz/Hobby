function SonnenkompassPlot()
    % Ergebnisdaten laden
    load( 'LasPalmas-12.10.2021.mat', 'y', 'abstand' )

    % sicherstellen, dass Datenlänge ungerade ist
    N = size( y, 1 );
    if( mod( N, 2 ) == 0 )  % N gerade?
        y( end )       = [];
        abstand( end ) = [];
    end

    % Daten so verschieben, dass der minimale Abstand zum Stab im
    % Mittelelement des Datensatzes ist. Die Zeit in Minuten ist ndx - 1.
    [ minAbstand, ndx ] = min( abstand );

    %         ... mitte ...
    % 1, 2, ..., (N+1)/2, ..., N
    mitte   = ( N + 1 ) / 2;
    shift   = mitte - ndx;
    y       = circshift( y, shift );

    sprintf( 'Minimaler Abstand: %1.4f m', minAbstand )

    figure
    title( 'Schattentrajektorie' )
    hold 'on'
    box 'on'
    grid 'on'
    axis( 'equal' )
    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Darstellungsbereich in Metern
    squareSize = 2;     % [m]
    xlim( squareSize * [ -1, 1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r' )
    % Schatten-Trajektorie plotten
    mndx = 1 : 20 : mitte;
    plot( y( :, 1 ), y( :, 2 ), '-o', 'MarkerSize', 3, 'MarkerIndices', mndx, ...
        'Color', 'k', 'LineWidth', 1 )
    % Markierung 12 Uhr
	text( 0, 1.7, '\uparrow', 'HorizontalAlignment', 'center' )
	text( 0, 1.5, '12:00 Uhr', 'HorizontalAlignment', 'center' )

    legend( 'Stabposition', 'Trajektorie, 10 Minuten-Intervalle' )
end