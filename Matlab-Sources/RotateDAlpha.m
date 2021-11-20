function [ x1, x2, x3 ] = RotateDAlpha( DAlpha, x1, x2, x3, alfa )
    % Punkt um den Winkel alpha drehen um Erdrotations-Achse 
    if( alfa ~= 0 )
        DAlphaNumeric = eval( subs( DAlpha ) );

        x  = DAlphaNumeric * [ x1; x2; x3 ];

        x1 = x( 1 );
        x2 = x( 2 );
        x3 = x( 3 );
    end
end