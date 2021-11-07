function [ x2, x3 ] = Maptangential( x1, x2, x3, phi, theta )
    % Punkt drehen um x3-Achse um den Winkel phi
    D = [ cos( phi ), -sin( phi ), 0;
          sin( phi ),  cos( phi ), 0;
          0,           0,          1 ];

    x = D * [ x1; x2; x3 ];
	x1 = x( 1 );
    x2 = x( 2 );
    x3 = x( 3 );

    % Punkt drehen um x2-Achse und den Winkel theta
    D = [  cos( theta ), 0, sin( theta );
           0,            1, 0;
          -sin( theta ), 0, cos( theta ) ];

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
