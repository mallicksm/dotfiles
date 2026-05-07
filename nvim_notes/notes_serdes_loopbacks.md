# SerDes 224G PMD — Loopback Modes

Reference: `dwc_224g_ethernet_phy_tsmc3pff_x4ns` 4.11a (configured tree at
`/project/libraries/tsmc_n3p/synopsys/dwc_ips/dwc_224g_ethernet_phy_tsmc3pff_x4ns/4.11a_cum_patch0a1a/`).

There are **three internal loopback paths** in the PHY, plus an "external
loopback" that lives outside the IP (board / test-harness wiring).

## Summary

| # | Name | Domain | Direction | Tap point | Enable bit(s) | SDK API |
|---|---|---|---|---|---|---|
| 1 | **Near-End Serial** (NE Serial) | Analog / AFE | TX → RX | TX serializer output muxed into RX AFE input, *before* the CTLE / channel pads | `RX_AFE_MB.RX_AFE_MBOX2425.AFE_LPBK_CTRL` ← `0x23` **and** `TX.TXS_CFG0.TX2RX_LPBK_EN` ← 1 (also CTLE gain/boost cleared) | `dwc_224g_phy_pmd_x4_ns_sdk_ne_serial_lpbk()` |
| 2 | **Near-End Parallel** (NE Parallel) | Digital | TX → RX | 160-bit symbol-bus mux at top of RX datapath; bypasses serializer / AFE / DSP entirely | `PMD_LANE_RX.RX_LANE_CFG0.TX_TO_RX_LPBK_EN` ← 1 | `dwc_224g_phy_pmd_x4_ns_sdk_ne_parallel_lpbk()` |
| 3 | **Far-End Parallel** (FE Parallel) | Digital | RX → TX | 160-bit symbol-bus mux at TX datapath input; recovered RX symdata is re-clocked onto TX | `PMD_LANE_RX.RX_LANE_CFG0.RX_TO_TX_LPBK_EN` ← 1; usually also `PMD_LANE_TX.FREQ_CODE_CFG11.TRACK_LOCAL_RX_CLK` ← 1 + clock-fwd flow | `dwc_224g_phy_pmd_x4_ns_sdk_fe_parallel_lpbk_clk_fwd()` |
| (4) | "External" loopback | Off-IP | TX pad → RX pad | Board/connector ties TXp/n to RXp/n outside the package — PHY runs as a normal link | none in the PMD; done by test fixture | tested via `ate_semisdk_tx2rx_extlpbk_test`, `stb_sdk_extlpbk_test` |

There is **no Far-End Serial** loopback in this PMD.

Naming convention (standard SerDes):

- **Near-End** = source is *this* PHY's TX, sunk into *this* PHY's RX (you're testing your own slice).
- **Far-End** = source is the link partner's TX (incoming through the channel into our RX), and the PHY *retransmits* it out our TX (the partner is testing themselves through us).
- **Serial** = mux is in the analog/AFE/serializer domain (post-serializer, pre-pad).
- **Parallel** = mux is in the digital 160-bit symbol-domain inside `pmd_datapath`.

## ASCII picture

```text
       Digital                       AFE / Analog                     Pads

   ┌──────────────┐               ┌──────────────┐
   │ TX symdata   │──────────────►│ PISO / AFE TX│──────────────────► ◯ TXp/n
   │  (160-bit)   │               └──────┬───────┘
   └──┬────────┬──┘                      │
      ▲        │                         │
      │        │                         │
   (3)│        │(2)                      │  (1) NE-Serial AFE / serial mux
      │        │                         ▼
      │        │                  ┌──────┴───────┐    ┌──────────┐
      │        ▼                  │ CTLE / DFE   │◄───┤  AFE RX  │◄──── ◯ RXp/n
   ┌──┴────────┴──┐               └──────┬───────┘    └──────────┘
   │ RX symdata   │                      │
   │  (160-bit)   │◄─────────────────────┘
   └──────────────┘
```

Loopback paths in the diagram:

- **(1) NE-Serial** — analog/AFE mux: taps PISO/AFE TX output back into CTLE/DFE input (before the channel pads).
- **(2) NE-Parallel** — digital mux at top of RX datapath: routes `TX symdata` (160-bit) into `RX symdata`.
- **(3) FE-Parallel** — digital mux at top of TX datapath: re-pipes recovered `RX symdata` (160-bit) onto `TX symdata`.
