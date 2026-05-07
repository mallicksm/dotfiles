# SerDes 224G PMD — Lane Swap

Reference: `dwc_224g_ethernet_phy_tsmc3pff_x4ns` 4.11a (configured tree at
`/project/libraries/tsmc_n3p/synopsys/dwc_ips/dwc_224g_ethernet_phy_tsmc3pff_x4ns/4.11a_cum_patch0a1a/`).

Build config in scope:

- `DWC_224G_PHY_X4_NS_LANE_SWAP_MUX`  → **defined**   (option **A** active)
- `DWC_224G_PHY_X4_NS_LANE_SWAP_PINS` → **not defined** (option **B** inactive)

This file documents **option A** — the internal CSR-driven lane-swap mux.

---

## The clever trick

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


