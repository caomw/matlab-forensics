#ifndef FARID_ALG_H
#define FARID_ALG_H

typedef struct {
	double	irgVal;	//IRG value
	int		gVal;	//Green intensity value at that IRG
	int		bVal;	//Blue intensity value at that IRG
} irgInfo;



///////////////////////////////
// Functions declarations

bool irgSortPredicat (irgInfo a,irgInfo b);


#endif // FARID_ALG_H