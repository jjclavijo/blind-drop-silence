#!/bin/bash

VOLUMETHR=0.15
VOLUMEDUR=0.3

mkfifo tmpfifo.dat

cat tmpfifo.dat | awk 'BEGIN{sil=0}; /;/{next};
                        sqrt($2 ** 2)<'$VOLUMETHR' {if (sil==0) {comienzo=$1};sil=1};
 												sqrt($2 ** 2)>='$VOLUMETHR' {if (sil==1) 
																								{fin=$1;
                                                 if ((fin - comienzo) > '$VOLUMEDUR')
																										{print comienzo,fin};
                                                sil=0
                                                }};' > $2 &

sox $1 tmpfifo.dat

rm tmpfifo.dat
