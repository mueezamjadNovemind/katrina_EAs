//+------------------------------------------------------------------+
//|                                         sweet_Spor_Indicator.mq4 |
//|                                    Copyright 2023, Novemind inc. |
//|                                         https://www.novemind.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Novemind inc."
#property link      "https://www.novemind.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 3       // Number of buffers
#property indicator_plots 3

sinput string     str1         = ".... General Settings ...."; // __
input int         hoursToCheck = 3;                            // Hours to check
input double      midBandPer   = 50;                           // Middle Band Percentage
input bool        topBottomLine= true;                         // Draw Top Bottom Line
input bool        centreLine   = true;                         // Draw Centre Line
input bool        middleLine   = true;                         // Draw Middle Bands Line

double Buf_tb_Dist[],Buf_LineStatus[],Buf_mid_dist[];
const string highLine = "High",centreLin = "centre ",lowLine = "Low",midHigh = "midHigh",midLow = "midLow";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   removeLines();
//--- indicator buffers mapping
   SetIndexBuffer(0,Buf_tb_Dist);         // Assigning an array to a buffer
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,Buf_LineStatus);         // Assigning an array to a buffer
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,Buf_mid_dist);         // Assigning an array to a buffer
   SetIndexStyle(2,DRAW_NONE);

   SetIndexLabel(0,"Top to Bottom Points");
   SetIndexLabel(1,"Line Status");
   SetIndexLabel(2,"Middle Band Points");
   createLines();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   removeLines();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   if(newBar())
     {
      if(prev_calculated == 0)
        {
         for(int i = rates_total/4 ; i > 0; i--)
           {
            double lowValue  = lowOfCandles(i);
            double highValue = highOfCandles(i);

            double midValue = lowValue + (highValue - lowValue)/2;
            ObjectSetDouble(0,centreLin,OBJPROP_PRICE,midValue);

            double distance = highValue - lowValue;
            double centerBands = (midBandPer/2)/100;

            double upperMidBand = midValue + (distance*centerBands);
            double lowerMidBand = midValue - (distance*centerBands);
            //if(i == 1)
              {
               ObjectSetDouble(0,midHigh,OBJPROP_PRICE,upperMidBand);
               ObjectSetDouble(0,midLow,OBJPROP_PRICE,lowerMidBand);
              }
            setBufferValues(i);
           }
        }
      else
        {
         double lowValue  = lowOfCandles(1);
         double highValue = highOfCandles(1);
         double midValue = lowValue + (highValue - lowValue)/2;
         ObjectSetDouble(0,centreLin,OBJPROP_PRICE,midValue);
         double distance = highValue - lowValue;
         double centerBands = (midBandPer/2)/100;
         double upperMidBand = midValue + (distance*centerBands);
         double lowerMidBand = midValue - (distance*centerBands);
         ObjectSetDouble(0,midHigh,OBJPROP_PRICE,upperMidBand);
         ObjectSetDouble(0,midLow,OBJPROP_PRICE,lowerMidBand);
        }
     }
   setBufferValues(0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBufferValues(int index)
  {
   double high_Value    = ObjectGetDouble(0,highLine,OBJPROP_PRICE,0);
   double center_Value  = ObjectGetDouble(0,centreLin,OBJPROP_PRICE,0);
   double low_Value     = ObjectGetDouble(0,lowLine,OBJPROP_PRICE,0);
   double mid_High      = ObjectGetDouble(0,midHigh,OBJPROP_PRICE,0);
   double mid_Low       = ObjectGetDouble(0,midLow,OBJPROP_PRICE,0);

   Buf_tb_Dist[index]  = (high_Value - low_Value)/Point();
   Buf_mid_dist[index] = (mid_High - mid_Low)/Point();

   if(high_Value >= Close[index] && Close[index] >= mid_High)
     {
      Buf_LineStatus[index] = 1;
     }
   if(mid_High >= Close[index] && Close[index] >= mid_Low)
     {
      Buf_LineStatus[index] = 2;
     }
   if(mid_Low >= Close[index] && Close[index] >= low_Value)
     {
      Buf_LineStatus[index] = 3;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {
   static datetime lastbar;
   datetime curbar = iTime(Symbol(),PERIOD_CURRENT,0);
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return (true);
     }
   else
     {
      return (false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createLines()
  {
   string name = highLine;

   if(!ObjectCreate(0,name,OBJ_HLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),Ask))
     {
      Print("Error in Creating Object: ",GetLastError());
     }
   if(topBottomLine)
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   else
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   name = centreLin;


   if(!ObjectCreate(0,name,OBJ_HLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),Ask))
     {
      Print("Error in Creating Object: ",GetLastError());
     }
   if(centreLine)
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   else
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);

   name = lowLine;

   if(!ObjectCreate(0,name,OBJ_HLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),Ask))
     {
      Print("Error in Creating Object: ",GetLastError());
     }
   if(topBottomLine)
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   else
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);

   name = midHigh;
   if(!ObjectCreate(0,name,OBJ_HLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),Ask))
     {
      Print("Error in Creating Object: ",GetLastError());
     }
   if(middleLine)
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   else
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);

   name = midLow;
   if(!ObjectCreate(0,name,OBJ_HLINE,0,iTime(Symbol(),PERIOD_CURRENT,0),Ask))
     {
      Print("Error in Creating Object: ",GetLastError());
     }
   if(middleLine)
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   else
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double highOfCandles(int i)
  {

   datetime prevCandle = iTime(Symbol(),PERIOD_CURRENT,i) - hoursToCheck*3600;
   int candle = iBarShift(Symbol(),PERIOD_CURRENT,prevCandle,false);
//Print("Prev Candle: ",prevCandle, " candle number : ",candle);

   int highIndex = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,candle-1,i);
     //Print("High Index: ",highIndex);
   double high = iHigh(Symbol(),PERIOD_CURRENT,highIndex);
   ObjectSetDouble(0,highLine,OBJPROP_PRICE,high);
   return high;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lowOfCandles(int i)
  {
   datetime prevCandle = iTime(Symbol(),PERIOD_CURRENT,i) - hoursToCheck*3600;
   int candle = iBarShift(Symbol(),PERIOD_CURRENT,prevCandle,false);
   //Print("Prev Candle: ",prevCandle, " candle number : ",candle," i ",i);

   int lowIndex = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,candle-1,i);
   //Print("Low Index: ",lowIndex);
   double low = iLow(Symbol(),PERIOD_CURRENT,lowIndex);
//Print("Low : ", low,"  Time: ",iTime(Symbol(),PERIOD_CURRENT,lowIndex) ," Low Index: ",lowIndex);
   ObjectSetDouble(0,lowLine,OBJPROP_PRICE,low);
   return low;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void removeLines()
  {
   string name = "";
   for(int i = ObjectsTotal(0,0); i >= 0 ; i--)
     {
      name = ObjectName(0,i);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE) == OBJ_HLINE)
        {
         if(StringFind(name,highLine,0) >= 0 || StringFind(name,centreLin,0) >= 0 || StringFind(name,lowLine,0) >= 0 ||
            StringFind(name,midHigh,0)  >= 0 || StringFind(name,midLow,0)    >= 0)
           {
            ObjectDelete(0,name);
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
