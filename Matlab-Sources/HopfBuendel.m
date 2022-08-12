function HopfBuendel()
    clc
    clear

    a  = sym( 'a', 'real' );
    b  = sym( 'b', 'real' );
    c  = sym( 'c', 'real' );
    d  = sym( 'd', 'real' );

    M = [ 1 + a^2 / c^2, a * b / c^2;
	      a * b / c^2,   1 + b^2 / c^2 ];

    [ q, r ] = qr( M );
    simplify( q )
    simplify( r )
    simplify( M - q * r )

    M = subs( M, a, 5 );
    M = subs( M, b, -2 );
    M = subs( M, c, 39 );

    [ W, D ] = eig( M );

    simplify( M - W * D * inv( W ) ) %#ok<MINV>

    [ U, S, V ] = svd( M );

    simplify( U - V ) 

    simplify( M - U * S * V' ) 
end