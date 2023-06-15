#define TG 12                                             // 12|14|16
#define MAXVA            ((TG) + 3*((TG)-3))              // 4K=[9+9+9+12], 16K=[11+11+11+14], 64K=[13+13+13+16]

#define PGSIZE           (1 << (TG))                      // 4K=0x1000, 16K=0x4000, 64K=0x10000
#define PXMASK           ((1 << ((TG)-3)) - 1)            // 4K=0x1ff, 16K=0x7ff, 64K=0x1fff
#define PXSHIFT(level)   (TG + (((TG)-3) * (3 - level)))  // 4K=[12 + 9*(3-level)], 16K=[14 + 11*(3-level)], 64K=[16 + 13*(3-level)]

#define PX(level, va)    (((va) >> PXSHIFT(level)) & PXMASK)
#define PAxPTE(a)        ((a) & ~(PGSIZE-1))

#define LPGSIZE(l)       (1 << ((TG)+((TG)-3)*(3-(l))))   // 4K=[9,9,9,12], 16K=[11,11,11,14], 64K=[13,13,13,16]
#define PGROUNDDOWN(a,l) ((a) & ~(LPGSIZE(l) - 1))
#define PGROUNDUP(a,l)   (((a) + LPGSIZE(l) - 1) & ~(LPGSIZE(l) - 1))

#define PTE_V (0x1ULL << 0)
#define PTE_T (0x1ULL << 1)
