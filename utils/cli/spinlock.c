#include "spinlock.h"

void acquire(struct spinlock *lock) {
}
void release(struct spinlock *lock) {
}
void initlock(struct spinlock *lock, char *name) {
   lock->name = name;
   lock->locked = 0;
}

