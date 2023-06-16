#include "types.h"
#include "defs.h"
#include "vm.h"

uint64 *kernel_pagetable;

void pteprint(uint64 *pagetable, int level) {
#define _PINDENT 25
   if (level == 3) {
      for (int i = 0; i < PXMASK+1; i++) {
         if (pagetable[i] & (PTE_T | PTE_V)) {
            printf("%*s%d: pte=0x%p\n", (level-1)*_PINDENT, "", i, pagetable[i]);
         }
      }
   } else {
      uint64 *nextLevelTable;
      for (int i = 0; i < PXMASK+1; i++) {
         if ((pagetable[i] & PTE_T) && (pagetable[i] & PTE_V)) {
            printf("%*s%d: pte=0x%p\n", (level-1)*_PINDENT, "", i, pagetable[i]);
            nextLevelTable = (uint64 *)PAxPTE(pagetable[i]);
            pteprint(nextLevelTable, level + 1);
         } else if (pagetable[i] & PTE_V) {
            printf("%*s%d: blk=0x%p\n", (level-1)*_PINDENT, "", i, pagetable[i]);
         }
      }
   }
   printf("&pagetable[%d]=0x%p\n", level, pagetable);
}

uint64 *walk(uint64 *pagetable, uint64 va, uint32 levels, int alloc) {
   for (uint32 level = 0; level < levels; level++) {
      if (PXSHIFT(level) >= MAXVA)
         continue;

      uint64 *pte = &pagetable[PX(level,va)];
      if ((*pte & PTE_T) && (*pte & PTE_V)) {
         pagetable = (uint64 *)PAxPTE(*pte);
         printf("found table=%d numpages=%d pt=0x%p pte=0x%p\n", level, knumpages(),pte,*pte);
      } else if (*pte & PTE_V) {
         pagetable = (uint64 *)PAxPTE(*pte);
         printf("found block=%d numpages=%d pt=0x%p pte=0x%p\n", level, knumpages(),pte,*pte);
         return pagetable;
      } else {
         if (!alloc || (pagetable = kalloc()) == 0)
            return 0;
         *pte = PAxPTE((uint64)pagetable) | PTE_T | PTE_V;
         printf("alloc table=%d numpages=%d pt=0x%p pte=0x%p\n", level, knumpages(),pte,*pte);
      }
   }
done:
   return &pagetable[PX(levels, va)];
}

int mappages(uint64 *pagetable, uint64 va, uint64 pa, int level, uint64 size, uint64 perm) {
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

void kvmmap(uint64 *kpgtbl, uint64 va, uint64 pa, int level, uint64 size, uint64 perm) {
   if (mappages(kpgtbl, va, pa, level, size, perm) != 0) {
      printf("panic kvmmap\n");
      while(1);
   }
}

uint64 *kvmmake(void) {
   uint64 *kpgtbl;

   kpgtbl = (uint64 *)kalloc();
   memset(kpgtbl, 0, PGSIZE);
#if 1
   kvmmap(kpgtbl, 0ULL<<30, 0ULL<<30, 1, 1, DEVICE);
   kvmmap(kpgtbl, 1ULL<<30, 1ULL<<30, 1, 1, DEVICE);
   kvmmap(kpgtbl, 2ULL<<30, 2ULL<<30, 1, 1, DEVICE);
   kvmmap(kpgtbl, 3ULL<<30, 3ULL<<30, 1, 1, DEVICE);
   kvmmap(kpgtbl, 4ULL<<30, 4ULL<<30, 1, 1, NORMAL);
#endif
   return kpgtbl;
}

void kvminit(void) {
   kernel_pagetable = kvmmake();
}
