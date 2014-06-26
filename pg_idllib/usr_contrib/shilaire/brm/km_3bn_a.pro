;Koch & Mott (1959) formula 3BN(b) for electron bremsstrahlung differential cross-section (Born approximation, ultra-relativistic limit, without screening effects).
;
;
; Ee is initial electron energy, Eph is emitted photon energy, both in keV.
;


FUNCTION km_3bn_a, Ee, Eph, z=z, mb=mb
	RETURN,betheheitler_brm_crosssection(Ee,Eph, z=z, mb=mb, /QUIET)
END

