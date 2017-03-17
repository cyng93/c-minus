
LL	= lex
CC = gcc
CFLAGS = -lfl

LEX = 0556513
OUT = scanner

all: $(OUT)

%.yy.c: %.l 
	$(LL) -o $@ $<

$(OUT): $(LEX).yy.c
	$(CC) -o $@ $< $(CFLAGS)

clean:
	rm -f *~ *.yy.c $(OUT)
