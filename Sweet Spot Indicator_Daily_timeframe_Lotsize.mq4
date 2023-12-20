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

#property indicator_buffers 7       // Number of buffers
#property indicator_plots 3

sinput string     str1         = ".... General Settings ...."; // __
input int         daysToCheck  = 1;                            // Days to check
input int         nofPending   = 20;                           // Number Of Pending Orders
input double      midBandPer   = 50;                           // Middle Band Percentage
input bool        topBottomLine= true;                         // Draw Top Bottom Line
input bool        centreLine   = true;                         // Draw Centre Line
input bool        middleLine   = true;                         // Draw Middle Bands Line
input double      slPercent    = 20;                           // Deduct SL Percent form high and low
input int         atrPeriod    = 14;                           // ATR Period
input int         atrMultiplier= 5;                            // Max ATR Multiple
input double      risk         = 20;                           // Lot Risk in Percentage %
input double      minRisk      = 100;                          // Minimum Risk ($)
input double      capitalAmount= 0;                            // Capital Amount ($)

double Buf_tb_Dist[],Buf_LineStatus[],Buf_mid_dist[],Buf_spacing[], Buf_tf[], Buf_lotSize[],Buf_stoploss[];
const string highLine = "High",centreLin = "centre ",lowLine = "Low",midHigh = "midHigh",midLow = "midLow";

double lowValue  = 0;
double highValue = 0;
double spacingValue = 0;
double stoplossPoints = 0;
double lotSize        = 0;
datetime expiry=D'2024.01.30 12:00:00';
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
   SetIndexBuffer(4,Buf_tf);
   SetIndexBuffer(5,Buf_lotSize);
   SetIndexBuffer(6,Buf_stoploss);

   SetIndexLabel(0,"Top to Bottom Points");
   SetIndexLabel(1,"Line Status");
   SetIndexLabel(2,"Middle Band Points");
   SetIndexLabel(3,"Spacing Buffer");
   SetIndexLabel(4,"Timeframe");
   SetIndexLabel(5,"Lotsize");
   SetIndexLabel(6,"Stoploss");
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
   double pips = iCustom(Symbol(),PERIOD_CURRENT,"Point_Pips_Indicator",0,0);
   if(TimeCurrent() > expiry)
      return 0;
   if(newBar())
     {
      if(prev_calculated == 0)
        {
         setHighLow(0,false);
         double midValue = lowValue + (highValue - lowValue)/2;
         ObjectSetDouble(0,centreLin,OBJPROP_PRICE,midValue);
         double distance = highValue - lowValue;
         double centerBands = (midBandPer/2)/100;
         double upperMidBand = midValue + (distance*centerBands);
         double lowerMidBand = midValue - (distance*centerBands);
         ObjectSetDouble(0,midHigh,OBJPROP_PRICE,upperMidBand);
         ObjectSetDouble(0,midLow,OBJPROP_PRICE,lowerMidBand);
         double highLowDistPoints = distance/pips;
         spacingValue = (highLowDistPoints)/nofPending;

         double highForSL   = highValue - (distance * slPercent/100);
         double lowForSL    = lowValue + (distance * slPercent/100);
         double slDist_Pips = (highForSL - lowForSL)/pips;
         stoplossPoints     = (nofPending/2)*((2*slDist_Pips) - (nofPending - 1)*spacingValue);
         lotSize = getLot(stoplossPoints);

         for(int i = rates_total/2 ; i > 0; i--)
           {
            setBufferValues(i);
           }
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
      double highLowDistPoints = distance/Point();
      spacingValue = (highLowDistPoints)/nofPending;

      double highForSL   = highValue - (distance * slPercent/100);
      double lowForSL    = lowValue + (distance * slPercent/100);
      double slDist_Pips = (highForSL - lowForSL)/pips;
      stoplossPoints     = (nofPending/2)*((2*slDist_Pips) - (nofPending - 1)*spacingValue);
      lotSize = getLot(stoplossPoints);
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
   Buf_spacing[index]  = NormalizeDouble(spacingValue,0);

   if((high_Value >= Close[0] && Close[0] >= mid_High) || Close[0] >= high_Value)
     {
      Buf_LineStatus[index] = 1;
     }
   if(mid_High >= Close[0] && Close[0] >= mid_Low)
     {
      Buf_LineStatus[index] = 2;
     }
   if((mid_Low >= Close[0] && Close[0] >= low_Value) || Close[0] <= low_Value)
     {
      Buf_LineStatus[index] = 3;
     }

   double atr_1 = (iCustom(Symbol(),PERIOD_M1,"Katrina ATR",atrPeriod,0,1))*atrMultiplier;
   double atr_5 = (iCustom(Symbol(),PERIOD_M5,"Katrina ATR",atrPeriod,0,1))*atrMultiplier;
   double atr_15 = (iCustom(Symbol(),PERIOD_M15,"Katrina ATR",atrPeriod,0,1))*atrMultiplier;
   double atr_30 = (iCustom(Symbol(),PERIOD_M30,"Katrina ATR",atrPeriod,0,1))*atrMultiplier;
   double atr_60 = (iCustom(Symbol(),PERIOD_H1,"Katrina ATR",atrPeriod,0,1))*atrMultiplier;
   if(atr_1 > spacingValue)
     {
      Buf_tf[index] = 1;
     }
   else
      if(atr_5 > spacingValue)
        {
         Buf_tf[index] = 5;
        }
      else
         if(atr_15 > spacingValue)
           {
            Buf_tf[index] = 15;
           }
         else
            if(atr_30 > spacingValue)
              {
               Buf_tf[index] = 30;
              }
            else
               if(atr_60 > spacingValue)
                 {
                  Buf_tf[index] = 60;
                 }
               else
                 {
                  Buf_tf[index] = 0;
                 }
   Buf_lotSize[index] = lotSize;
   Buf_stoploss[index] = stoplossPoints;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {
   static datetime lastbar;
   datetime curbar = iTime(Symbol(),PERIOD_M1,0);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLot(double stop_loss)
  {
   double pipvalue = NormalizeDouble(((MarketInfo(Symbol(),MODE_TICKVALUE)/(MarketInfo(Symbol(),MODE_TICKSIZE)/Point))*10),2);
   pipvalue = pipvalue / 10;

   double riskamount=(risk/100)*AccountBalance();
   if(capitalAmount > 0)
     {
      riskamount=(risk/100)*capitalAmount;
     }

   if(riskamount < minRisk)
      riskamount = minRisk;

//Print("Risk Amount: ",riskamount," Account Balance: ",AccountBalance());
   double pipvalue_required=riskamount/stop_loss;
   double lot_Size = pipvalue_required/pipvalue;
   int roundDigit=0;
   double step=MarketInfo(Symbol(), MODE_LOTSTEP);
   while(step<1)
     {
      roundDigit++;
      step=step*10;
     }

   lot_Size = NormalizeDouble(lot_Size,roundDigit);
   if(lot_Size<MarketInfo(Symbol(),MODE_MINLOT))
      lot_Size=MarketInfo(Symbol(),MODE_MINLOT);
   else
      if(lot_Size>MarketInfo(Symbol(),MODE_MAXLOT))
         lot_Size=MarketInfo(Symbol(),MODE_MAXLOT);
//Print("Lot: ",lot_Size," sl Points: ",stop_loss);
   return lot_Size;
  }
//+------------------------------------------------------------------+
