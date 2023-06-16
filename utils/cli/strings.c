#include <stdio.h>
#include <stdarg.h>

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
