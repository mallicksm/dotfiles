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

//------------------------------------------------------------------------------
// perms
//  11 10      8      6  5        2  1   0
// +--+--+---+--+---+--+--+--+--+--+---+---+
// |nG|AF|  SH  |  AP  |NS|  IDXn  | T | V |
// +--+--+---+--+---+--+--+--+--+--+---+---+
// NS:      bit5: 0=Secure page, 1=not-secure page
// AP[0]:   bit6: 0=kernel, 1=user/kernel
// AP[1]:   bit7: 0=rw, 1=ro
// SH:    bit9:8: 0=not-shareable, 2=outer sharaeable, 3=inner shareable
// AF:     bit10: 1=normal, 0=exception
// nG:     bit11: 0=global applies to all asid, 1=not-global ASID specific 
// -----------------------------------------------------------------------------
#define AF 10
#define SH 8
#define AP 6
#define IDX 2
#define DEVICE (1<<AF)|(0x2<<SH)|(0x0<<AP)|(0x0<<IDX)
#define NORMAL (1<<AF)|(0x2<<SH)|(0x0<<AP)|(0x2<<IDX)
#define PTE_V (0x1ULL << 0)
#define PTE_T (0x1ULL << 1)
