all:
	cc -std=c99 -g cli.c vm.c kalloc.c spinlock.c -o cli
	./cli

clean:
	rm -rf cli

debug:
	gdb --tui ./cli 
