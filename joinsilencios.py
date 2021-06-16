#!/bin/env python3

import numpy as np
import click

DESCARTTRH=0.3
FPS=24

@click.command()
@click.argument('entrada')
@click.argument('salida')
@click.option('--fps',default=FPS,type=int)
@click.option('--threshold',default=DESCARTTRH,type=float)
def purge_silencios(entrada,salida,fps,threshold):
    with open(entrada,'r') as f:
        lineas = f.readlines()

    ar = np.array([*map(lambda x: [*map(float,x.strip().split())],lineas)])

    largos = ar[1:,0]-ar[:-1,1]
    mask1 = [False,*(largos < threshold)]
    mask0 = [*(largos < threshold),False]

    ar[mask0,1] = np.nan
    ar[mask1,0] = np.nan

    itt = iter(ar.copy())

    ar2 = []

    #i = next(itt)
    i = np.array([0,0],dtype=float)
    while True:

        while np.isnan(i[1]):
            i[1] = next(itt)[1]

        c = i #c for candidate

        try: i = next(itt)
        except StopIteration:
            ar2.append(c)
            break

        if abs(i[0]-c[1]) < (3./fps):
            i[0] = c[0]
        else:
            ar2.append(c)

    with open(salida,'w') as f:
        for i,j in ar2:
            print('{:.5f} {:.5f}'.format((i-(i % (1./fps))),(j-(j % (1./fps)))),file=f)

if __name__ == '__main__':
    purge_silencios()
