all: malloc

malloc: malloc.o
	ld malloc.o -o malloc -g

malloc.o: malloc.s
	as malloc.s -o malloc.o -g

clean:
	rm -f malloc.o malloc
