#include "types.h"
#include "vm.h"
__attribute((aligned(PGSIZE))) uint64 pagetable[(PGSIZE>>3) * 10];

int numpages = 1;
uint64 *kalloc(void) {
   return &pagetable[(PGSIZE>>3) * numpages++];
}
