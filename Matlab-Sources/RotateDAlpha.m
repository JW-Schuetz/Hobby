function [ x1, x2, x3 ] = RotateDAlpha( dAlpha, psi, x1, x2, x3, alpha )
    % Punkt um den Winkel alpha drehen um Erdrotations-Achse 
    if( alpha ~= 0 )
        dAlphaNumeric = eval( subs( dAlpha ) );

        x  = dAlphaNumeric * [ x1; x2; x3 ];

        x1 = x( 1 );
        x2 = x( 2 );
        x3 = x( 3 );
    end
end