#!/bin/env python3

import click

@click.command()
@click.argument('infile')
@click.argument('outfile')
def purge(infile,outfile):
    dic = {}
    with open(infile) as f:
        lineas = f.readlines()
    for i in lineas:
        v,k = i.strip().split()
        dic[k]=v
    with open(outfile,'w') as f:
        for k,v in dic.items():
            if v == 'file':
                print(f'file {k}',file=f)

if __name__ == '__main__':
    purge()
