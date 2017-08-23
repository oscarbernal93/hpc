CC = gcc -std=c11

all: pollux mm mmo

pollux: pollux.c
	$(CC) -o pollux.o -c pollux.c

mm: mm.c
	$(CC) -o mm mm.c pollux.o

mmo: mmo.c
	$(CC)  -fopenmp -o mmo mmo.c pollux.o

clean:
	rm mm mmo
