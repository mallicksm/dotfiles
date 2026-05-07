# SerDes 224G PMD — Lane Swap

Reference: `dwc_224g_ethernet_phy_tsmc3pff_x4ns` 4.11a (configured tree at
`/project/libraries/tsmc_n3p/synopsys/dwc_ips/dwc_224g_ethernet_phy_tsmc3pff_x4ns/4.11a_cum_patch0a1a/`).

Build config in scope:

- `DWC_224G_PHY_X4_NS_LANE_SWAP_MUX`  → **defined**   (option **A** active)
- `DWC_224G_PHY_X4_NS_LANE_SWAP_PINS` → **not defined** (option **B** inactive)

This file documents **option A** — the internal CSR-driven lane-swap mux.

---

## Option A — internal lane-swap mux

Module: `pmd/rtl/dwc_224g_phy_pmd_x4_ns_pmd_lane_swap_mux.sv`
(`LANEC = 4`, sel width = `clog2(4) = 2` bits per lane).

## The aha

The wires and CSRs make it *look* like you have two independent 4×4:1 crossbars
(one per direction). **You don't.** The real degree of freedom is picking one
bijection `f : L ↔ P` out of the **4! = 24 possible permutations**. The two
muxes are just two halves of that single bijection.

Why? Because each physical lane `P_i` is ONE atomic AFE block:

```text
                P_i  — single atomic AFE (cannot be split)

                      ┌──────────────────┐
                      │   TX driver      │ ────────────► TXp/n[i]
                      └──────────────────┘
                      ┌──────────────────┐
                      │   RX path / CDR  │ ◄──────────── RXp/n[i]
                      └──────────────────┘
                      ┌──────────────────┐
                      │   symclk PLL     │ ── pmd_tx_symclk[i] ──►
                      └──────────────────┘
```

You cannot drive its TX from one logical engine and read its RX/symclk into a
different logical engine — they share the same PLL and the same hardware block.
Whichever `L_j` drives `P_i`'s TX **must** be the same one reading back `P_i`'s
symclk and FFE-ack. Period.

So in practice the "lane swap mux" just lets firmware bind each `L_j` to
exactly one `P_i` (and vice versa) — a 4-element permutation.

## The bijection

```text
   Logical side                                 Physical side
   (KR/AN engines + FFE                         (atomic AFE per i,
   training engines, per j)                     bonded TX + RX + symclk)

       L_0  ◄════════════════════════════════════════════►   P_0  ↔ pads[0]
       L_1  ◄════════════════════════════════════════════►   P_1  ↔ pads[1]
       L_2  ◄════════════════════════════════════════════►   P_2  ↔ pads[2]
       L_3  ◄════════════════════════════════════════════►   P_3  ↔ pads[3]

   Each ◄══► is the FULL two-way bond between L_j and P_i:
       L → P  carries:  KR pattern, FFE coeffs, encoder mode, TX disable, ...
       P → L  carries:  TX symdata width, signal type, FFE-ack, pmd_tx_symclk

   The picture above shows the IDENTITY mapping (L_j ↔ P_j). Firmware can
   program any of the 4! = 24 permutations as long as L↔P stays a bijection.
```

## How it's implemented — and the trap

The bijection is realized by two CSR-driven 4:1 muxes per output, one per
direction. Each is a 2-bit field per lane:

```text
   Pass 1  (L → P, downstream KR/FFE/...):
        P[i] = L[ LOG_SEL[i] ]
        LOG_SEL[i]  = j  such that  L_j ↔ P_i
        reg_logical_tx_mux_sel[i]      (TX-lane CSR 0x074, bits [1:0])

   Pass 2  (P → L, upstream status + symclk):
        L[j] = P[ PHYS_SEL[j] ]
        PHYS_SEL[j] = i  such that  L_j ↔ P_i
        reg_physical_tx_mux_sel[j]     (RX-lane CSR 0x018, bits [1:0])
```

`LOG_SEL` and `PHYS_SEL` encode the **same bijection viewed from opposite ends**
— so they must be **inverse permutations** of each other.

If you program them inconsistently, KR engine `L_j` sends its training pattern
out `P_x`, but reads back symclk and FFE-ack from `P_y ≠ P_x`. The two halves
of the same atomic AFE would be talking to different KR engines — electrically
impossible. KR will never converge.

```text
   GOOD (inverse pair, identity):                BAD (non-inverse):

       LOG_SEL  = {0, 1, 2, 3}                       LOG_SEL  = {0, 1, 2, 3}
       PHYS_SEL = {0, 1, 2, 3}                       PHYS_SEL = {3, 2, 1, 0}

       L_0 ── KR pattern ─► P_0                      L_0 ── KR pattern ─► P_0
       L_0 ◄── symclk ──── P_0     ✓                 L_0 ◄── symclk ──── P_3   ✗
                                                     (P_3's symclk does not match
                                                      P_0's TX driver — link dies)
```

## All 24 legal bijections

Cycle notation: a cycle `(a→b→c→a)` means `a` maps to `b`, `b` maps to `c`, and
`c` maps back to `a`. Fixed points (lanes that stay put) are written `(j)` with
no arrows. Self-inverse bijections have `LOG_SEL = PHYS_SEL`.

Total: `4! = 24`. Grouped by cycle structure:

| #  | Cycle notation        | `LOG_SEL[3..0]` | `PHYS_SEL[3..0]` | Notes                                                      |
|----|-----------------------|-----------------|------------------|------------------------------------------------------------|
| 1  | `(0)(1)(2)(3)`        | `{0,1,2,3}`     | `{0,1,2,3}`      | **identity** (cyclic +0); self-inverse                     |
| 2  | `(0→1→0)(2)(3)`       | `{1,0,2,3}`     | `{1,0,2,3}`      | swap(0,1); self-inverse                                    |
| 3  | `(0→2→0)(1)(3)`       | `{2,1,0,3}`     | `{2,1,0,3}`      | swap(0,2); self-inverse                                    |
| 4  | `(0→3→0)(1)(2)`       | `{3,1,2,0}`     | `{3,1,2,0}`      | swap(0,3); self-inverse                                    |
| 5  | `(0)(1→2→1)(3)`       | `{0,2,1,3}`     | `{0,2,1,3}`      | swap(1,2); self-inverse                                    |
| 6  | `(0)(1→3→1)(2)`       | `{0,3,2,1}`     | `{0,3,2,1}`      | swap(1,3); self-inverse                                    |
| 7  | `(0)(1)(2→3→2)`       | `{0,1,3,2}`     | `{0,1,3,2}`      | swap(2,3); self-inverse                                    |
| 8  | `(0→1→0)(2→3→2)`      | `{1,0,3,2}`     | `{1,0,3,2}`      | dbl-swap (0↔1)(2↔3); self-inverse                          |
| 9  | `(0→2→0)(1→3→1)`      | `{2,3,0,1}`     | `{2,3,0,1}`      | **cyclic +2** = dbl-swap (0↔2)(1↔3); self-inverse          |
| 10 | `(0→3→0)(1→2→1)`      | `{3,2,1,0}`     | `{3,2,1,0}`      | **full reversal** = dbl-swap (0↔3)(1↔2); self-inverse      |
| 11 | `(0→1→2→0)(3)`        | `{2,0,1,3}`     | `{1,2,0,3}`      | 3-cycle (L_3 fixed); inverse of #12                        |
| 12 | `(0→2→1→0)(3)`        | `{1,2,0,3}`     | `{2,0,1,3}`      | 3-cycle (L_3 fixed); inverse of #11                        |
| 13 | `(0→1→3→0)(2)`        | `{3,0,2,1}`     | `{1,3,2,0}`      | 3-cycle (L_2 fixed); inverse of #14                        |
| 14 | `(0→3→1→0)(2)`        | `{1,3,2,0}`     | `{3,0,2,1}`      | 3-cycle (L_2 fixed); inverse of #13                        |
| 15 | `(0→2→3→0)(1)`        | `{3,1,0,2}`     | `{2,1,3,0}`      | 3-cycle (L_1 fixed); inverse of #16                        |
| 16 | `(0→3→2→0)(1)`        | `{2,1,3,0}`     | `{3,1,0,2}`      | 3-cycle (L_1 fixed); inverse of #15                        |
| 17 | `(0)(1→2→3→1)`        | `{0,3,1,2}`     | `{0,2,3,1}`      | 3-cycle (L_0 fixed); inverse of #18                        |
| 18 | `(0)(1→3→2→1)`        | `{0,2,3,1}`     | `{0,3,1,2}`      | 3-cycle (L_0 fixed); inverse of #17                        |
| 19 | `(0→1→2→3→0)`         | `{3,0,1,2}`     | `{1,2,3,0}`      | **cyclic +1**; inverse of #20                              |
| 20 | `(0→3→2→1→0)`         | `{1,2,3,0}`     | `{3,0,1,2}`      | **cyclic +3** (= cyclic -1); inverse of #19                |
| 21 | `(0→1→3→2→0)`         | `{2,0,3,1}`     | `{1,3,0,2}`      | non-rotation 4-cycle; inverse of #22                       |
| 22 | `(0→2→3→1→0)`         | `{1,3,0,2}`     | `{2,0,3,1}`      | non-rotation 4-cycle; inverse of #21                       |
| 23 | `(0→2→1→3→0)`         | `{3,2,0,1}`     | `{2,3,1,0}`      | non-rotation 4-cycle; inverse of #24                       |
| 24 | `(0→3→1→2→0)`         | `{2,3,1,0}`     | `{3,2,0,1}`      | non-rotation 4-cycle; inverse of #23                       |

Family count check: 1 identity + 6 single swaps + 3 double swaps + 8 three-cycles
+ 6 four-cycles = **24**. ✓

Self-inverse rows (where `LOG_SEL = PHYS_SEL`): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
(10 of 24). The remaining 14 form 7 inverse pairs.

In practice you'll almost always pick **#1 (identity)**, **#10 (full reversal)**,
or one of **#19 / #20 (cyclic ±1)**. The other 19 are hardware-legal but rarely
useful for any real board topology.

## 24 bijections (grid view)

Convention: row = `L_j` (logical lane, top→bottom), column = `P_i` (physical
lane, left→right). A `●` at row `j`, column `i` means `L_j ↔ P_i`. Every row and
every column has exactly one dot — that's the bijection property visualized.

```text
┌─ Family 1: identity (1) ────────────────────────────────────────────────┐
│                                                                         │
│  #1 identity                                                            │
│  P: 0 1 2 3                                                             │
│  L0 ● · · ·                                                             │
│  L1 · ● · ·                                                             │
│  L2 · · ● ·                                                             │
│  L3 · · · ●                                                             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─ Family 2: single swaps (6) ────────────────────────────────────────────┐
│                                                                         │
│  #2 swap(0,1)     #3 swap(0,2)     #4 swap(0,3)     #5 swap(1,2)        │
│  P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3          │
│  L0 · ● · ·       L0 · · ● ·       L0 · · · ●       L0 ● · · ·          │
│  L1 ● · · ·       L1 · ● · ·       L1 · ● · ·       L1 · · ● ·          │
│  L2 · · ● ·       L2 ● · · ·       L2 · · ● ·       L2 · ● · ·          │
│  L3 · · · ●       L3 · · · ●       L3 ● · · ·       L3 · · · ●          │
│                                                                         │
│  #6 swap(1,3)     #7 swap(2,3)                                          │
│  P: 0 1 2 3       P: 0 1 2 3                                            │
│  L0 ● · · ·       L0 ● · · ·                                            │
│  L1 · · · ●       L1 · ● · ·                                            │
│  L2 · · ● ·       L2 · · · ●                                            │
│  L3 · ● · ·       L3 · · ● ·                                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─ Family 3: double swaps (3) ────────────────────────────────────────────┐
│                                                                         │
│  #8 (01)(23) dbl  #9 cyclic +2     #10 full reverse                     │
│  P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3                           │
│  L0 · ● · ·       L0 · · ● ·       L0 · · · ●                           │
│  L1 ● · · ·       L1 · · · ●       L1 · · ● ·                           │
│  L2 · · · ●       L2 ● · · ·       L2 · ● · ·                           │
│  L3 · · ● ·       L3 · ● · ·       L3 ● · · ·                           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─ Family 4: 3-cycles (8) ────────────────────────────────────────────────┐
│                                                                         │
│  #11 3-cyc(L3fix) #12 3-cyc(L3fix) #13 3-cyc(L2fix) #14 3-cyc(L2fix)    │
│  P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3          │
│  L0 · ● · ·       L0 · · ● ·       L0 · ● · ·       L0 · · · ●          │
│  L1 · · ● ·       L1 ● · · ·       L1 · · · ●       L1 ● · · ·          │
│  L2 ● · · ·       L2 · ● · ·       L2 · · ● ·       L2 · · ● ·          │
│  L3 · · · ●       L3 · · · ●       L3 ● · · ·       L3 · ● · ·          │
│                                                                         │
│  #15 3-cyc(L1fix) #16 3-cyc(L1fix) #17 3-cyc(L0fix) #18 3-cyc(L0fix)    │
│  P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3          │
│  L0 · · ● ·       L0 · · · ●       L0 ● · · ·       L0 ● · · ·          │
│  L1 · ● · ·       L1 · ● · ·       L1 · · ● ·       L1 · · · ●          │
│  L2 · · · ●       L2 ● · · ·       L2 · · · ●       L2 · ● · ·          │
│  L3 ● · · ·       L3 · · ● ·       L3 · ● · ·       L3 · · ● ·          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─ Family 5: 4-cycles (6) ────────────────────────────────────────────────┐
│                                                                         │
│  #19 cyclic +1    #20 cyclic +3    #21 4-cyc        #22 4-cyc           │
│  P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3       P: 0 1 2 3          │
│  L0 · ● · ·       L0 · · · ●       L0 · ● · ·       L0 · · ● ·          │
│  L1 · · ● ·       L1 ● · · ·       L1 · · · ●       L1 ● · · ·          │
│  L2 · · · ●       L2 · ● · ·       L2 ● · · ·       L2 · · · ●          │
│  L3 ● · · ·       L3 · · ● ·       L3 · · ● ·       L3 · ● · ·          │
│                                                                         │
│  #23 4-cyc        #24 4-cyc                                             │
│  P: 0 1 2 3       P: 0 1 2 3                                            │
│  L0 · · ● ·       L0 · · · ●                                            │
│  L1 · · · ●       L1 · · ● ·                                            │
│  L2 · ● · ·       L2 ● · · ·                                            │
│  L3 ● · · ·       L3 · ● · ·                                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Visual patterns to spot:

- **Identity (#1)** — dots on the main diagonal `\`.
- **Full reversal (#10)** — dots on the anti-diagonal `/`.
- **Cyclic +1 (#19)** — main diagonal shifted one column right with wrap.
- **Cyclic +3 (#20)** — main diagonal shifted one column left with wrap.
- **Cyclic +2 (#9)** — main diagonal shifted two columns with wrap (also a double-swap).
- **Self-inverse rows (#1–#10)** — dot pattern is symmetric across the main
  diagonal (transposing the grid gives the same grid).
- **Inverse pairs (#11/#12, #13/#14, #15/#16, #17/#18, #19/#20, #21/#22, #23/#24)**
  — each pair's grids are mirror images of each other across the main diagonal.
- **3-cycles (#11–#18)** — exactly one dot stays on the main diagonal (the
  fixed lane); the other three form a 3-element rotation among the off-diagonal
  positions.

## Reset gotcha

Both CSRs reset to `2'b00` for every lane. With those defaults, every output
picks lane 0 — that's NOT the identity bijection. Firmware **must** program at
least the identity (`LOG_SEL = PHYS_SEL = {0,1,2,3}`) before bringing up KR.

(This is different from `LANE_SWAP_MUX` *not being defined* at compile time —
in that case the module is hard-coded to passthrough at all times, ignoring
the CSRs.)

## Signals carried by each pass

(From `pmd_lane_swap_mux.sv` lines 103–157.)

**Pass 1 (L → P)** — KR/AN/FFE/encoder plumbing:

- FFE coefficients: `tx_ffe_cursor` (7b), `tx_ffe_postcursor1/2` (6b each), `tx_ffe_precursor1` (6b), `precursor2` (5b), `precursor3/4` (4b each)
- `tx_ffe_coeff_update`, `tx_disable`
- `mr_training_enable_tx_symclk`, `krt_pam4_encoder_mode` (2b)
- `an_krt_data` (160-bit KR training pattern)
- `tx_train_data_sel`
- `reg_encoder_mode_ovrd_en` / `_val`, `reg_pam4_precode_no_krt_en`, `reg_pam4_ab_swap_en`

**Pass 2 (P → L)** — status feedback + clock:

- `tx_symdata_width` (4b), `tx_signal_type` (NRZ vs PAM4)
- `tx_ffe_coeff_init_update`, `tx_ffe_coeff_update_ack`
- `pmd_tx_symclk` — via the `dwc_224g_phy_pmd_x4_ns_pmd_clk_mux` instance
  (in scan mode the select is forced to identity to keep per-lane scan clocks)

## What is NOT muxed

User TX/RX `symdata` does not go through this module. The 160-bit user
`tx_symdata` that the MAC/PCS drives onto `pmd_lane[i]` goes straight to AFE TX
lane `i`; `rx_symdata` comes back from AFE RX lane `i` straight to the PCS.
**No permutation of the user data path inside the PMD.** If the board has
swapped lanes, the upstream PCS / MAC has to permute the user data; the PMD's
lane-swap mux only fixes the KR/AN/FFE/symclk plumbing so each KR engine is
bonded to the right atomic AFE.
