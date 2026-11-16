# Zones

`CZones`: a reusable MQL5 class that finds supply and demand zones, groups them into clusters and draws them on the chart.

> **Proprietary software.** © Teenodi Ltd. All rights reserved. The code is shared for viewing only. It is not licensed for reuse or redistribution. See [LICENSE](LICENSE).

## What it does

- **Scans for swing zones.** High-swing zones (supply) and low-swing zones (demand), on any symbol and timeframe.
- **Checks depth.** A zone needs a minimum depth and must stay under a maximum depth, set in points or as a share of the recent price range.
- **Groups zones into clusters.** Zones that sit close together become one cluster.
- **Keeps zones current.** It updates them on new bars and can remove the ones price has broken.
- **Draws them.** Zones and clusters can be shown on the chart.

```mql5
#include "Zones.mqh"

CZones zones;
zones.Initialize(_Symbol,PERIOD_H1);
zones.ScanZones();
```

## Zones.mqh

## Install

1. Copy the source file(s) into your MetaTrader 5 `MQL5/` tree (`Experts/`, `Indicators/`, or `Scripts/` as appropriate).
2. In MetaEditor, open the file and compile (**F7**).
3. Attach the compiled program to a chart from the terminal Navigator.

## Risk note

Trading carries risk. This code shows how the strategy is built. It is not financial advice.

## License

Proprietary. © Teenodi Ltd. All rights reserved. The code is shared for viewing only. See [LICENSE](LICENSE).
