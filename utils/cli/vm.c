#include "types.h"
#include "defs.h"
#include "vm.h"

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
            nextLevelTable = (uint64 *)PAxPTE(pagetable[i]);
            pteprint(nextLevelTable, level + 1);
         } else if (pagetable[i] & PTE_V) {
            printf("%*s%d: blk=0x%016llx\n", (level-1)*_PINDENT, "", i, pagetable[i]);
         }
      }
   }
   printf("&pagetable[%d]=0x%016llx\n", level, pagetable);
}

uint64 *walk(uint64 *pagetable, uint64 va, uint32 levels, int alloc) {
   for (uint32 level = 0; level < levels; level++) {
      if (PXSHIFT(level) >= MAXVA)
         continue;

      uint64 *pte = &pagetable[PX(level,va)];
      if ((*pte & PTE_T) && (*pte & PTE_V)) {
         pagetable = (uint64 *)PAxPTE(*pte);
         logprintf("found table=%d numpages=%d pt=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
      } else if (*pte & PTE_V) {
         pagetable = (uint64 *)PAxPTE(*pte);
         logprintf("found block=%d numpages=%d pt=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
         return pagetable;
      } else {
         if (!alloc || (pagetable = kalloc()) == 0)
            return 0;
         *pte = PAxPTE((uint64)pagetable) | PTE_T | PTE_V;
         logprintf("alloc table=%d numpages=%d pt=0x%016llx pte=0x%016llx\n", level, numpages,pte,*pte);
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
      if ((pte = walk(pagetable, a, level, 1)) == 0) {
         printf("Jacked\n");
         return -1;
      }
      if (*pte & PTE_V) {
         printf("Mapped\n");
         return -1;
      }
      if (level == 3) {
         *pte = PAxPTE(pa) | perm | PTE_T | PTE_V;
      } else {
         *pte = PAxPTE(pa) | perm | PTE_V;
      }
      if (a == last) {
         goto done;
      }
      a += PGSIZE;
      pa += PGSIZE;
   }
done:
   return 0;
}

