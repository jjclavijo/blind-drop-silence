#!/bin/env python3

import numpy as np
import click

@click.command()
@click.argument('entrada')
@click.argument('salida')
def purge_silencios(entrada,salida):
    with open(entrada,'r') as f:
        lineas = f.readlines()

    ar = np.array([*map(lambda x: [*map(float,x.strip().split())],lineas)])

    largos = ar[1:,0]-ar[:-1,1]
    mask1 = [False,*(largos < 0.3)]
    mask0 = [*(largos < 0.3),False]

    ar[mask0,1] = np.nan
    ar[mask1,0] = np.nan

    itt = iter(ar.copy())

    ar2 = []
    for i in itt:
        while np.isnan(i[1]):
            i[1] = next(itt)[1]
        ar2.append(i)

    with open(salida,'w') as f:
        for i,j in ar2:
            print('{:.5f} {:.5f}'.format((i-(i % (1./24.))),(j-(j % (1./24.)))),file=f)

if __name__ == '__main__':
    purge_silencios()
