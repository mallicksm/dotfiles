extern uint64 *kernel_pagetable;
extern int numpages;

struct spinlock;

void pteprint(uint64 *, int);
uint64 *walk(uint64 *, uint64, uint32, int);
int mappages(uint64 *, uint64, uint64, int, uint64, uint64);
void logprintf(char *, ...);

// kalloc.c
void *kalloc(void);
uint64 kinit(void);
void kfree (void *);
void kvminit (void);
int knumpages (void);

// spinlock.c
void acquire(struct spinlock *);
void release(struct spinlock *);
void initlock(struct spinlock *, char *);
