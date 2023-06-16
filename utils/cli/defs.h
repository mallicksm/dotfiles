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
void initlock(struct spinlock *, char *);
void acquire(struct spinlock *);
void release(struct spinlock *);

// strings.c
void *private_memset(void *, int, uint32);
#define memset private_memset
void private_printf(const char*, ...);
#define printf private_printf

extern uint64 *kernel_pagetable;
