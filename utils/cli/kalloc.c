#include "types.h"
#include "vm.h"
#include "defs.h"
#include "spinlock.h"

#define NUMPHYPAGES 10
__attribute((aligned(PGSIZE))) static char physmem[PGSIZE * NUMPHYPAGES];

struct run {
   struct run *next;
};

static struct {
   struct spinlock lock;
   struct run *freelist;
   int numpages;
} kmem;

void kfree (void *pa) {
   struct run *r;

   r = (struct run *)pa;
   acquire(&kmem.lock);
   r->next = kmem.freelist;
   kmem.freelist = r;
   kmem.numpages--;
   release(&kmem.lock);
}

static void freerange(void *pa_start, void *pa_end) {
   char *p;

   p = (char *)PGROUNDUP((uint64)pa_start, 3);
   for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
      kfree(p);
}

uint64 kinit(void) {
   initlock(&kmem.lock, "kmem");
   freerange((void *)&physmem[0], (void *)&physmem[PGSIZE*NUMPHYPAGES]);
   kmem.numpages = 0;
   return (uint64)&kmem;
}

void *kalloc(void) {
   struct run *r;

   acquire(&kmem.lock);
   r = kmem.freelist;
   if (r) {
      kmem.freelist = r->next;
      kmem.numpages++;
   }
   release(&kmem.lock);
   return (void *)r;
}
int knumpages(void) {
   return kmem.numpages;
}
