# AArch32 CP15 System Registers

Quick reference for AArch32 CP15 (coprocessor 15) system registers and
operations, accessed with `MRC`/`MCR` (32-bit) or `MRRC`/`MCRR` (64-bit).

Encoding columns follow the ARM ARM convention:

```
MRC/MCR  p15, <op1>, <Rt>, <CRn>, <CRm>, <op2>
```

`<rd>` marks the general-purpose register operand (`<Rt>`). Blank `CRn`/`op2`
cells are the 64-bit `MRRC`/`MCRR` registers, which are selected by `op1` + `CRm`
alone. Access notes (RO/RW, Secure/Non-Secure) are in the description.

## System Control Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `sctlr`  | 0 | c1 | c0 | 0 | System Control Register |
| `actlr`  | 0 | c1 | c0 | 1 | Auxiliary Control Register |
| `cpacr`  | 0 | c1 | c0 | 2 | Coprocessor Access Control Register |
| `scr`    | 0 | c1 | c1 | 0 | Secure Configuration (Secure only) |
| `sder`   | 0 | c1 | c1 | 1 | Secure Debug Enable (Secure only) |
| `nsacr`  | 0 | c1 | c1 | 2 | Non-Secure Access Control (Non-Secure RO) |

## Memory System Fault Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `dfsr`  | 0 | c5 | c0 | 0 | Data Fault Status Register |
| `ifsr`  | 0 | c5 | c0 | 1 | Instruction Fault Status Register |
| `adfsr` | 0 | c5 | c1 | 0 | Auxiliary DFSR |
| `aifsr` | 0 | c5 | c1 | 1 | Auxiliary IFSR |
| `dfar`  | 0 | c6 | c0 | 0 | Data Fault Address Register |
| `ifar`  | 0 | c6 | c0 | 2 | Instruction Fault Address Register |
| `drbar` | 0 | c6 | c1 | 0 | Data Region Base Address Register |
| `irbar` | 0 | c6 | c1 | 1 | Instruction Region Base Address Register |
| `drsr`  | 0 | c6 | c1 | 2 | Data Region Size and Enable Register |
| `irsr`  | 0 | c6 | c1 | 3 | Instruction Region Size and Enable Register |
| `dracr` | 0 | c6 | c1 | 4 | Data Region Access Control Register |
| `iracr` | 0 | c6 | c1 | 5 | Instruction Region Access Control Register |
| `rgnr`  | 0 | c6 | c2 | 0 | MPU Region Number Register |

## ID Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `midr`      | 0 | c0 | c0 | 0 | Main ID Register |
| `ctr`       | 0 | c0 | c0 | 1 | Cache Type Register |
| `tcmtr`     | 0 | c0 | c0 | 2 | TCM Type Register |
| `tlbtr`     | 0 | c0 | c0 | 3 | TLB Type Register |
| `mpuir`     | 0 | c0 | c0 | 4 | MPU Type Register |
| `mpidr`     | 0 | c0 | c0 | 5 | Multiprocessor Affinity Register |
| `revidr`    | 0 | c0 | c0 | 6 | Revision ID |
| `id pfr0`   | 0 | c0 | c1 | 0 | Processor Feature Register 0 |
| `id pfr1`   | 0 | c0 | c1 | 1 | Processor Feature Register 1 |
| `id dfr0`   | 0 | c0 | c1 | 2 | Debug Feature Register 0 |
| `id afr0`   | 0 | c0 | c1 | 3 | Auxiliary Feature Register 0 |
| `id mmfr0`  | 0 | c0 | c1 | 4 | Memory Model Feature Register 0 |
| `id mmfr1`  | 0 | c0 | c1 | 5 | Memory Model Feature Register 1 |
| `id mmfr2`  | 0 | c0 | c1 | 6 | Memory Model Feature Register 2 |
| `id mmfr3`  | 0 | c0 | c1 | 7 | Memory Model Feature Register 3 |
| `id isar0`  | 0 | c0 | c2 | 0 | Instruction Set Attribute Register 0 |
| `id isar1`  | 0 | c0 | c2 | 1 | Instruction Set Attribute Register 1 |
| `id isar2`  | 0 | c0 | c2 | 2 | Instruction Set Attribute Register 2 |
| `id isar3`  | 0 | c0 | c2 | 3 | Instruction Set Attribute Register 3 |
| `id isar4`  | 0 | c0 | c2 | 4 | Instruction Set Attribute Register 4 |
| `id isar5`  | 0 | c0 | c2 | 5 | Instruction Set Attribute Register 5 |
| `ccsidr`    | 1 | c0 | c0 | 0 | Cache Size ID Register |
| `clidr`     | 1 | c0 | c0 | 1 | Cache Level ID Register |
| `aidr`      | 1 | c0 | c0 | 7 | Auxiliary ID Register |
| `csselr`    | 2 | c0 | c0 | 0 | Cache Size Selection Register (RW) |

## Generic Timer Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `cntfrq`    | 0 | c14 | c0 | 0 | Counter Frequency Register (Non-Secure RO) |
| `cntkctl`   | 0 | c14 | c1 | 0 | Timer PL1 Control Register |
| `cntp tval` | 0 | c14 | c2 | 0 | PL1 Physical TimerValue Register |
| `cntp ctl`  | 0 | c14 | c2 | 1 | PL1 Physical Timer Control Register |
| `cntv tval` | 0 | c14 | c3 | 0 | Virtual TimerValue Register |
| `cntv ctl`  | 0 | c14 | c3 | 1 | Virtual Timer Control Register |
| `cntpct`    | 0 | | c14 | | Physical Count Register (RO, 64-bit) |
| `cntvct`    | 1 | | c14 | | Virtual Count Register (RO, 64-bit) |
| `cntp cval` | 2 | | c14 | | PL1 Physical Timer CompareValue Register (64-bit) |
| `cntv cval` | 3 | | c14 | | Virtual Timer CompareValue Register (64-bit) |

## Performance Monitor Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `PMCR`       | 0 | c9 | c12 | 0 | PM Control Register |
| `PMCNTENSET` | 0 | c9 | c12 | 1 | PM Count Enable Set Register |
| `PMCNTENCLR` | 0 | c9 | c12 | 2 | PM Count Enable Clear Register |
| `PMOVSR`     | 0 | c9 | c12 | 3 | PM Overflow Flag Status Register |
| `PMSWINC`    | 0 | c9 | c12 | 4 | PM Software Increment Register |
| `PMSELR`     | 0 | c9 | c12 | 5 | PM Event Counter Selection Register |
| `PMCEID0`    | 0 | c9 | c12 | 6 | PM Common Event Identification Register 0 |
| `PMCEID1`    | 0 | c9 | c12 | 7 | PM Common Event Identification Register 1 |
| `PMCCNTR`    | 0 | c9 | c13 | 0 | PM Cycle Count Register |
| `PMXEVTYPER` | 0 | c9 | c13 | 1 | PM Event Type Select Register |
| `PMXEVCNTR`  | 0 | c9 | c13 | 2 | PM Event Count Register |
| `PMUSERENR`  | 0 | c9 | c14 | 0 | PM User Enable Register |
| `PMINTENSET` | 0 | c9 | c14 | 1 | PM Interrupt Enable Set Register |
| `PMINTENCLR` | 0 | c9 | c14 | 2 | PM Interrupt Enable Clear Register |

## Cache Maintenance Registers

| Register | op1 | CRn | CRm | op2 | Description |
|----------|-----|-----|-----|-----|-------------|
| `cp15wfi`    | 0 | c7 | c0  | 4 | Wait for interrupt operation |
| `icialluis`  | 0 | c7 | c1  | 0 | Inv all instr caches to PoU Inner Shareable |
| `bpiallis`   | 0 | c7 | c1  | 6 | Inv all branch predictors Inner Shareable |
| `par`        | 0 | c7 | c4  | 0 | Physical Address Register (RW) |
| `iciallu`    | 0 | c7 | c5  | 0 | Invalidate all instruction caches to PoU |
| `icimvau`    | 0 | c7 | c5  | 1 | Inv instruction caches by MVA to PoU |
| `cp15isb`    | 0 | c7 | c5  | 4 | Instruction Sync Barrier operation |
| `bpiall`     | 0 | c7 | c5  | 6 | Invalidate all branch predictors |
| `bpimva`     | 0 | c7 | c5  | 7 | Invalidate MVA from branch predictors |
| `dcimvac`    | 0 | c7 | c6  | 1 | Inv data cache line by MVA to PoC |
| `dcisw`      | 0 | c7 | c6  | 2 | Invalidate data cache line by set/way |
| `ats1cpr`    | 0 | c7 | c8  | 0 | PL1 read translation (Current state) |
| `ats1cpw`    | 0 | c7 | c8  | 1 | PL1 write translation (Current state) |
| `ats1cur`    | 0 | c7 | c8  | 2 | Unpriv read translation (Current state) |
| `ats1cuw`    | 0 | c7 | c8  | 3 | Unpriv write translation (Current state) |
| `ats12nsopr` | 0 | c7 | c8  | 4 | PL1 read translation (NS state) |
| `ats12nsopw` | 0 | c7 | c8  | 5 | PL1 write translation (NS state) |
| `ats12nsour` | 0 | c7 | c8  | 6 | Unprivileged read translation (NS state) |
| `ats12nsouw` | 0 | c7 | c8  | 7 | Unprivileged write translation (NS state) |
| `dccmvac`    | 0 | c7 | c10 | 1 | Clean data cache line by MVA to PoC |
| `dccsw`      | 0 | c7 | c10 | 2 | Clean data cache line by set/way |
| `cp15dsb`    | 0 | c7 | c10 | 4 | Data Synchronization Barrier operation |
| `cp15dmb`    | 0 | c7 | c10 | 5 | Data Memory Barrier operation |
| `dccmvau`    | 0 | c7 | c11 | 1 | Clean data cache line by MVA to PoU |
| `dccimvac`   | 0 | c7 | c14 | 1 | Clean and inv data cache line by MVA to PoC |
| `dccisw`     | 0 | c7 | c14 | 2 | Clean and inv data cache line by set/way |
| `par`        | 0 | c7 |     |   | Physical Address Register (RW, 64-bit) |
