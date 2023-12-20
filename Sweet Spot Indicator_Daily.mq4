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
input int         daysToCheck  = 1;                            // Days to check
input double      midBandPer   = 50;                           // Middle Band Percentage
input bool        topBottomLine= true;                         // Draw Top Bottom Line
input bool        centreLine   = true;                         // Draw Centre Line
input bool        middleLine   = true;                         // Draw Middle Bands Line

double Buf_tb_Dist[],Buf_LineStatus[],Buf_mid_dist[],Buf_spacing[];
const string highLine = "High",centreLin = "centre ",lowLine = "Low",midHigh = "midHigh",midLow = "midLow";

double lowValue  = 0;
double highValue = 0;
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
   SetIndexBuffer(3,Buf_spacing);

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
         Print(" 0");
         setHighLow(0,false);
         double midValue = lowValue + (highValue - lowValue)/2;
         ObjectSetDouble(0,centreLin,OBJPROP_PRICE,midValue);
         double distance = highValue - lowValue;
         double centerBands = (midBandPer/2)/100;
         double upperMidBand = midValue + (distance*centerBands);
         double lowerMidBand = midValue - (distance*centerBands);
         ObjectSetDouble(0,midHigh,OBJPROP_PRICE,upperMidBand);
         ObjectSetDouble(0,midLow,OBJPROP_PRICE,lowerMidBand);
        
         for(int i = rates_total/2 ; i > 0; i--)
           {
            setBufferValues(i);
           }
        }
      else
        {
         setHighLow(0,true);
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

   if(high_Value >= Close[0] && Close[0] >= mid_High)
     {
      Buf_LineStatus[index] = 1;
     }
   if(mid_High >= Close[0] && Close[0] >= mid_Low)
     {
      Buf_LineStatus[index] = 2;
     }
   if(mid_Low >= Close[0] && Close[0] >= low_Value)
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
      Print(".... Newbar ....",lastbar);
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
void setHighLow(int i,bool checkTime)
  {
   if((checkTime && checkNewDay(iTime(Symbol(),PERIOD_CURRENT,i))) || !checkTime)
     {
      datetime time = iTime(Symbol(),PERIOD_CURRENT,i);
      if(checkTime == false)
         time = iTime(Symbol(),PERIOD_D1,0);

      int dailyBar = iBarShift(Symbol(),PERIOD_D1,time,false);

      int highIndex = iHighest(Symbol(),PERIOD_D1,MODE_HIGH,dailyBar+daysToCheck,dailyBar+1);
      highValue = iHigh(Symbol(),PERIOD_D1,highIndex);
      int lowIndex = iLowest(Symbol(),PERIOD_D1,MODE_LOW,dailyBar+daysToCheck,dailyBar+1);
      lowValue = iLow(Symbol(),PERIOD_D1,lowIndex);

      ObjectSetDouble(0,highLine,OBJPROP_PRICE,highValue);
      ObjectSetDouble(0,lowLine,OBJPROP_PRICE,lowValue);
      Print("High Value: ",highValue," Low Value: ",lowValue);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
bool checkNewDay(datetime time)
  {
   MqlDateTime sdate;
   if(TimeToStruct(time,sdate))
     {
      if(sdate.hour == 0 && sdate.min == 0)
        {

         return true;
        }
     }
   else
      Print("Error in Converting Time: ",GetLastError());
   return false;
  }
//+------------------------------------------------------------------+
