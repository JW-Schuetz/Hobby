function [ x2, x3 ] = Maptangential( x1, x2, x3, alpha, psi, phi, theta )
    if( alpha ~= 0 )
        % Punkt drehen um Erdrotations-Achse um den Winkel alpha
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

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0;
          0, 0, 1 ];

    x = A * [ x1; x2; x3 ];
    x2 = x( 1 );
    x3 = x( 2 );
end