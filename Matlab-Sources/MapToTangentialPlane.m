function [ x2, x3 ] = MapToTangentialPlane( x1, x2, x3, phi, theta )
    % Punkt drehen um x3-Achse um den Winkel phi
    if( phi ~= 0 )
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

    % Punkt drehen um x2-Achse und den Winkel theta
    if( theta ~= 0 )
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

    % Projizieren auf die Tangentialebene
    A = [ 0, 1, 0;
          0, 0, 1 ];

    x = A * [ x1; x2; x3 ];
    x2 = x( 1 );
    x3 = x( 2 );
end