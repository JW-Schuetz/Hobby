function [ sPlus, highNoon ] = steigung( alpha, psi, omega, offset )
% Steigung der Trajektorie und astronomischer Mittag
    A = -cos( psi )^2 * sin( alpha ) * cos( omega ) + ...
         cos( psi ) * cos( alpha ) * sin( omega );
    B = -cos( psi ) * sin( psi ) * sin( alpha ) * cos( omega ) + ...
         sin( psi ) * cos( alpha ) * sin( omega );
    C =  cos( psi ) * cos( alpha ) * cos( omega ) + ...
         sin( alpha ) * sin( omega );

	s     = ( sin( offset ) * A + cos( offset ) * B ) / C;
    sPlus = simplify(  s );

    highNoon = atan2( tan( omega ), cos( psi ) );
end