#include "types.h"
#include "defs.h"
#include "vm.h"

void logprintf(char *fmt, ...) {
   va_list args;
   va_start(args, fmt);
   vprintf(fmt, args);
   va_end(args);
}

int kinit_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;

   uint64 ip = kinit();
   printf("ip=0x%016llx\n", ip);
   return 0;
}
int kalloc_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   void *pa = kalloc();
   printf("pa=0x%016llx\n", pa);
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
int kvminit_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   kvminit();
   return 0;
}

int pteprint_cli(int argc, char** argv) {
   (void)argc;
   (void)argv;
   pteprint(pagetable, 1);
   return 0;
}

int mappages_cli(int argc, char** argv) {
   uint64 pa;
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
   mappages(pagetable, va, 0x123456789a000ULL+va, levels, pages*PGSIZE, 0x5bULL<<(14*4));
   return 0;
}

int test_cli(int argc, char** argv) {
   (void)argc;
   uint64 va = strtol(argv[1], NULL, 0);
   for (int l = 0; l < 4; l++) {
      printf("PgRoundUp   l=%d: 0x%016llx\n", l, PGROUNDUP(va,l));
      printf("PgRoundDown l=%d: 0x%016llx\n", l, PGROUNDDOWN(va,l));
      printf("pagetable 0x%016llx\n", pagetable);
   }
}

int mrd_cli(int argc, char** argv) {
   if (argc != 2) {
      printf("Please provide 1 argument\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = *(volatile uint64 *)addr;
   printf("Mem[0x%016llx] => 0x%016llx\n",addr, data);
   return 0;
}

int mwr_cli(int argc, char** argv) {
   if (argc != 3) {
      logprintf("Please provide 2 arguments\n");
      return -1;
   }
   uint64 addr = strtol(argv[1], NULL, 0);
   uint64 data = strtol(argv[2], NULL, 0);
   *(volatile uint64 *)addr = data;
   printf("Mem[0x%016llx] <= 0x%016llx\n",addr, data);
   return 0;
}

int help_cli(int argc, char** argv) {
   printf("mappages va pages pa levels\n");
   printf("pteprint\n");
   printf("mrd/mwr\n");
   printf("kinit\n");
   printf("kalloc\n");
   printf("kfree\n");
   printf("test va\n");
   printf("help\n");
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
      .cmd = "test",
      .func = test_cli,
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
   {
      .cmd = "kvminit",
      .func = kvminit_cli,
   }, 
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
            logprintf("rc=%d\n",rc);
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
