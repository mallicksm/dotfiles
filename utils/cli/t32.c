#include <stdio.h>
#include "t32.h"
#include "types.h"

void ot32() {
   uint32 rev;
   int dstate;
   int retries = 0;
retryit:
   retries++;
   T32_Config("NODE=", "10.1.12.138");
   T32_Config("PORT=", "20000");

   if (T32_Init() == -1) {
      printf("Error initializing TRACE32\n");
      T32_Exit();
      if (retries < 2) {
         goto retryit;
      }
      return;
   }

   if (T32_Attach(T32_DEV_ICD) != 0) {
      T32_Exit();
      T32_Init();
      if (T32_Attach(T32_DEV_ICD) != 0) {
         printf("Failure to connect to Trace32. Terminating\n");
         return;
      }
   }

   T32_Printf("Info: CLI taking over\n");
   T32_GetState(&dstate);
   T32_GetApiRevision(&rev);
   printf("Welcome to t32cli v%d CPU(%d)\n",rev, dstate);
   printf("   Supported functions:\n");
   printf("      ot32     -Open TRACE32\n");
   printf("      mrdt32   -Read 32Bit Address via TRACE32\n");
   printf("      mwrt32   -Write 32Bit Address with 32Bit Data via TRACE32\n");
   printf("      ct32     -Close TRACE32\n");
}

void ct32() {
   T32_Exit();
}
void mwrt32(uint32 address, uint32 data) {
   int nb = 4;
   unsigned char *buffer = (unsigned char *)&data;
   T32_WriteMemory(address, 0, buffer, nb);
}
void mrdt32(uint32 address) {
   int nb = 4;
   uint32 *ptr;
   unsigned char buffer[nb];
   T32_ReadMemory(address, 0, buffer, nb);
   ptr = (uint32 *)buffer;
   printf("0x%08x\n",*ptr);
}
