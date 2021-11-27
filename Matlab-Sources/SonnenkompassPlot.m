function SonnenkompassPlot()
    clc
    clear

    % Ergebnisdaten laden
    load( 'LasPalmas-12.10.2021.mat', 'y' )

    % Aufräumen
    ndx = ~isnan( y( :, 2 ) );
    y   = y( ndx, : );

    N = size( y, 1 );

%     minAbstand = min( sqrt( y( :, 2 ).^2 + y( :, 3 ).^2 ) )

    figure
    title( 'Schattentrajektorie' )
    hold( 'on' )
    box( 'on' )
    grid( 'on' )
    axis( 'equal' )
    xlabel( 'West-Ost [m]' )
    ylabel( 'Süd-Nord [m]' )

    % Darstellungsbereich in Metern
    squareSize = 6;     % [m]
    xlim( squareSize * [ -1, 1 ] );
    ylim( squareSize * [ -0.1, 1 ] );

    % Ort des Stabes plotten
    plot( 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r' )
    % Schatten-Trajektorie plotten
    mndx = 1 : 10 : N;
    plot( y( :, 2 ), y( :, 3 ), '-o', 'MarkerSize', 3, 'MarkerIndices', mndx, ...
        'Color', 'k', 'LineWidth', 1 )
    % Markierung 12 Uhr
	text( 0, 1.7, '\uparrow', 'HorizontalAlignment', 'center' )
	text( 0, 1.3, '12:00 Uhr', 'HorizontalAlignment', 'center' )

    legend( 'Stabposition', 'Trajektorie, 10 Minuten-Intervalle' )
end