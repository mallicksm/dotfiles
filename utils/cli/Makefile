all:
	cc -std=c99 -g cli.c vm.c kalloc.c -o cli
	./cli

clean:
	rm -rf cli

debug:
	gdb --tui ./cli 
