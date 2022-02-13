function [ alphaPlus, alphaMinus ] = alphaLimits( rS, rE, p1, p3, psi, omega )
% Limits für den Erdrotationswinkel alpha (Tageszeit)
% Die hier benutzten Formeln werden in "SonnenKompassSymbolicAddon.m"
% verfifiziert.

	as = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) ...
            * sin( omega );
    bs = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) * cos( psi ) ...
            * cos( omega );
    cs = rE^2 - rS * ( p1 * sin( psi )^2 + p3 * cos( psi ) * sin( psi ) ) ...
            * cos( omega );

    wurzel  = sqrt( as^2 + bs^2 - cs^2 );
    nenner  = bs - cs;
    zPlus   = as + wurzel;
    zMinus  = as - wurzel;

    alphaPlus  = 2 * atan2( zPlus,  nenner );
    alphaMinus = 2 * ( atan2( zMinus, nenner ) + pi );
end
