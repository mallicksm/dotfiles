all:
	cc -g -Wall cli.c vm.c kalloc.c spinlock.c strings.c t32/hremote.c t32/hlinknet.c t32/t32nettcp.c t32/tcpsimple2.c t32.c -DT32HOST_LE -It32 -o cli
	./cli

clean:
	rm -rf cli

debug:
	gdb --tui ./cli 
