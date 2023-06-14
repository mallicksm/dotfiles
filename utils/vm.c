#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define uint32 unsigned int
#define uint64 unsigned long long

#define MAXVA 39
#define TG 12                                                // 12|14|16

#define PGSIZE           (1 << (TG))                         // 4096
#define PXMASK           ((1 << (TG-3)) - 1)                 // 0x1ff
#define PXSHIFT(level)   (TG + ((TG-3) * (3 - level)))       // 12 + 9*(3-level)
#define PX(level, va)    ((va >> PXSHIFT(level)) & PXMASK)   // level mask
#define PTE2PA(pte)      (pte & ~(PGSIZE-1))
#define PA2PTE(pa)       (pa & ~(PGSIZE-1))

#define GPGSIZE(l)       (1 << ((TG)+((TG)-3)*(3-(l))))      // 4K=[9, 9, 9,12], 16K=[11,11,11,14], 64K=[13,13,13,16]
#define PGROUNDDOWN(a,l) ((a) & ~(GPGSIZE(l) - 1))
#define PGROUNDUP(a,l)   (((a) + GPGSIZE(l) - 1) & ~(GPGSIZE(l) - 1))

#define PTE_V (0x1ULL << 0)
#define PTE_T (0x1ULL << 1)

__attribute((aligned(4096))) uint64 pagetable[512 * 10];
int numpages = 1;

uint64 *kalloc(void) {
   return &pagetable[512 * numpages++];
}

void pteprint(uint64 *pagetable, int level) {
#define _PINDENT 25
   if (level == 3) {
      for (int i = 0; i < PXMASK+1; i++) {
         if (pagetable[i] & (PTE_T | PTE_V)) {
            printf("%*s%d: pte=0x%016llx\n", (level-1)*_PINDENT, "", i, pagetable[i]);
         }
      }
   } else {
      uint64 *nextLevelTable;
      for (int i = 0; i < PXMASK+1; i++) {
         if ((pagetable[i] & PTE_T) && (pagetable[i] & PTE_V)) {
            printf("%*s%d: pte=0x%016llx\n", (level-1)*_PINDENT, "", i, pagetable[i]);
            nextLevelTable = (uint64 *)PTE2PA(pagetable[i]);
            pteprint(nextLevelTable, level + 1);
         } else if (pagetable[i] & PTE_V) {
            printf("%*s%d: blk=0x%016llx\n", (level-1)*_PINDENT, "", i, pagetable[i]);
         }
      }
   }
}

uint64 *walk(uint64 *pagetable, uint64 va, uint32 levels) {
   for (uint32 level = 0; level < levels; level++) {
      if (PXSHIFT(level) >= MAXVA)
         continue;

      uint64 *pte = &pagetable[PX(level,va)];
      if ((*pte & PTE_T) && (*pte & PTE_V)) {
         pagetable = (uint64 *)PTE2PA(*pte);
         printf("found table=%d numpages=%d &pte=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
      } else if (*pte & PTE_V) {
         pagetable = (uint64 *)PTE2PA(*pte);
         printf("found block=%d numpages=%d &pte=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
         goto done;
      } else {
         pagetable = kalloc();
         if ((levels==2 && level==2) || (levels==1 && level==1)) {
            *pte = PA2PTE((uint64)pagetable) | PTE_V;
            printf("block level=%d numpages=%d &pte=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
         } else {
            *pte = PA2PTE((uint64)pagetable) | PTE_T | PTE_V;
            printf("table level=%d numpages=%d &pte=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
         }
      }
   }
done:
   return &pagetable[PX(levels, va)];
}

int mappages(uint64 *pagetable, uint64 va, uint64 pa, uint32 level, uint64 size, uint64 perm) {
   uint64 *pte;
   uint64 a = PGROUNDDOWN(va, level);
   uint64 last = PGROUNDDOWN(va+size-1, level);
   while (1) {
      if ((pte = walk(pagetable, a, level)) == 0) {
         printf("Jacked\n");
         return -1;
      }
      if (*pte & PTE_V) {
         printf("Mapped\n");
         return -1;
      }
      *pte = PA2PTE(pa) | perm | PTE_T | PTE_V;
      if (a == last) {
         goto done;
      }
      a += PGSIZE;
      pa += PGSIZE;
   }
done:
   pteprint(pagetable, 1);
   return 0;
}

int pteprint_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   pteprint(pagetable, 1);
   printf("pagetable=0x%016llx\n", pagetable);
   return 0;
}

int mappages_cli(int argc, char** argv) {
   uint64 pa;
   uint64 va;
   uint64 pages;
   int levels;
   if (argc < 2) {
      va = 0;
      pages = 1;
      levels = 3;
   } else if (argc < 3) {
      va = strtol(argv[1], NULL, 0);
      pages = 1;
      levels = 3;
   } else if (argc < 4) {
      va = strtol(argv[1], NULL, 0);
      pages = strtol(argv[2], NULL, 0);
      levels = 3;
   } else {
      va = strtol(argv[1], NULL, 0);
      pages = strtol(argv[2], NULL, 0);
      levels = strtol(argv[3], NULL, 0);
   }
   mappages(pagetable, va, (0x1234ULL << 32), levels, pages*4096, 0x5bULL<<(14*4));
   return 0;
}

int test_cli(int argc, char** argv) {
   (void)argc;
   uint64 va = strtol(argv[1], NULL, 0);
   for (int l = 0; l < 4; l++) {
      printf("PgRoundUp   l=%d: 0x%016llx\n", l, PGROUNDUP(va,l));
      printf("PgRoundDown l=%d: 0x%016llx\n", l, PGROUNDDOWN(va,l));
   }
}

int mrd_cli(int argc, char** argv) {
   if (argc != 2) {
      printf("Please provide 1 argument\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = *(volatile uint64 *)addr;
   printf("Mem[0x%016llx] => 0x%016llx\n",addr, data);
   return 0;
}

int mwr_cli(int argc, char** argv) {
   if (argc != 3) {
      printf("Please provide 2 arguments\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = strtol(argv[2], NULL, 0);
   *(volatile uint64 *)addr = data;
   printf("Mem[0x%016llx] <= 0x%016llx\n",addr, data);
   return 0;
}

int help_cli(int argc, char** argv) {
   printf("mappages va pages pa levels\n");
   printf("pteprint\n");
   printf("mrd/mwr\n");
   printf("help\n");
   return 0;
}

struct cmd_t {
   int last;
   char *cmd;
   int (*func)(int, char **);
};

static struct cmd_t cmd_table[] = {
   {
      .cmd = "help",
      .func = help_cli,
   }, 
   {
      .cmd = "mrd",
      .func = mrd_cli,
   }, 
   {
      .cmd = "mwr",
      .func = mwr_cli,
   }, 
   {
      .cmd = "test",
      .func = test_cli,
   }, 
   {
      .cmd = "mappages",
      .func = mappages_cli,
   }, 
   {
      .cmd = "pteprint",
      .func = pteprint_cli,
   }, 
   {
      .last = 1,
   }
};

struct {
#define INPUT_BUF 128
   char buf[INPUT_BUF];
} cons;

void exec (void) {
   char *argv[30];
   while (1) {
      int argc = 0;
      printf(">> ");
      fgets(cons.buf, sizeof(cons.buf), stdin);

      // create argc argv
      argv[argc++] = cons.buf;
      int i;
      for (i = 0; cons.buf[i] != '\n'; i++) {
         if (cons.buf[i] == ' ') {
            cons.buf[i] = '\0';
            argv[argc++] = &cons.buf[i+1];
         }
      }
      cons.buf[i] = '\0';

      // execute func(argc, argv);
      i = 0;
      int legal_cmd = 0;
      while (!cmd_table[i].last) {
         if (strcmp(argv[0], cmd_table[i].cmd) == 0) {
            uint32 rc = cmd_table[i].func(argc, argv);
            printf("rc=%d\n",rc);
            legal_cmd = 1;
         }
         i++;
      }
      if (strncmp(argv[0], "q", 2) == 0) {
         return;
      }
      if (!legal_cmd) {
         printf("Illegal command, try again\n");
      }
   }
}

int main () {
   exec();
   return 0;
}
