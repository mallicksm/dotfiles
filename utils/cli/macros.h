//=============================================================================
// C++ Programming
// Created: Mar-10-2023
// Author: soummya
//
// Note:
//
// Description: Description
//
// .align is p2align while .balign is byte align
//=============================================================================
#define PROC(name) \
  .global name;    \
  .align 2;        \
name:              \

#define ENDPROC(name)    \
  .type name, @function; \

#define VENTRY(name) \
.balign 0x80;        \
  b name;            \

#define NELEM(x) (sizeof(x) / sizeof((x)[0]))
#define UNUSED_VARIABLE(N) \
   do {                    \
      (void)(N);           \
   } while (0)

#define CLI_FUNCTION(name, comment) \
int name##_cli(int argc, char* argv[]) {  \
   UNUSED_VARIABLE(argc);                       \
   UNUSED_VARIABLE(argv);                       \
   name();                                      \
   return 0;                                    \
}

#define CLI_ALIASES(name, comment) \
   {                      \
      .cmd = #name,       \
      .func = name##_cli, \
   },

#define CLI_HELP(name, comment) \
   printf("   %s            \t%s\n", #name, #comment);
