

FUNCTION gamma2beta,gamma
	g=DOUBLE(gamma)
	RETURN, (1-g^(-2))^0.5
END
