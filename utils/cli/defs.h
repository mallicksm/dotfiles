extern uint64 pagetable[];
extern int numpages;

void pteprint(uint64 *, int);
uint64 *walk(uint64 *, uint64, uint32, int);
int mappages(uint64 *, uint64, uint64, int, uint64, uint64);
void logprintf(char *, ...);

// kalloc.c
uint64 *kalloc(void);
uint64 kinit(void);
void kfree (void *);
void kvminit (void);
int knumpages (void);
