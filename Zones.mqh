//+------------------------------------------------------------------+
//|                                                        Zones.mqh |
//|                                      Copyright 2025,Teenodi Ltd. |
//|                                           https://wwwteenodi.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025,Teenodi Ltd."
#property link      "https://wwwteenodi.com"
#property version   "1.00"

#include "Context.mqh"

//+------------------------------------------------------------------+
//| Enumeration Definitions                                          |
//+------------------------------------------------------------------+
enum DepthMode { CONTEXT, FIXED_POINTS };
enum ContextType { PRECEEDING_BARS_RANGE, ATR };

//+------------------------------------------------------------------+
//| Structure Definitions                                            |
//+------------------------------------------------------------------+
struct Zone
{
    double      apex;                    // High price for HS, Low price for LS
    double      bodyApex;                // Highest body tip for nearby candles
    datetime    zoneTime;                // Bar time of zone candle
    datetime    bodyTime;                // Bar time of body Apex candle
    double      lowRange;                // Lower boundary of zone
    double      highRange;               // Upper boundary of zone
    double      breachValue;             // Current breach tracking value
    double      maxPostApexFartherDepth; // Maximum allowed depth (price value)
    string      visualRef;               // Name of visualization object
};

struct ZoneCluster
{
    datetime    clusterTime;             // Time of latest zone in cluster
    datetime    clusterStartTime;        // Time of earliest zone in cluster
    double      clusterUpperRange;       // Upper boundary
    double      clusterLowerRange;       // Lower boundary
    int         zoneCount;               // Number of zones in cluster
    string      visualRef;               // Name of visualization channel
};

struct MakeshiftZone
{
    datetime    zoneTime;
    double      apex;
    double      bodyApex;
};

//+------------------------------------------------------------------+
//| Zones Management Class                                           |
//+------------------------------------------------------------------+
class CZones
{
private:
    // Symbol and timeframe
    string            m_symbol;
    ENUM_TIMEFRAMES   m_timeframe;
    double            m_point;
    int               m_digits;

    // Context calculator
    CContext          m_context;

    // Zone arrays
    Zone              m_HSZones[];      // High Swing zones
    Zone              m_LSZones[];      // Low Swing zones

    // Cluster arrays
    ZoneCluster       m_clusters[];

    // Global time tracking for new zones
    datetime          m_lastHSZoneTime;
    datetime          m_lastLSZoneTime;

    // Zone parameters
    bool              m_deleteBreached;
    bool              m_zoneVisualisation;
    bool              m_deleteZoneVisualisation;

    // Time-based parameters
    int               m_minPreApexBars;
    int               m_minPostApexBars;
    int               m_maxPostApexBars;
    int               m_lookBackPeriod;
    int               m_bodyTipScanRange;

    // Price-based parameters
    DepthMode         m_minDepthsMode;
    double            m_minDepthModeValue;
    ContextType       m_minDepthContextType;
    int               m_minDepthContextSize;

    double            m_minPreApexCloserDepth;
    double            m_minPreApexFartherDepth;
    double            m_minPostApexCloserDepth;
    double            m_minPostApexFartherDepth;

    DepthMode         m_maxDepthMode;
    double            m_maxDepthModeValue;
    ContextType       m_maxDepthContextType;
    int               m_maxDepthContextSize;
    double            m_maxPostApexFartherDepth;

    double            m_extension;

    // Cluster parameters
    double            m_clusterExtension;
    int               m_minZoneCount;
    int               m_maxZoneCount;
    int               m_clusterExpiry;
    bool              m_clusterVisualisation;
    bool              m_deleteClusterVisualisation;

    // Visualization colors
    color             m_HSZoneColor;
    color             m_LSZoneColor;
    color             m_clusterColor;

    // Helper functions
    int               iHighestCustom(string symbol, ENUM_TIMEFRAMES timeframe, int type, int count, int start, double &result);
    int               iLowestCustom(string symbol, ENUM_TIMEFRAMES timeframe, int type, int count, int start, double &result);

    // Zone scanning helpers
    bool              ScanHighSwingZones(int initialZoneCount);
    bool              ScanLowSwingZones(int initialZoneCount);

    // Zone validation helpers
    bool              ValidateHSZoneDepths(int index);
    bool              ValidateLSZoneDepths(int index);
    void              CalculateHSBodyApex(int index);
    void              CalculateLSBodyApex(int index);

    // Visualization functions
    void              CreateZoneVisualization(const Zone &zone, bool isHighSwing);
    void              TerminateZoneVisualization(string visualRef, datetime endTime);
    void              DeleteZoneVisualization(string visualRef);
    void              CreateClusterVisualization(ZoneCluster &cluster);
    void              UpdateClusterVisualization(ZoneCluster &cluster);
    void              TerminateClusterVisualization(string visualRef, datetime endTime);
    void              DeleteClusterVisualization(string visualRef);

    // Cluster helpers
    void              PrepareMakeshiftArray(MakeshiftZone &makeshift[]);
    void              RemoveClusteredZones(MakeshiftZone &makeshift[]);

public:
    // Constructor and Destructor
                     CZones(void);
                    ~CZones(void);

    // Initialization
    bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe);

    // Parameter setters (to be called after Initialize, before first scan)
    void              SetZoneParameters(bool deleteBreached, bool zoneVis, bool deleteZoneVis,
                                       int minPreApexBars, int minPostApexBars, int maxPostApexBars,
                                       int lookBackPeriod, int bodyTipScanRange);

    void              SetMinDepthParameters(DepthMode mode, double modeValue, ContextType contextType,
                                           int contextSize, double preApexCloser, double preApexFarther,
                                           double postApexCloser, double postApexFarther);

    void              SetMaxDepthParameters(DepthMode mode, double modeValue, ContextType contextType,
                                           int contextSize, double postApexFarther, double extension);

    void              SetClusterParameters(double clusterExt, int minCount, int maxCount, int expiry,
                                          bool clusterVis, bool deleteClusterVis);

    // Main scanning and updating functions
    bool              ScanZones();
    void              UpdateZones();

    // Cluster functions
    bool              ScanClusters();
    void              UpdateClusters();

    // Helper to check if new zones were added
    bool              CheckNewZonesAdded();
    void              UpdateLastZoneTimes();

    // Cleanup
    void              DeleteAllVisualizations();

    // Getters - manual copy (ArrayCopy doesn't work with structure arrays containing objects)
    void              GetHSZones(Zone &outputZones[])
    {
        int size = ArraySize(m_HSZones);
        ArrayResize(outputZones, size);
        for(int i = 0; i < size; i++)
            outputZones[i] = m_HSZones[i];
    }

    void              GetLSZones(Zone &outputZones[])
    {
        int size = ArraySize(m_LSZones);
        ArrayResize(outputZones, size);
        for(int i = 0; i < size; i++)
            outputZones[i] = m_LSZones[i];
    }

    void              GetClusters(ZoneCluster &clusters[])
    {
        int size = ArraySize(m_clusters);
        ArrayResize(clusters, size);
        for(int i = 0; i < size; i++)
            clusters[i] = m_clusters[i];
    }

    int               GetHSZoneCount() { return ArraySize(m_HSZones); }
    int               GetLSZoneCount() { return ArraySize(m_LSZones); }
    int               GetClusterCount() { return ArraySize(m_clusters); }

    // Direct access methods (more efficient than copying)
    bool              GetHSZone(int index, Zone &zone)
    {
        if(index < 0 || index >= ArraySize(m_HSZones)) return false;
        zone = m_HSZones[index];
        return true;
    }

    bool              GetLSZone(int index, Zone &zone)
    {
        if(index < 0 || index >= ArraySize(m_LSZones)) return false;
        zone = m_LSZones[index];
        return true;
    }

    bool              GetCluster(int index, ZoneCluster &cluster)
    {
        if(index < 0 || index >= ArraySize(m_clusters)) return false;
        cluster = m_clusters[index];
        return true;
    }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CZones::CZones(void) : m_symbol(""),
                        m_timeframe(PERIOD_CURRENT),
                        m_point(0.0),
                        m_digits(0),
                        m_lastHSZoneTime(0),
                        m_lastLSZoneTime(0),
                        m_deleteBreached(true),
                        m_zoneVisualisation(true),
                        m_deleteZoneVisualisation(true),
                        m_minPreApexBars(1),
                        m_minPostApexBars(1),
                        m_maxPostApexBars(0),
                        m_lookBackPeriod(10),
                        m_bodyTipScanRange(5),
                        m_minDepthsMode(CONTEXT),
                        m_minDepthModeValue(0.0),
                        m_minDepthContextType(PRECEEDING_BARS_RANGE),
                        m_minDepthContextSize(0),
                        m_minPreApexCloserDepth(0.0),
                        m_minPreApexFartherDepth(0.0),
                        m_minPostApexCloserDepth(0.0),
                        m_minPostApexFartherDepth(0.0),
                        m_maxDepthMode(CONTEXT),
                        m_maxDepthModeValue(0.0),
                        m_maxDepthContextType(PRECEEDING_BARS_RANGE),
                        m_maxDepthContextSize(0),
                        m_maxPostApexFartherDepth(0.0),
                        m_extension(0.0),
                        m_clusterExtension(0.0),
                        m_minZoneCount(0),
                        m_maxZoneCount(2),
                        m_clusterExpiry(0),
                        m_clusterVisualisation(true),
                        m_deleteClusterVisualisation(true),
                        m_HSZoneColor(clrLimeGreen),
                        m_LSZoneColor(clrCrimson),
                        m_clusterColor(clrDodgerBlue)
{
    ArrayResize(m_HSZones, 0);
    ArrayResize(m_LSZones, 0);
    ArrayResize(m_clusters, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CZones::~CZones(void)
{
    // Clean up all visualizations
    for(int i = 0; i < ArraySize(m_HSZones); i++)
    {
        if(m_HSZones[i].visualRef != "")
            DeleteZoneVisualization(m_HSZones[i].visualRef);
    }

    for(int i = 0; i < ArraySize(m_LSZones); i++)
    {
        if(m_LSZones[i].visualRef != "")
            DeleteZoneVisualization(m_LSZones[i].visualRef);
    }

    for(int i = 0; i < ArraySize(m_clusters); i++)
    {
        if(m_clusters[i].visualRef != "")
            DeleteClusterVisualization(m_clusters[i].visualRef);
    }

    ArrayFree(m_HSZones);
    ArrayFree(m_LSZones);
    ArrayFree(m_clusters);
}

//+------------------------------------------------------------------+
//| Initialize the zones system                                     |
//+------------------------------------------------------------------+
bool CZones::Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
{
    m_symbol = symbol;
    m_timeframe = timeframe;
    m_point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    m_digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

    // Initialize context calculator
    if(!m_context.Initialize(symbol, timeframe))
    {
        Print("Zones: Failed to initialize context calculator for ", symbol);
        return false;
    }

    Print("Zones: Initialized for ", symbol, " on ", EnumToString(timeframe));
    return true;
}

//+------------------------------------------------------------------+
//| Set zone parameters                                             |
//+------------------------------------------------------------------+
void CZones::SetZoneParameters(bool deleteBreached, bool zoneVis, bool deleteZoneVis,
                               int minPreApexBars, int minPostApexBars, int maxPostApexBars,
                               int lookBackPeriod, int bodyTipScanRange)
{
    m_deleteBreached = deleteBreached;
    m_zoneVisualisation = zoneVis;
    m_deleteZoneVisualisation = deleteZoneVis;
    m_minPreApexBars = MathMax(1, minPreApexBars);
    m_minPostApexBars = MathMax(1, minPostApexBars);
    m_maxPostApexBars = MathMax(0, maxPostApexBars);
    m_lookBackPeriod = MathMax(10, lookBackPeriod);
    m_bodyTipScanRange = MathMax(5, bodyTipScanRange);
}

//+------------------------------------------------------------------+
//| Set minimum depth parameters                                    |
//+------------------------------------------------------------------+
void CZones::SetMinDepthParameters(DepthMode mode, double modeValue, ContextType contextType,
                                   int contextSize, double preApexCloser, double preApexFarther,
                                   double postApexCloser, double postApexFarther)
{
    m_minDepthsMode = mode;
    m_minDepthModeValue = modeValue;
    m_minDepthContextType = contextType;
    m_minDepthContextSize = contextSize;
    m_minPreApexCloserDepth = preApexCloser;
    m_minPreApexFartherDepth = preApexFarther;
    m_minPostApexCloserDepth = postApexCloser;
    m_minPostApexFartherDepth = postApexFarther;
}

//+------------------------------------------------------------------+
//| Set maximum depth parameters                                    |
//+------------------------------------------------------------------+
void CZones::SetMaxDepthParameters(DepthMode mode, double modeValue, ContextType contextType,
                                   int contextSize, double postApexFarther, double extension)
{
    m_maxDepthMode = mode;
    m_maxDepthModeValue = modeValue;
    m_maxDepthContextType = contextType;
    m_maxDepthContextSize = contextSize;
    m_maxPostApexFartherDepth = postApexFarther;
    m_extension = extension;
}

//+------------------------------------------------------------------+
//| Set cluster parameters                                          |
//+------------------------------------------------------------------+
void CZones::SetClusterParameters(double clusterExt, int minCount, int maxCount, int expiry,
                                  bool clusterVis, bool deleteClusterVis)
{
    m_clusterExtension = clusterExt * m_point;
    m_minZoneCount = MathMax(0, minCount);
    m_maxZoneCount = MathMax(2, maxCount);
    m_clusterExpiry = MathMax(0, expiry);
    m_clusterVisualisation = clusterVis;
    m_deleteClusterVisualisation = deleteClusterVis;
}

//+------------------------------------------------------------------+
//| Custom iHighest that returns smallest index for equal values    |
//+------------------------------------------------------------------+
int CZones::iHighestCustom(string symbol, ENUM_TIMEFRAMES timeframe, int type, int count, int start, double &result)
{
    if(count <= 0)
        return -1;

    int highestIndex = -1;
    double highestValue = -DBL_MAX;

    for(int i = 0; i < count; i++)
    {
        int shift = start + i;
        double value = 0.0;

        switch(type)
        {
            case MODE_HIGH:
                value = iHigh(symbol, timeframe, shift);
                break;
            case MODE_LOW:
                value = iLow(symbol, timeframe, shift);
                break;
            case MODE_CLOSE:
                value = iClose(symbol, timeframe, shift);
                break;
            case MODE_OPEN:
                value = iOpen(symbol, timeframe, shift);
                break;
            default:
                return -1;
        }

        // Use >= to get smallest index for equal values
        if(value >= highestValue)
        {
            highestValue = value;
            highestIndex = shift;
        }
    }

    result = highestValue;
    return highestIndex;
}

//+------------------------------------------------------------------+
//| Custom iLowest that returns smallest index for equal values     |
//+------------------------------------------------------------------+
int CZones::iLowestCustom(string symbol, ENUM_TIMEFRAMES timeframe, int type, int count, int start, double &result)
{
    if(count <= 0)
        return -1;

    int lowestIndex = -1;
    double lowestValue = DBL_MAX;

    for(int i = 0; i < count; i++)
    {
        int shift = start + i;
        double value = 0.0;

        switch(type)
        {
            case MODE_HIGH:
                value = iHigh(symbol, timeframe, shift);
                break;
            case MODE_LOW:
                value = iLow(symbol, timeframe, shift);
                break;
            case MODE_CLOSE:
                value = iClose(symbol, timeframe, shift);
                break;
            case MODE_OPEN:
                value = iOpen(symbol, timeframe, shift);
                break;
            default:
                return -1;
        }

        // Use <= to get smallest index for equal values
        if(value <= lowestValue)
        {
            lowestValue = value;
            lowestIndex = shift;
        }
    }

    result = lowestValue;
    return lowestIndex;
}

//+------------------------------------------------------------------+
//| Main zone scanning function                                     |
//+------------------------------------------------------------------+
bool CZones::ScanZones()
{
    // Store initial zone counts
    int initialHSCount = ArraySize(m_HSZones);
    int initialLSCount = ArraySize(m_LSZones);

    // Scan for high swing zones
    if(!ScanHighSwingZones(initialHSCount))
    {
        Print("Zones: Error scanning high swing zones");
        return false;
    }

    // Scan for low swing zones
    if(!ScanLowSwingZones(initialLSCount))
    {
        Print("Zones: Error scanning low swing zones");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Scan for High Swing zones - PHASE 1, 2, 3                       |
//+------------------------------------------------------------------+
bool CZones::ScanHighSwingZones(int initialZoneCount)
{
    // Determine earliest shift to scan from
    int earliestShift = m_lookBackPeriod;

    // If zones exist, limit scan to last zone time
    if(ArraySize(m_HSZones) > 0)
    {
        datetime lastZoneTime = m_HSZones[ArraySize(m_HSZones) - 1].zoneTime;
        int lastZoneShift = iBarShift(m_symbol, m_timeframe, lastZoneTime);
        if(lastZoneShift >= 0)
            earliestShift = MathMin(earliestShift, lastZoneShift);
    }

    // PHASE 1: Scan for potential zones based on time criteria
    for(int i = m_minPostApexBars; i <= earliestShift - m_minPreApexBars; )
    {
        // Check minPreApexBars condition
        double resultHigh = 0.0;
        int preApexHighest = iHighestCustom(m_symbol, m_timeframe, MODE_HIGH, m_minPreApexBars, i + 1, resultHigh);

        if(preApexHighest < 0)
        {
            i++;
            continue;
        }

        double currentHigh = iHigh(m_symbol, m_timeframe, i);

        if(resultHigh > currentHigh)
        {
            // Higher high found in pre-apex bars, skip to that position
            i = preApexHighest;
            continue;
        }

        // Check minPostApexBars condition
        double postResultHigh = 0.0;
        int postApexHighest = iHighestCustom(m_symbol, m_timeframe, MODE_HIGH, m_minPostApexBars, MathMax(1, i - m_minPostApexBars), postResultHigh);

        if(postApexHighest < 0)
        {
            i++;
            continue;
        }

        if(postResultHigh <= currentHigh)
        {
            // Valid time-based zone found, add to array
            int newSize = ArraySize(m_HSZones) + 1;
            ArrayResize(m_HSZones, newSize);

            int idx = newSize - 1;
            m_HSZones[idx].apex = currentHigh;
            m_HSZones[idx].zoneTime = iTime(m_symbol, m_timeframe, i);
            m_HSZones[idx].bodyApex = 0.0;  // Will be calculated later
            m_HSZones[idx].lowRange = 0.0;
            m_HSZones[idx].highRange = 0.0;
            m_HSZones[idx].breachValue = 0.0;
            m_HSZones[idx].maxPostApexFartherDepth = 0.0;
            m_HSZones[idx].visualRef = "";

            i = i + m_minPostApexBars + 1;
        }
        else
        {
            i++;
        }
    }

    // PHASE 2 & 3: Validate new zones and calculate parameters
    for(int i = initialZoneCount; i < ArraySize(m_HSZones); i++)
    {
        // Validate depth requirements
        if(!ValidateHSZoneDepths(i))
        {
            // Remove invalid zone
            ArrayRemove(m_HSZones, i, 1);
            i--;  // Adjust index after removal
            continue;
        }

        // Calculate body apex
        CalculateHSBodyApex(i);

        // Calculate ranges
        m_HSZones[i].highRange = m_HSZones[i].apex + m_extension;
        m_HSZones[i].lowRange = m_HSZones[i].bodyApex - m_extension;

        // Calculate max depth for updates
        int zoneShift = iBarShift(m_symbol, m_timeframe, m_HSZones[i].zoneTime);
        double contextValue = 0.0;

        if(m_maxDepthMode == CONTEXT)
        {
            if(m_maxDepthContextType == PRECEEDING_BARS_RANGE)
                contextValue = m_context.CalculateContext((CContext::ContextType)0, m_maxDepthContextSize, zoneShift);
            else
                contextValue = m_context.CalculateContextATR(m_maxDepthContextSize, zoneShift);

            m_HSZones[i].maxPostApexFartherDepth = m_HSZones[i].apex - m_context.GetContextPercentage(contextValue, m_maxDepthModeValue);
        }
        else
        {
            m_HSZones[i].maxPostApexFartherDepth = m_HSZones[i].apex - (m_maxDepthModeValue * m_point);
        }

        // Create visualization if enabled
        if(m_zoneVisualisation)
        {
            // Store visual ref before creating
            string objName = StringFormat("Zone_%s_HS_%d", m_symbol, (int)m_HSZones[i].zoneTime);
            m_HSZones[i].visualRef = objName;
            CreateZoneVisualization(m_HSZones[i], true);
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Scan for Low Swing zones                                        |
//+------------------------------------------------------------------+
bool CZones::ScanLowSwingZones(int initialZoneCount)
{
    // Similar to HighSwing but for lows
    int earliestShift = m_lookBackPeriod;

    if(ArraySize(m_LSZones) > 0)
    {
        datetime lastZoneTime = m_LSZones[ArraySize(m_LSZones) - 1].zoneTime;
        int lastZoneShift = iBarShift(m_symbol, m_timeframe, lastZoneTime);
        if(lastZoneShift >= 0)
            earliestShift = MathMin(earliestShift, lastZoneShift);
    }

    // PHASE 1: Scan for potential zones
    for(int i = m_minPostApexBars; i <= earliestShift - m_minPreApexBars; )
    {
        double resultLow = 0.0;
        int preApexLowest = iLowestCustom(m_symbol, m_timeframe, MODE_LOW, m_minPreApexBars, i + 1, resultLow);

        if(preApexLowest < 0)
        {
            i++;
            continue;
        }

        double currentLow = iLow(m_symbol, m_timeframe, i);

        if(resultLow < currentLow)
        {
            i = preApexLowest;
            continue;
        }

        double postResultLow = 0.0;
        int postApexLowest = iLowestCustom(m_symbol, m_timeframe, MODE_LOW, m_minPostApexBars, MathMax(1, i - m_minPostApexBars), postResultLow);

        if(postApexLowest < 0)
        {
            i++;
            continue;
        }

        if(postResultLow >= currentLow)
        {
            int newSize = ArraySize(m_LSZones) + 1;
            ArrayResize(m_LSZones, newSize);

            int idx = newSize - 1;
            m_LSZones[idx].apex = currentLow;
            m_LSZones[idx].zoneTime = iTime(m_symbol, m_timeframe, i);
            m_LSZones[idx].bodyApex = 0.0;
            m_LSZones[idx].lowRange = 0.0;
            m_LSZones[idx].highRange = 0.0;
            m_LSZones[idx].breachValue = 0.0;
            m_LSZones[idx].maxPostApexFartherDepth = 0.0;
            m_LSZones[idx].visualRef = "";

            i = i + m_minPostApexBars + 1;
        }
        else
        {
            i++;
        }
    }

    // PHASE 2 & 3: Validate
    for(int i = initialZoneCount; i < ArraySize(m_LSZones); i++)
    {
        if(!ValidateLSZoneDepths(i))
        {
            ArrayRemove(m_LSZones, i, 1);
            i--;
            continue;
        }

        CalculateLSBodyApex(i);

        m_LSZones[i].lowRange = m_LSZones[i].apex - m_extension;
        m_LSZones[i].highRange = m_LSZones[i].bodyApex + m_extension;

        int zoneShift = iBarShift(m_symbol, m_timeframe, m_LSZones[i].zoneTime);
        double contextValue = 0.0;

        if(m_maxDepthMode == CONTEXT)
        {
            if(m_maxDepthContextType == PRECEEDING_BARS_RANGE)
                contextValue = m_context.CalculateContext((CContext::ContextType)0, m_maxDepthContextSize, zoneShift);
            else
                contextValue = m_context.CalculateContextATR(m_maxDepthContextSize, zoneShift);

            m_LSZones[i].maxPostApexFartherDepth = m_LSZones[i].apex + m_context.GetContextPercentage(contextValue, m_maxDepthModeValue);
        }
        else
        {
            m_LSZones[i].maxPostApexFartherDepth = m_LSZones[i].apex + (m_maxDepthModeValue * m_point);
        }

        if(m_zoneVisualisation)
        {
            // Store visual ref before creating
            string objName = StringFormat("Zone_%s_LS_%d", m_symbol, (int)m_LSZones[i].zoneTime);
            m_LSZones[i].visualRef = objName;
            CreateZoneVisualization(m_LSZones[i], false);
        }
    }

    return true;
}

//+------------------------------------------------------------------+
//| Validate High Swing zone depths - PHASE 2                       |
//+------------------------------------------------------------------+
bool CZones::ValidateHSZoneDepths(int index)
{
    int zoneShift = iBarShift(m_symbol, m_timeframe, m_HSZones[index].zoneTime);
    if(zoneShift < 0)
        return false;

    double apex = m_HSZones[index].apex;

    // Calculate context for depth calculations if needed
    double contextValue = 0.0;
    if(m_minDepthsMode == CONTEXT)
    {
        if(m_minDepthContextType == PRECEEDING_BARS_RANGE)
            contextValue = m_context.CalculateContext((CContext::ContextType)0, m_minDepthContextSize, zoneShift);
        else
            contextValue = m_context.CalculateContextATR(m_minDepthContextSize, zoneShift);
    }

    // Calculate minimum depth price levels
    double minPreApexCloserPrice = 0.0, minPreApexFartherPrice = 0.0;
    double minPostApexCloserPrice = 0.0, minPostApexFartherPrice = 0.0;

    if(m_minPreApexCloserDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPreApexCloserPrice = apex - m_context.GetContextPercentage(contextValue, m_minPreApexCloserDepth);
        else
            minPreApexCloserPrice = apex - (m_minPreApexCloserDepth * m_point);
    }

    if(m_minPreApexFartherDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPreApexFartherPrice = apex - m_context.GetContextPercentage(contextValue, m_minPreApexFartherDepth);
        else
            minPreApexFartherPrice = apex - (m_minPreApexFartherDepth * m_point);
    }

    if(m_minPostApexCloserDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPostApexCloserPrice = apex - m_context.GetContextPercentage(contextValue, m_minPostApexCloserDepth);
        else
            minPostApexCloserPrice = apex - (m_minPostApexCloserDepth * m_point);
    }

    if(m_minPostApexFartherDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPostApexFartherPrice = apex - m_context.GetContextPercentage(contextValue, m_minPostApexFartherDepth);
        else
            minPostApexFartherPrice = apex - (m_minPostApexFartherDepth * m_point);
    }

    // Evaluate actual depths
    double preApexCloserDepth = DBL_MAX, preApexFartherDepth = DBL_MAX;
    double postApexCloserDepth = DBL_MAX, postApexFartherDepth = DBL_MAX;

    // Pre-apex measurements
    bool foundPreApexBoundary = false;
    for(int j = index - 1; j >= 0; j--)
    {
        if(m_HSZones[j].apex > apex)
        {
            int jShift = iBarShift(m_symbol, m_timeframe, m_HSZones[j].zoneTime);
            if(jShift >= 0 && jShift > zoneShift)
            {
                // Scan from zone to j for depths
                int scanStart = jShift;
                int scanEnd = zoneShift;
                int scanCount = scanStart - scanEnd + 1;

                int closerIdx = iLowest(m_symbol, m_timeframe, MODE_HIGH, scanCount, scanEnd);
                int fartherIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, scanCount, scanEnd);

                if(closerIdx >= 0)
                    preApexCloserDepth = iHigh(m_symbol, m_timeframe, closerIdx);
                if(fartherIdx >= 0)
                    preApexFartherDepth = iLow(m_symbol, m_timeframe, fartherIdx);

                foundPreApexBoundary = true;
                break;
            }
        }
    }

    if(!foundPreApexBoundary)
    {
        // Scan from zoneShift to lookBackPeriod
        int scanCount = m_lookBackPeriod - zoneShift;
        if(scanCount > 0)
        {
            int closerIdx = iLowest(m_symbol, m_timeframe, MODE_HIGH, scanCount, zoneShift);
            int fartherIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, scanCount, zoneShift);

            if(closerIdx >= 0)
                preApexCloserDepth = iHigh(m_symbol, m_timeframe, closerIdx);
            if(fartherIdx >= 0)
                preApexFartherDepth = iLow(m_symbol, m_timeframe, fartherIdx);
        }
    }

    // Post-apex measurements
    bool foundPostApexBoundary = false;
    for(int j = index + 1; j < ArraySize(m_HSZones); j++)
    {
        if(m_HSZones[j].apex > apex)
        {
            int jShift = iBarShift(m_symbol, m_timeframe, m_HSZones[j].zoneTime);
            if(jShift >= 0 && jShift < zoneShift)
            {
                int scanStart = zoneShift;
                int scanEnd = jShift;
                int scanCount = scanStart - scanEnd + 1;

                int closerIdx = iLowest(m_symbol, m_timeframe, MODE_HIGH, scanCount, scanEnd);
                int fartherIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, scanCount, scanEnd);

                if(closerIdx >= 0)
                    postApexCloserDepth = iHigh(m_symbol, m_timeframe, closerIdx);
                if(fartherIdx >= 0)
                    postApexFartherDepth = iLow(m_symbol, m_timeframe, fartherIdx);

                foundPostApexBoundary = true;
                break;
            }
        }
    }

    if(!foundPostApexBoundary)
    {
        // Scan from zoneShift to shift 1
        if(zoneShift > 1)
        {
            int scanCount = zoneShift - 1;
            int closerIdx = iLowest(m_symbol, m_timeframe, MODE_HIGH, scanCount, 1);
            int fartherIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, scanCount, 1);

            if(closerIdx >= 0)
                postApexCloserDepth = iHigh(m_symbol, m_timeframe, closerIdx);
            if(fartherIdx >= 0)
                postApexFartherDepth = iLow(m_symbol, m_timeframe, fartherIdx);
        }
    }

    // Calculate breach value
    if(zoneShift > 1)
    {
        int breachIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, zoneShift - 1, 1);
        if(breachIdx >= 0)
            m_HSZones[index].breachValue = iHigh(m_symbol, m_timeframe, breachIdx);
    }

    // Check depth requirements
    if(m_minPreApexCloserDepth > 0 && preApexCloserDepth > minPreApexCloserPrice)
        return false;
    if(m_minPreApexFartherDepth > 0 && preApexFartherDepth > minPreApexFartherPrice)
        return false;
    if(m_minPostApexCloserDepth > 0 && postApexCloserDepth > minPostApexCloserPrice)
        return false;
    if(m_minPostApexFartherDepth > 0 && postApexFartherDepth > minPostApexFartherPrice)
        return false;

    // Check breach condition
    if(m_deleteBreached && m_HSZones[index].breachValue >= apex)
        return false;

    return true;
}

//+------------------------------------------------------------------+
//| Validate Low Swing zone depths                                  |
//+------------------------------------------------------------------+
bool CZones::ValidateLSZoneDepths(int index)
{
    int zoneShift = iBarShift(m_symbol, m_timeframe, m_LSZones[index].zoneTime);
    if(zoneShift < 0)
        return false;

    double apex = m_LSZones[index].apex;

    double contextValue = 0.0;
    if(m_minDepthsMode == CONTEXT)
    {
        if(m_minDepthContextType == PRECEEDING_BARS_RANGE)
            contextValue = m_context.CalculateContext((CContext::ContextType)0, m_minDepthContextSize, zoneShift);
        else
            contextValue = m_context.CalculateContextATR(m_minDepthContextSize, zoneShift);
    }

    double minPreApexCloserPrice = 0.0, minPreApexFartherPrice = 0.0;
    double minPostApexCloserPrice = 0.0, minPostApexFartherPrice = 0.0;

    if(m_minPreApexCloserDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPreApexCloserPrice = apex + m_context.GetContextPercentage(contextValue, m_minPreApexCloserDepth);
        else
            minPreApexCloserPrice = apex + (m_minPreApexCloserDepth * m_point);
    }

    if(m_minPreApexFartherDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPreApexFartherPrice = apex + m_context.GetContextPercentage(contextValue, m_minPreApexFartherDepth);
        else
            minPreApexFartherPrice = apex + (m_minPreApexFartherDepth * m_point);
    }

    if(m_minPostApexCloserDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPostApexCloserPrice = apex + m_context.GetContextPercentage(contextValue, m_minPostApexCloserDepth);
        else
            minPostApexCloserPrice = apex + (m_minPostApexCloserDepth * m_point);
    }

    if(m_minPostApexFartherDepth > 0)
    {
        if(m_minDepthsMode == CONTEXT)
            minPostApexFartherPrice = apex + m_context.GetContextPercentage(contextValue, m_minPostApexFartherDepth);
        else
            minPostApexFartherPrice = apex + (m_minPostApexFartherDepth * m_point);
    }

    double preApexCloserDepth = -DBL_MAX, preApexFartherDepth = -DBL_MAX;
    double postApexCloserDepth = -DBL_MAX, postApexFartherDepth = -DBL_MAX;

    // Pre-apex measurements (for LS: look for lower apex)
    bool foundPreApexBoundary = false;
    for(int j = index - 1; j >= 0; j--)
    {
        if(m_LSZones[j].apex < apex)
        {
            int jShift = iBarShift(m_symbol, m_timeframe, m_LSZones[j].zoneTime);
            if(jShift >= 0 && jShift > zoneShift)
            {
                int scanStart = jShift;
                int scanEnd = zoneShift;
                int scanCount = scanStart - scanEnd + 1;

                int closerIdx = iHighest(m_symbol, m_timeframe, MODE_LOW, scanCount, scanEnd);
                int fartherIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, scanCount, scanEnd);

                if(closerIdx >= 0)
                    preApexCloserDepth = iLow(m_symbol, m_timeframe, closerIdx);
                if(fartherIdx >= 0)
                    preApexFartherDepth = iHigh(m_symbol, m_timeframe, fartherIdx);

                foundPreApexBoundary = true;
                break;
            }
        }
    }

    if(!foundPreApexBoundary)
    {
        int scanCount = m_lookBackPeriod - zoneShift;
        if(scanCount > 0)
        {
            int closerIdx = iHighest(m_symbol, m_timeframe, MODE_LOW, scanCount, zoneShift);
            int fartherIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, scanCount, zoneShift);

            if(closerIdx >= 0)
                preApexCloserDepth = iLow(m_symbol, m_timeframe, closerIdx);
            if(fartherIdx >= 0)
                preApexFartherDepth = iHigh(m_symbol, m_timeframe, fartherIdx);
        }
    }

    // Post-apex measurements
    bool foundPostApexBoundary = false;
    for(int j = index + 1; j < ArraySize(m_LSZones); j++)
    {
        if(m_LSZones[j].apex < apex)
        {
            int jShift = iBarShift(m_symbol, m_timeframe, m_LSZones[j].zoneTime);
            if(jShift >= 0 && jShift < zoneShift)
            {
                int scanStart = zoneShift;
                int scanEnd = jShift;
                int scanCount = scanStart - scanEnd + 1;

                int closerIdx = iHighest(m_symbol, m_timeframe, MODE_LOW, scanCount, scanEnd);
                int fartherIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, scanCount, scanEnd);

                if(closerIdx >= 0)
                    postApexCloserDepth = iLow(m_symbol, m_timeframe, closerIdx);
                if(fartherIdx >= 0)
                    postApexFartherDepth = iHigh(m_symbol, m_timeframe, fartherIdx);

                foundPostApexBoundary = true;
                break;
            }
        }
    }

    if(!foundPostApexBoundary)
    {
        if(zoneShift > 1)
        {
            int scanCount = zoneShift - 1;
            int closerIdx = iHighest(m_symbol, m_timeframe, MODE_LOW, scanCount, 1);
            int fartherIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, scanCount, 1);

            if(closerIdx >= 0)
                postApexCloserDepth = iLow(m_symbol, m_timeframe, closerIdx);
            if(fartherIdx >= 0)
                postApexFartherDepth = iHigh(m_symbol, m_timeframe, fartherIdx);
        }
    }

    // Calculate breach value
    if(zoneShift > 1)
    {
        int breachIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, zoneShift - 1, 1);
        if(breachIdx >= 0)
            m_LSZones[index].breachValue = iLow(m_symbol, m_timeframe, breachIdx);
    }

    // Check depth requirements (inverted for LS)
    if(m_minPreApexCloserDepth > 0 && preApexCloserDepth < minPreApexCloserPrice)
        return false;
    if(m_minPreApexFartherDepth > 0 && preApexFartherDepth < minPreApexFartherPrice)
        return false;
    if(m_minPostApexCloserDepth > 0 && postApexCloserDepth < minPostApexCloserPrice)
        return false;
    if(m_minPostApexFartherDepth > 0 && postApexFartherDepth < minPostApexFartherPrice)
        return false;

    // Check breach condition
    if(m_deleteBreached && m_LSZones[index].breachValue <= apex)
        return false;

    return true;
}

//+------------------------------------------------------------------+
//| Calculate body apex for High Swing zone - PHASE 3               |
//+------------------------------------------------------------------+
void CZones::CalculateHSBodyApex(int index)
{
    int zoneShift = iBarShift(m_symbol, m_timeframe, m_HSZones[index].zoneTime);
    if(zoneShift < 0)
        return;

    // Get initial body high
    double iBodyHigh = MathMax(iOpen(m_symbol, m_timeframe, zoneShift), iClose(m_symbol, m_timeframe, zoneShift));
    double bodyApex = iBodyHigh;
    int bodyIndex = zoneShift;

    // Scan right (towards shift 0)
    int rightLimit = MathMax(1, zoneShift - m_bodyTipScanRange);
    for(int j = zoneShift - 1; j >= rightLimit; j--)
    {
        double jBodyHigh = MathMax(iOpen(m_symbol, m_timeframe, j), iClose(m_symbol, m_timeframe, j));
        if(jBodyHigh >= iBodyHigh)
        {
            if(jBodyHigh > bodyApex)
            {
                bodyApex = jBodyHigh;
                bodyIndex = j;
            }
        }
        else
        {
            break;
        }
    }

    // Scan left (away from shift 0)
    int leftLimit = zoneShift + m_bodyTipScanRange;
    for(int j = zoneShift + 1; j <= leftLimit; j++)
    {
        double jBodyHigh = MathMax(iOpen(m_symbol, m_timeframe, j), iClose(m_symbol, m_timeframe, j));
        if(jBodyHigh >= iBodyHigh)
        {
            if(jBodyHigh > bodyApex)
            {
                bodyApex = jBodyHigh;
                bodyIndex = j;
            }
        }
        else
        {
            break;
        }
    }

    // Write values to zone structure entry
    m_HSZones[index].bodyApex = bodyApex;
    m_HSZones[index].bodyTime = iTime(m_symbol, m_timeframe, bodyIndex);
}

//+------------------------------------------------------------------+
//| Calculate body apex for Low Swing zone                          |
//+------------------------------------------------------------------+
void CZones::CalculateLSBodyApex(int index)
{
    int zoneShift = iBarShift(m_symbol, m_timeframe, m_LSZones[index].zoneTime);
    if(zoneShift < 0)
        return;

    double iBodyLow = MathMin(iOpen(m_symbol, m_timeframe, zoneShift), iClose(m_symbol, m_timeframe, zoneShift));
    double bodyApex = iBodyLow;
    int bodyIndex = zoneShift;

    // Scan right
    int rightLimit = MathMax(1, zoneShift - m_bodyTipScanRange);
    for(int j = zoneShift - 1; j >= rightLimit; j--)
    {
        double jBodyLow = MathMin(iOpen(m_symbol, m_timeframe, j), iClose(m_symbol, m_timeframe, j));
        if(jBodyLow <= iBodyLow)
        {
            if(jBodyLow < bodyApex)
            {
                bodyApex = jBodyLow;
                bodyIndex = j;
            }
        }
        else
        {
            break;
        }
    }

    // Scan left
    int leftLimit = zoneShift + m_bodyTipScanRange;
    for(int j = zoneShift + 1; j <= leftLimit; j++)
    {
        double jBodyLow = MathMin(iOpen(m_symbol, m_timeframe, j), iClose(m_symbol, m_timeframe, j));
        if(jBodyLow <= iBodyLow)
        {
            if(jBodyLow < bodyApex)
            {
                bodyApex = jBodyLow;
                bodyIndex = j;
            }
        }
        else
        {
            break;
        }
    }

    // Write values to zone structure entry
    m_LSZones[index].bodyApex = bodyApex;
    m_LSZones[index].bodyTime = iTime(m_symbol, m_timeframe, bodyIndex);
}

//+------------------------------------------------------------------+
//| Update zones - check depth, expiry and breaches                 |
//+------------------------------------------------------------------+
void CZones::UpdateZones()
{
    // Update High Swing zones
    for(int i = ArraySize(m_HSZones) - 1; i >= 0; i--)
    {
        int zoneShift = iBarShift(m_symbol, m_timeframe, m_HSZones[i].zoneTime);
        bool shouldDelete = false;
        int terminateIndex = 1;

        // Check maxPostApexBars (0 means no check)
        if(m_maxPostApexBars > 0 && zoneShift > m_maxPostApexBars)
        {
            shouldDelete = true;
            terminateIndex = zoneShift - m_maxPostApexBars;
        }

        // Update and check breach value
        if(!shouldDelete && zoneShift > 1)
        {
            int breachIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, zoneShift - 1, 1);
            if(breachIdx > 0)
            {
                m_HSZones[i].breachValue = iHigh(m_symbol, m_timeframe, breachIdx);
    
                if(m_deleteBreached && m_HSZones[i].breachValue >= m_HSZones[i].apex)
                {
                    shouldDelete = true;
                    terminateIndex = breachIdx;
                }
            }
         }

        // Check maxPostApexFartherDepth
        if(!shouldDelete && zoneShift > 1 && m_HSZones[i].maxPostApexFartherDepth > 0)
        {
            int depthIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, zoneShift - 1, 1);
            if(depthIdx > 0)
            {
                double currentDepth = iLow(m_symbol, m_timeframe, depthIdx);
                if(currentDepth < m_HSZones[i].maxPostApexFartherDepth)
                {
                    shouldDelete = true;
                }
            }
        }

        if(shouldDelete)
        {
            // Terminate visualization at breach point
            if(!m_deleteZoneVisualisation)
            {
                datetime breachTime = iTime(m_symbol, m_timeframe, terminateIndex);
                TerminateZoneVisualization(m_HSZones[i].visualRef, breachTime);
            }
            else{
                DeleteZoneVisualization(m_HSZones[i].visualRef);
            }
            ArrayRemove(m_HSZones, i, 1);
        }
    }

    // Update Low Swing zones
    for(int i = ArraySize(m_LSZones) - 1; i >= 0; i--)
    {
        int zoneShift = iBarShift(m_symbol, m_timeframe, m_LSZones[i].zoneTime);
        bool shouldDelete = false;
        int terminateIndex = 1;

        // Check maxPostApexBars
        if(m_maxPostApexBars > 0 && zoneShift > m_maxPostApexBars)
        {
            shouldDelete = true;
            terminateIndex = zoneShift - m_maxPostApexBars;
        }

        // Update and check breach value
        if(!shouldDelete && zoneShift > 1)
        {
            int breachIdx = iLowest(m_symbol, m_timeframe, MODE_LOW, zoneShift - 1, 1);
            if(breachIdx > 0)
            {
                m_LSZones[i].breachValue = iLow(m_symbol, m_timeframe, breachIdx);

                if(m_deleteBreached && m_LSZones[i].breachValue <= m_LSZones[i].apex)
                {
                    shouldDelete = true;
                    terminateIndex = breachIdx;
                }
            }
        }

        // Check maxPostApexFartherDepth
        if(!shouldDelete && zoneShift > 1)
        {
            int depthIdx = iHighest(m_symbol, m_timeframe, MODE_HIGH, zoneShift - 1, 1);
            if(depthIdx > 0)
            {
                double currentDepth = iHigh(m_symbol, m_timeframe, depthIdx);
                if(currentDepth >= m_LSZones[i].maxPostApexFartherDepth)
                {
                    shouldDelete = true;
                }
            }
        }

        if(shouldDelete)
        {
            // Terminate visualization at breach point
            if(!m_deleteZoneVisualisation)
            {
                datetime breachTime = iTime(m_symbol, m_timeframe, terminateIndex);
                TerminateZoneVisualization(m_LSZones[i].visualRef, breachTime);
            }
            else{
                DeleteZoneVisualization(m_LSZones[i].visualRef);
            }
            ArrayRemove(m_LSZones, i, 1);
        }
    }
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Check if new zones were added                                   |
//+------------------------------------------------------------------+
bool CZones::CheckNewZonesAdded()
{
    bool newZones = false;

    if(ArraySize(m_HSZones) > 0)
    {
        datetime lastHSTime = m_HSZones[ArraySize(m_HSZones) - 1].zoneTime;
        if(lastHSTime > m_lastHSZoneTime)
            newZones = true;
    }

    if(ArraySize(m_LSZones) > 0)
    {
        datetime lastLSTime = m_LSZones[ArraySize(m_LSZones) - 1].zoneTime;
        if(lastLSTime > m_lastLSZoneTime)
            newZones = true;
    }

    return newZones;
}

//+------------------------------------------------------------------+
//| Update last zone times                                          |
//+------------------------------------------------------------------+
void CZones::UpdateLastZoneTimes()
{
    if(ArraySize(m_HSZones) > 0)
        m_lastHSZoneTime = m_HSZones[ArraySize(m_HSZones) - 1].zoneTime;

    if(ArraySize(m_LSZones) > 0)
        m_lastLSZoneTime = m_LSZones[ArraySize(m_LSZones) - 1].zoneTime;
}

//+------------------------------------------------------------------+
//| Prepare makeshift array for cluster scanning                    |
//+------------------------------------------------------------------+
void CZones::PrepareMakeshiftArray(MakeshiftZone &makeshift[])
{
    ArrayResize(makeshift, 0);

    // Combine both HS and LS zones into makeshift array
    for(int i = 0; i < ArraySize(m_HSZones); i++)
    {
        int size = ArraySize(makeshift);
        ArrayResize(makeshift, size + 1);
        makeshift[size].zoneTime = m_HSZones[i].zoneTime;
        makeshift[size].apex = m_HSZones[i].apex;
        makeshift[size].bodyApex = m_HSZones[i].bodyApex;
    }

    for(int i = 0; i < ArraySize(m_LSZones); i++)
    {
        int size = ArraySize(makeshift);
        ArrayResize(makeshift, size + 1);
        makeshift[size].zoneTime = m_LSZones[i].zoneTime;
        makeshift[size].apex = m_LSZones[i].apex;
        makeshift[size].bodyApex = m_LSZones[i].bodyApex;
    }

    // Sort makeshift array by zoneTime (bubble sort for simplicity)
    int n = ArraySize(makeshift);
    for(int i = 0; i < n - 1; i++)
    {
        for(int j = 0; j < n - i - 1; j++)
        {
            if(makeshift[j].zoneTime > makeshift[j + 1].zoneTime)
            {
                // Swap
                MakeshiftZone temp = makeshift[j];
                makeshift[j] = makeshift[j + 1];
                makeshift[j + 1] = temp;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Remove zones that are already in clusters                       |
//+------------------------------------------------------------------+
void CZones::RemoveClusteredZones(MakeshiftZone &makeshift[])
{
    for(int c = 0; c < ArraySize(m_clusters); c++)
    {
        for(int m = ArraySize(makeshift) - 1; m >= 0; m--)
        {
            double apex = makeshift[m].apex;
            double bodyApex = makeshift[m].bodyApex;

            // Check if apex or bodyApex falls within cluster range
            if((apex >= m_clusters[c].clusterLowerRange && apex <= m_clusters[c].clusterUpperRange) ||
               (bodyApex >= m_clusters[c].clusterLowerRange && bodyApex <= m_clusters[c].clusterUpperRange))
            {
                ArrayRemove(makeshift, m, 1);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Scan for new clusters                                           |
//+------------------------------------------------------------------+
bool CZones::ScanClusters()
{
    // Prepare makeshift array
    MakeshiftZone makeshift[];
    PrepareMakeshiftArray(makeshift);

    // Remove zones already in clusters
    RemoveClusteredZones(makeshift);

    // Scan from last to first in makeshift
    for(int i = ArraySize(makeshift) - 1; i >= 0; )
    {
        int zoneShift = iBarShift(m_symbol, m_timeframe, makeshift[i].zoneTime);

        // Check expiry (0 means no check)
        if(m_clusterExpiry > 0 && zoneShift >= m_clusterExpiry)
        {
            i--;
            continue;
        }

        // Initialize potential cluster
        datetime clusterTime = makeshift[i].zoneTime;
        datetime clusterStartTime = makeshift[i].zoneTime;
        double clusterHighestBody = makeshift[i].bodyApex;
        double clusterLowestTip = makeshift[i].apex;
        double clusterUpperRange = MathMax(clusterLowestTip, clusterHighestBody);
        double clusterLowerRange = MathMin(clusterLowestTip, clusterHighestBody);
        int zoneCount = 1;

        // Remove this zone from makeshift
        ArrayRemove(makeshift, i, 1);

        // Loop through remaining makeshift zones
        for(int j = ArraySize(makeshift) - 1; j >= 0 && zoneCount < m_maxZoneCount; j--)
        {
            double jApex = makeshift[j].apex;
            double jBodyApex = makeshift[j].bodyApex;

            // Check if zone falls within cluster range + extension
            if((jApex >= (clusterLowerRange - m_clusterExtension) && jApex <= (clusterUpperRange + m_clusterExtension)) ||
               (jBodyApex >= (clusterLowerRange - m_clusterExtension) && jBodyApex <= (clusterUpperRange + m_clusterExtension)))
            {
                // Update cluster parameters
                clusterStartTime = makeshift[j].zoneTime;  // Earlier time
                clusterHighestBody = MathMax(clusterHighestBody, jBodyApex);
                clusterLowestTip = MathMin(clusterLowestTip, jApex);
                clusterUpperRange = MathMax(MathMax(clusterUpperRange, jApex), jBodyApex);
                clusterLowerRange = MathMin(MathMin(clusterLowerRange, jApex), jBodyApex);
                zoneCount++;

                // Remove this zone from makeshift
                ArrayRemove(makeshift, j, 1);
            }
        }

        // Check if we have enough zones to form a cluster
        if(zoneCount > m_minZoneCount)
        {
            // Check expiry one more time for latest zone in cluster
            int latestShift = iBarShift(m_symbol, m_timeframe, clusterTime);
            if(m_clusterExpiry == 0 || latestShift < m_clusterExpiry)
            {
                // Add cluster to array
                int clusterSize = ArraySize(m_clusters);
                ArrayResize(m_clusters, clusterSize + 1);

                m_clusters[clusterSize].clusterTime = clusterTime;
                m_clusters[clusterSize].clusterStartTime = clusterStartTime;
                //m_clusters[clusterSize].clusterHighestBody = clusterHighestBody;
                //m_clusters[clusterSize].clusterLowestTip = clusterLowestTip;
                m_clusters[clusterSize].clusterUpperRange = clusterUpperRange;
                m_clusters[clusterSize].clusterLowerRange = clusterLowerRange;
                m_clusters[clusterSize].zoneCount = zoneCount;
                m_clusters[clusterSize].visualRef = "";

                // Create visualization
                if(m_clusterVisualisation)
                {
                    CreateClusterVisualization(m_clusters[clusterSize]);
                }
            }
        }

        // Update index (already removed current element, so check same index)
        i = ArraySize(makeshift) - 1;
    }
    ChartRedraw();
    return true;
}

//+------------------------------------------------------------------+
//| Update existing clusters                                        |
//+------------------------------------------------------------------+
void CZones::UpdateClusters()
{
    // Check for new zones and update clusters
    for(int i = ArraySize(m_HSZones) - 1; i >= 0; i--)
    {
        if(m_HSZones[i].zoneTime > m_lastHSZoneTime)
        {
            // New zone found, check all clusters
            for(int c = ArraySize(m_clusters) - 1; c >= 0; c--)
            {
                double apex = m_HSZones[i].apex;
                double bodyApex = m_HSZones[i].bodyApex;

                // Check if zone falls within cluster range
                if((apex >= m_clusters[c].clusterLowerRange && apex <= m_clusters[c].clusterUpperRange) ||
                   (bodyApex >= m_clusters[c].clusterLowerRange && bodyApex <= m_clusters[c].clusterUpperRange))
                {
                    // Update cluster parameters
                    m_clusters[c].clusterTime = m_HSZones[i].zoneTime;
                    //m_clusters[c].clusterHighestBody = MathMax(m_clusters[c].clusterHighestBody, bodyApex);
                    //m_clusters[c].clusterLowestTip = MathMin(m_clusters[c].clusterLowestTip, apex);
                    m_clusters[c].clusterUpperRange = MathMax(MathMax(m_clusters[c].clusterUpperRange, apex), bodyApex);
                    m_clusters[c].clusterLowerRange = MathMin(MathMin(m_clusters[c].clusterLowerRange, apex), bodyApex);
                    m_clusters[c].zoneCount++;

                    // Update visualization
                    if(m_clusterVisualisation)
                    {
                        UpdateClusterVisualization(m_clusters[c]);
                    }

                    // Check if zone count exceeded
                    if(m_clusters[c].zoneCount > m_maxZoneCount)
                    {
                        // Delete cluster
                        if(m_deleteClusterVisualisation)
                            DeleteClusterVisualization(m_clusters[c].visualRef);
                        else
                            TerminateClusterVisualization(m_clusters[c].visualRef, m_clusters[c].clusterTime);

                        ArrayRemove(m_clusters, c, 1);
                    }
                }
            }
        }
        else
        {
            break;  // No more new zones
        }
    }

    // Check for new LS zones
    for(int i = ArraySize(m_LSZones) - 1; i >= 0; i--)
    {
        if(m_LSZones[i].zoneTime > m_lastLSZoneTime)
        {
            for(int c = ArraySize(m_clusters) - 1; c >= 0; c--)
            {
                double apex = m_LSZones[i].apex;
                double bodyApex = m_LSZones[i].bodyApex;

                if((apex >= m_clusters[c].clusterLowerRange && apex <= m_clusters[c].clusterUpperRange) ||
                   (bodyApex >= m_clusters[c].clusterLowerRange && bodyApex <= m_clusters[c].clusterUpperRange))
                {
                    m_clusters[c].clusterTime = m_LSZones[i].zoneTime;
                    //m_clusters[c].clusterHighestBody = MathMax(m_clusters[c].clusterHighestBody, bodyApex);
                    //m_clusters[c].clusterLowestTip = MathMin(m_clusters[c].clusterLowestTip, apex);
                    m_clusters[c].clusterUpperRange = MathMax(MathMax(m_clusters[c].clusterUpperRange, apex), bodyApex);
                    m_clusters[c].clusterLowerRange = MathMin(MathMin(m_clusters[c].clusterLowerRange, apex), bodyApex);
                    m_clusters[c].zoneCount++;

                    if(m_clusterVisualisation)
                    {
                        UpdateClusterVisualization(m_clusters[c]);
                    }

                    if(m_clusters[c].zoneCount > m_maxZoneCount)
                    {
                        if(m_deleteClusterVisualisation)
                            DeleteClusterVisualization(m_clusters[c].visualRef);
                        else
                            TerminateClusterVisualization(m_clusters[c].visualRef, m_clusters[c].clusterTime);

                        ArrayRemove(m_clusters, c, 1);
                    }
                }
            }
        }
        else
        {
            break;
        }
    }

    // Check cluster expiry (0 means no expiry check)
    if(m_clusterExpiry > 0)
    {
        for(int c = ArraySize(m_clusters) - 1; c >= 0; c--)
        {
            int clusterShift = iBarShift(m_symbol, m_timeframe, m_clusters[c].clusterTime);
            if(clusterShift >= m_clusterExpiry)
            {
                // Expired, delete cluster and visualization
                DeleteClusterVisualization(m_clusters[c].visualRef);
                ArrayRemove(m_clusters, c, 1);
            }
        }
    }
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create zone visualization (trend channel)                       |
//+------------------------------------------------------------------+
void CZones::CreateZoneVisualization(const Zone &zone, bool isHighSwing)
{
    // Generate unique name
    string objName = StringFormat("Zone_%s_%s_%d", m_symbol, isHighSwing ? "HS" : "LS", (int)zone.zoneTime);
    
    // Find the earlier candle (larger shift) between zone and body apex
    int zoneShift = iBarShift(m_symbol, m_timeframe, zone.zoneTime);
    int bodyShift = iBarShift(m_symbol, m_timeframe, zone.bodyTime);
    int startShift = MathMax(zoneShift, bodyShift);
    
    double startPrice = MathMax(zone.apex, zone.bodyApex);
    double endPrice = MathMin(zone.apex, zone.bodyApex);
    endPrice = endPrice == 0 ? startPrice : endPrice;
    
    datetime startTime = iTime(m_symbol, m_timeframe, startShift);
    datetime endTime = iTime(m_symbol, m_timeframe, startShift - (m_minPostApexBars > 0 ? m_minPostApexBars : 1));
    
    // Delete existing object if it exists
    if(ObjectFind(0, objName) >= 0)
        //ObjectDelete(0, objName);
        return;
    
    // Reset error
    ResetLastError();
    
    // Create equidistant channel with THREE anchor points
    // Point 1: Start time at apex price (top/bottom of zone)
    // Point 2: Start time at body apex price (defines channel width)
    // Point 3: Same time as point 1, same price as point 2 (makes horizontal channel)
    if(!ObjectCreate(0, objName, OBJ_CHANNEL, 0, 
                     startTime, startPrice,           // Point 1: time1, price1
                     endTime, startPrice,       // Point 2: time2, price2  
                     startTime, endPrice))      // Point 3: time3, price3
    {
        Print(__FUNCTION__, ": Failed to create channel '", objName, "'. Error: ", GetLastError());
        return;
    }
    
    // Set channel color with variation
    color zoneColor;
    if(isHighSwing)
    {
        zoneColor = (color)((m_HSZoneColor & 0xF0F0F0) + (MathRand() % 0x0F0F0F));
    }
    else
    {
        zoneColor = (color)((m_LSZoneColor & 0xF0F0F0) + (MathRand() % 0x0F0F0F));
    }
    ObjectSetInteger(0, objName, OBJPROP_COLOR, zoneColor);
    
    // Set line style and width
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    
    // Enable channel fill
    ObjectSetInteger(0, objName, OBJPROP_FILL, true);
    
    // Set ray properties (extend right, not left)
    ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);
    //ObjectSetInteger(0, objName, OBJPROP_RAY_LEFT, false);
    
    // Display in background
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    
    // Disable selection
    //ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
    //ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
    
    // Redraw chart
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Terminate zone visualization (turn off ray)                     |
//+------------------------------------------------------------------+
void CZones::TerminateZoneVisualization(string visualRef, datetime endTime)
{
    if(visualRef == "")
        return;
    
    double price = ObjectGetDouble(0, visualRef, OBJPROP_PRICE, 1);
    ObjectMove(0, visualRef, 1, endTime, price);
    ObjectSetInteger(0, visualRef, OBJPROP_RAY_RIGHT, false);
}

//+------------------------------------------------------------------+
//| Delete zone visualization                                       |
//+------------------------------------------------------------------+
void CZones::DeleteZoneVisualization(string visualRef)
{
    if(visualRef == "")
        return;

    ObjectDelete(0, visualRef);
}

//+------------------------------------------------------------------+
//| Create cluster visualization (channel)                          |
//+------------------------------------------------------------------+
void CZones::CreateClusterVisualization(ZoneCluster &cluster)
{
    // Generate unique name
    string objName = StringFormat("Cluster_%s_%d", m_symbol, (int)cluster.clusterTime);

    // Create channel between clusterHighestBody and clusterLowestTip
    ObjectCreate(0, objName, OBJ_CHANNEL, 0,
                cluster.clusterStartTime, cluster.clusterUpperRange,
                cluster.clusterStartTime + PeriodSeconds(m_timeframe), cluster.clusterUpperRange,
                cluster.clusterStartTime, cluster.clusterLowerRange);

    ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);
    //ObjectSetInteger(0, objName, OBJPROP_RAY_LEFT, false);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    //ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
    //ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, m_clusterColor);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGray);
    ObjectSetInteger(0, objName, OBJPROP_FILL, true);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);

    cluster.visualRef = objName;
}

//+------------------------------------------------------------------+
//| Update cluster visualization                                    |
//+------------------------------------------------------------------+
void CZones::UpdateClusterVisualization(ZoneCluster &cluster)
{
    if(cluster.visualRef == "" || ObjectFind(0, cluster.visualRef) < 0)
    {
        // Recreate if lost
        CreateClusterVisualization(cluster);
        return;
    }

    // Update channel prices
    ObjectMove(0, cluster.visualRef, OBJPROP_PRICE, 0, cluster.clusterUpperRange);
    ObjectMove(0, cluster.visualRef, OBJPROP_PRICE, 1, cluster.clusterUpperRange);
    ObjectMove(0, cluster.visualRef, OBJPROP_PRICE, 2, cluster.clusterLowerRange);
    ObjectMove(0, cluster.visualRef, OBJPROP_TIME, 0, cluster.clusterStartTime);
    ObjectMove(0, cluster.visualRef, OBJPROP_TIME, 1, cluster.clusterStartTime - 1);
    ObjectMove(0, cluster.visualRef, OBJPROP_TIME, 2, cluster.clusterStartTime);
}

//+------------------------------------------------------------------+
//| Terminate cluster visualization                                 |
//+------------------------------------------------------------------+
void CZones::TerminateClusterVisualization(string visualRef, datetime endTime)
{
    if(visualRef == "" || ObjectFind(0, visualRef) < 0)
        return;

    double price = ObjectGetDouble(0, visualRef, OBJPROP_PRICE, 1);
    ObjectMove(0, visualRef, 1, endTime, price);
    ObjectSetInteger(0, visualRef, OBJPROP_RAY_RIGHT, false);
}

//+------------------------------------------------------------------+
//| Delete cluster visualization                                    |
//+------------------------------------------------------------------+
void CZones::DeleteClusterVisualization(string visualRef)
{
    if(visualRef == "")
        return;

    ObjectDelete(0, visualRef);
}

//+------------------------------------------------------------------+
//| Delete all zone and cluster visualizations                     |
//+------------------------------------------------------------------+
void CZones::DeleteAllVisualizations()
{
    // Delete zone and cluster visualizations
    int totalObjects = ObjectsTotal(0, 0, -1);
    for(int i = totalObjects - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i, 0, -1);
        // Match KT visualization prefix
        if(StringFind(objName, "Zone_") == 0 || StringFind(objName, "Cluster_") == 0)
        {
            ObjectDelete(0, objName);
        }
    }

    ChartRedraw();
    Print("CZones: All zone and cluster visualizations deleted");
}

//+------------------------------------------------------------------+
