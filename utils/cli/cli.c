#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "types.h"
#include "defs.h"
#include "vm.h"
#include "macros.h"

#define FUNCTION_LIST \
   X(ot32, - Open Trace32) \
   X(ct32, - Close Trace32) \
   X(kvminit, - Initialize boot page table) \

#define X(name, comment) CLI_FUNCTION(name, comment)
   FUNCTION_LIST
#undef X

int kinit_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;

   uint64 ip = kinit();
   printf("ip=0x%p\n", ip);
   return 0;
}
int kalloc_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   void *pa = kalloc();
   printf("pa=0x%p\n", pa);
   return 0;
}
int kfree_cli(int argc, char** argv) {
   (void)argc;
   if (argc < 2) {
      printf("1 arg needed\n");
      return 1;
   }
   uint64 pa = strtol(argv[1], NULL, 0);
   kfree((void *)pa);
   return 0;
}
int pteprint_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   printf("kernel_pagetable = 0x%p\n", kernel_pagetable);
   pteprint(kernel_pagetable, 1);
   return 0;
}

int mappages_cli(int argc, char** argv) {
   uint64 va;
   uint64 pages;
   int levels;
   if (argc < 2) {
      va = 0;
      pages = 1;
      levels = 3;
   } else if (argc < 3) {
      va = strtol(argv[1], NULL, 0);
      pages = 1;
      levels = 3;
   } else if (argc < 4) {
      va = strtol(argv[1], NULL, 0);
      pages = strtol(argv[2], NULL, 0);
      levels = 3;
   } else {
      va = strtol(argv[1], NULL, 0);
      pages = strtol(argv[2], NULL, 0);
      levels = strtol(argv[3], NULL, 0);
   }
   return mappages(kernel_pagetable, va, 0x123456789a000ULL+va, levels, pages*PGSIZE, 0x5bULL<<(14*4));
}

int mwrt32_cli(int argc, char** argv) {
   if (argc < 3) {
      printf("Provide 2 args\n");
      return -1;
   }
   uint32 addr = strtol(argv[1], NULL, 0);
   uint32 data = strtol(argv[2], NULL, 0);
   mwrt32(addr, data);
   return 0;
}

int mrdt32_cli(int argc, char** argv) {
   if (argc < 2) {
      printf("Provide 1 args\n");
      return -1;
   }
   uint32 addr = strtol(argv[1], NULL, 0);
   mrdt32(addr);
   return 0;
}

int mrd_cli(int argc, char** argv) {
   if (argc != 2) {
      printf("Please provide 1 argument\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = *(volatile uint64 *)addr;
   printf("Mem[0x%p] => 0x%p\n",addr, data);
   return 0;
}

int mwr_cli(int argc, char** argv) {
   if (argc != 3) {
      printf("Please provide 2 arguments\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = strtol(argv[2], NULL, 0);
   *(volatile uint64 *)addr = data;
   printf("Mem[0x%p] <= 0x%p\n",addr, data);
   return 0;
}

int help_cli(int argc, char** argv) {
   printf("   mrd/mwr  <va>        \t-read/write memory\n");
   printf("   kinit                \t-kernel allocator init\n");
   printf("   kalloc               \t-kalloc a page\n");
   printf("   mappages [va|pg|lvl] \t-map va #pages of size #levels\n");
   printf("   kfree <pa>           \t-kfree a page\n");
   printf("   pteprint             \t-print pagetable\n");
#define X(name, comment) CLI_HELP(name, comment)
   FUNCTION_LIST
#undef X
   return 0;
}

struct cmd_t {
   int last;
   char *cmd;
   int (*func)(int, char **);
};

static struct cmd_t cmd_table[] = {
   {
      .cmd = "help",
      .func = help_cli,
   }, 
   {
      .cmd = "mrd",
      .func = mrd_cli,
   }, 
   {
      .cmd = "mwr",
      .func = mwr_cli,
   }, 
   {
      .cmd = "mwrt32",
      .func = mwrt32_cli,
   }, 
   {
      .cmd = "mrdt32",
      .func = mrdt32_cli,
   }, 
   {
      .cmd = "mappages",
      .func = mappages_cli,
   }, 
   {
      .cmd = "pteprint",
      .func = pteprint_cli,
   }, 
   {
      .cmd = "kinit",
      .func = kinit_cli,
   }, 
   {
      .cmd = "kalloc",
      .func = kalloc_cli,
   }, 
   {
      .cmd = "kfree",
      .func = kfree_cli,
   }, 
#define X(name, comment) CLI_ALIASES(name, comment)
   FUNCTION_LIST
#undef X
   {
      .last = 1,
   }
};

struct {
#define INPUT_BUF 128
   char buf[INPUT_BUF];
} cons;

void exec (void) {
   char *argv[30];
   while (1) {
      int argc = 0;
      printf(">> ");
      fgets(cons.buf, sizeof(cons.buf), stdin);

      // create argc argv
      argv[argc++] = cons.buf;
      int i;
      for (i = 0; cons.buf[i] != '\n'; i++) {
         if (cons.buf[i] == ' ') {
            cons.buf[i] = '\0';
            argv[argc++] = &cons.buf[i+1];
         }
      }
      cons.buf[i] = '\0';

      // execute func(argc, argv);
      i = 0;
      int legal_cmd = 0;
      while (!cmd_table[i].last) {
         if (strcmp(argv[0], cmd_table[i].cmd) == 0) {
            uint32 rc = cmd_table[i].func(argc, argv);
            printf("rc=%d\n",rc);
            legal_cmd = 1;
         }
         i++;
      }
      if (strncmp(argv[0], "q", 2) == 0) {
         return;
      }
      if (!legal_cmd) {
         printf("Illegal command, try again\n");
      }
   }
}

int main () {
   exec();
   return 0;
}
