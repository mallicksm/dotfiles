#include <stdio.h>
#include <stdarg.h>
#include "types.h"

void *private_memset(void *dst, int c, uint32 n) {
   uint64 p = (uint64)c & 0xff;
   uint64 *dwdst = (uint64 *)dst;
   uint64 bmsk = (0xffffffffffffffff << (((uint64)dwdst & 0x7) * 8));
   uint64 emsk = ~((0xffffffffffffffff << ((((uint64)dwdst + n) & 0x7) * 8)));
   uint64 pat = (p << 8 * 7) | (p << 8 * 6) | (p << 8 * 5) | (p << 8 * 4) | (p << 8 * 3) | (p << 8 * 2) | (p << 8 * 1) | (p << 8 * 0);

   /* First word iff n fit in 8Bytes */
   if ((((uint64)dst) >> 3) == ((uint64)dst + n) >> 3) {
      dwdst[0] = (pat & (bmsk & emsk)) | (dwdst[0] & ~(bmsk & emsk));
      return dst;
   }

   /* Align dst by filling in bytes */
   dwdst[0] = (pat & bmsk) | (dwdst[0] & ~bmsk);
   uint32 i = 1;
   uint32 nq = n >> 3;

   /* Fill words */
   while (i < nq) {
      dwdst[i++] = pat;
   }

   /* Mop up trailing bytes, if any */
   if ((n & 0x7) != 0) {
      dwdst[i] = (pat & emsk) | (dwdst[i] & ~emsk);
   }
   return dst;
}

void private_printf(const char* format, ...) {
   va_list args;
   va_start(args, format);

   char modified_format[256];  // Buffer to store modified format string
   const char* p = format;
   char* m = modified_format;

   while (*p) {
      if (*p == '%' && *(p + 1) == 'p') {
         *m++ = '%';
         *m++ = '0';
         *m++ = '1';
         *m++ = '6';
         *m++ = 'l';
         *m++ = 'l';
         *m++ = 'x';
         p++;  // Skip 'p' in the original format
      } else {
         *m++ = *p;
      }
      p++;
   }

   *m = '\0';  // Null-terminate the modified format string

   vprintf(modified_format, args);

   va_end(args);
}
