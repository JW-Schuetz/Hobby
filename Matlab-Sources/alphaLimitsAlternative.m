function [ alphaPlus, alphaMinus ] = ...
                alphaLimitsAlternative( omegaS, alpha )
    % Alternative Lösung von: omegaS(alpha)=-1
    c = sym( 'c', 'real' );
    s = sym( 's', 'real' );

    % Zerlegung: omegaS(alpha)=z(alpha)/n
    [ z, n ] = numden( omegaS );

    % die Terme von z(alpha) mit sin(alpha) zusammenfassen
    z = collect( z, sin( alpha ) );

    % die Terme von z(alpha) mit cos(alpha) zusammenfassen
    z = collect( z, cos( alpha ) );

    % sin(alpha) und cos(alpha) durch s und c substituieren
    z = subs( z, sin( alpha ), s );
    z = subs( z, cos( alpha ), c );

    % Koeffizienten von s, c und dem konstanten Term finden
    a = simplify( coeffs( z, s ) ); a = a( 2 );
    b = simplify( coeffs( z, c ) ); b = b( 2 );
    c = simplify( z - a * s - b * c );
    c = c + n;

    % damit gilt: z(alpha)=a*sin(alpha)+b*cos(alpha)+c
    % zu lösen ist: z(alpha)=-n oder z(alpha)+n=0
    A = sym( 'A', 'real' );
    B = sym( 'B', 'real' );
    C = sym( 'C', 'real' );

    res = solve( A * sin( alpha ) + B * cos( alpha ) + C == 0, alpha, ...
                'real', true, 'ReturnConditions', true );

    alphaPlus  = res.alpha( 1 );
    alphaMinus = res.alpha( 2 );

    alphaPlus = subs( alphaPlus, 'A', 'a' );
    alphaPlus = subs( alphaPlus, 'B', 'b' );
    alphaPlus = subs( alphaPlus, 'C', 'c' );
    alphaPlus = subs( alphaPlus );

    alphaMinus = subs( alphaMinus, 'A', 'a' );
    alphaMinus = subs( alphaMinus, 'B', 'b' );
    alphaMinus = subs( alphaMinus, 'C', 'c' );
    alphaMinus = subs( alphaMinus );
end
