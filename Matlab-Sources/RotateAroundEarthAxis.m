function [ x1, x2, x3 ] = RotateAroundEarthAxis( x1, x2, x3, psi, alpha )
    % Punkt um den Winkel alpha drehen um Erdrotations-Achse 
    if( alpha ~= 0 )
        cp = cos( psi );
        sp = sin( psi );
        ca = cos( alpha );
        sa = sin( alpha );

        D = [ sp^2 * ( 1 - ca ) + ca, -cp * sa,  sp * cp * ( 1 - ca );
              cp * sa,                 ca,      -sp * sa;
              cp * sp * ( 1 - ca ),    sp * sa,  cp^2 * ( 1 - ca ) + ca ];

        x = D * [ x1; x2; x3 ];
        x1 = x( 1 );
        x2 = x( 2 );
        x3 = x( 3 );
    end
end