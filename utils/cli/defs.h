void pteprint(uint64 *, int);
uint64 *walk(uint64 *, uint64, uint32, int);
int mappages(uint64 *, uint64, uint64, uint32, uint64, uint64);
uint64 *kalloc(void);
void logprintf(char *, ...);
extern uint64 pagetable[];
extern int numpages;
