CC = gcc -std=c11

all: mm mmo

mm: mm.c
	$(CC) -o mm mm.c

mmo: mmo.c
	$(CC) -o mmo mmo.c

clean:
	rm mm mmo
