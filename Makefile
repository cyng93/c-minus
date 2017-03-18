
LL	= lex
CC = gcc
CFLAGS = -lfl

LEX = 0556513
OUT = scanner
TEST = helloworld all_pos integer_neg scientific_neg

all: $(OUT)
test: $(TEST)

%.yy.c: %.l 
	$(LL) -o $@ $<

$(OUT): $(LEX).yy.c
	$(CC) -o $@ $< $(CFLAGS)

clean:
	rm -f *~ *.yy.c $(OUT)

$(TEST):
	./scanner testcases/$@.c > test.output
	diff test.output testcases/$@.gold || true
	rm -f test.output
