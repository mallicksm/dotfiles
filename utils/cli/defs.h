struct spinlock;

// vm.c
void pteprint(uint64 *, int);
uint64 *walk(uint64 *, uint64, uint32, int);
int mappages(uint64 *, uint64, uint64, int, uint64, uint64);

// kalloc.c
void *kalloc(void);
uint64 kinit(void);
void kfree (void *);
void kvminit (void);
int knumpages (void);

// spinlock.c
void initlock(struct spinlock *, char *);
void acquire(struct spinlock *);
void release(struct spinlock *);

// strings.c
void *private_memset(void *, int, uint32);
#define memset private_memset
void private_printf(const char*, ...);
#define printf private_printf

void ot32(void);
void ct32(void);
void mwrt32(uint32, uint32);
void mrdt32(uint32);

extern uint64 *kernel_pagetable;

