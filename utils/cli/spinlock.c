#include "spinlock.h"
#include "types.h"
#include "defs.h"

void acquire(struct spinlock *lock) {
   UNUSED_VARIABLE(lock);
}
void release(struct spinlock *lock) {
   UNUSED_VARIABLE(lock);
}
void initlock(struct spinlock *lock, char *name) {
   lock->name = name;
   lock->locked = 0;
}
