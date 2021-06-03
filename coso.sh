#!/bin/bash

mkfifo sarasa.dat

cat sarasa.dat | awk 'BEGIN{sil=0}; /;/{next};
                        sqrt($2 ** 2)<0.005 {if (sil==0) {comienzo=$1};sil=1};
 												sqrt($2 ** 2)>=0.005 {if (sil==1) 
																								{fin=$1;
                                                 if ((fin - comienzo) > 0.5)
																										{print comienzo,fin};
                                                sil=0
                                                }};' > $2 &

sox $1 sarasa.dat

rm sarasa.dat
