#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "HighlightCandle"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue, clrPurple   // 0 = bull, 1 = bear
#property indicator_width1  1

enum ENUM_TREND_MODE { Bull, Bear, Both };

input datetime        InpDate          = D'2020.00.01 00:00'; // Start date
input ENUM_TREND_MODE WhereToDraw      = Both;                // Where to draw
input color           InpBullCandleColor = clrBlue;           // Bull Candle Color
input color           InpBearCandleColor = clrGray;         // Bear Candle Color

double OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[], ColorBuffer[];

int OnInit()
{
   SetIndexBuffer(0, OpenBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, HighBuffer,  INDICATOR_DATA);
   SetIndexBuffer(2, LowBuffer,   INDICATOR_DATA);
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpBullCandleColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpBearCandleColor);

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 2)
      return(0);

   int start = (prev_calculated > 1) ? prev_calculated - 1 : 1;

   for(int i = start; i < rates_total; i++)
   {
      OpenBuffer[i] = HighBuffer[i] = LowBuffer[i] = CloseBuffer[i] = EMPTY_VALUE;
      ColorBuffer[i] = 0;

      if(time[i] < InpDate)
         continue;

      int p = i - 1; // previous candle 

      bool curBull  = close[i] > open[i];
      bool curBear  = close[i] < open[i];
      bool prevBull = close[p] > open[p];
      bool prevBear = close[p] < open[p];

      int clrIndex = -1;

      if(WhereToDraw != Bear && curBull && prevBull && low[i] < low[p])
         clrIndex = 0;
      else if(WhereToDraw != Bull && curBear && prevBear && high[i] > high[p])
         clrIndex = 1;

      if(clrIndex >= 0)
      {
         OpenBuffer[i]  = open[i];
         HighBuffer[i]  = high[i];
         LowBuffer[i]   = low[i];
         CloseBuffer[i] = close[i];
         ColorBuffer[i] = clrIndex;
      }
   }
   return(rates_total);
}