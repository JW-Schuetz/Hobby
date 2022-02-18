function [ chi1, chi2, chi3 ] = chi( rS, rE, lS, alpha, omega, thetaG, psi, mue0 )
    fak  = ( rE + lS ) * mue0 ;
    rho1 = fak * cos( thetaG - psi );
    rho2 = 0;
    rho3 = fak * sin( thetaG - psi );

    fak  = rS * ( 1 - mue0 );
    sig1 = sin( psi )^2 * cos( omega ) * ( 1 - cos( alpha ) ) + ...
           cos( omega ) * cos( alpha ) + ...
           cos( psi ) * sin( omega ) * sin( alpha );
    sig1 = fak * sig1;
    sig2 = -cos( psi ) * cos( omega ) * sin( alpha ) + ...
           sin( omega ) * cos( alpha );
    sig2 = fak * sig2;
    sig3 = cos( psi ) * sin( psi ) * cos( omega ) * ( 1 - cos( alpha ) ) - ...
           sin( psi ) * sin( omega ) * sin( alpha );
    sig3 = fak * sig3;

    chi1 = simplify( rho1 + sig1 );
    chi2 = simplify( rho2 + sig2 );
    chi3 = simplify( rho3 + sig3 );
end
