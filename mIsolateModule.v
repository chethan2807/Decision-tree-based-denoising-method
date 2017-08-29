module mIsolateModule (input wire iClk,
						input wire iRst,
						input wire iDataValid,
						input wire [7:0] iv8Pixel_a,
						input wire [7:0] iv8Pixel_b,
						input wire [7:0] iv8Pixel_c,
						input wire [7:0] iv8Pixel_d,
						input wire [7:0] iv8Pixel_fij,
						input wire [7:0] iv8Pixel_e,
						input wire [7:0] iv8Pixel_f,
						input wire [7:0] iv8Pixel_g,
						input wire [7:0] iv8Pixel_h,
						output reg [7:0] ov8PixelOut,
						output reg oValid,
						output wire oDecisionOut
						);

						
localparam pThIMa 	= 20;//512;
localparam pThIMb 	= 25;//512;					
						
wire [7:0]  wv8TopHalfMaxIntr0;						
wire [7:0]  wv8TopHalfMaxIntr1;						
wire [7:0]  wv8TopHalfMax;
wire [7:0]  wv8TopHalfMinIntr0;						
wire [7:0]  wv8TopHalfMinIntr1;						
wire [7:0]  wv8TopHalfMin;	
wire [7:0]  wv8TopHalfDiff;

					
wire [7:0]  wv8BottomHalfMaxIntr0;						
wire [7:0]  wv8BottomHalfMaxIntr1;						
wire [7:0]  wv8BottomHalfMax;
wire [7:0]  wv8BottomHalfMinIntr0;						
wire [7:0]  wv8BottomHalfMinIntr1;						
wire [7:0]  wv8BottomHalfMin;	
wire [7:0]  wv8BottomHalfDiff;	

wire [7:0]  wv8FijTopHalfMinDiff;	
wire [7:0]  wv8FijTopHalfMaxDiff;	
wire [7:0]  wv8FijBtmHalfMaxDiff;	
wire [7:0]  wv8FijBtmHalfMinDiff;	

wire [7:0]  wv8PixelOut;	

wire   		wDecisionOut1;	
wire   		wDecisionOut2;	
wire   		wDecision;	
wire   		wValid;	

reg			rDecisionOut;
reg			rDataValid;
reg [7:0]	rv9x8ImgArray [8:0];
integer		i;
											
assign oDecisionOut  = rDecisionOut;
assign wValid 	 	 = (!wDecision);
assign wv8PixelOut 	 = wValid ? rv9x8ImgArray[4] : 8'd0	;

assign wDecision	 = (wDecisionOut1 | wDecisionOut2) & (!rDecisionOut) ;
assign wDecisionOut1 = ((wv8TopHalfDiff >= pThIMa) | (wv8BottomHalfDiff >= pThIMa) ); 
assign wDecisionOut2 = ((wv8FijTopHalfMinDiff >= pThIMb) | (wv8FijTopHalfMaxDiff >= pThIMb) | (wv8FijBtmHalfMaxDiff >= pThIMb) | (wv8FijBtmHalfMinDiff >= pThIMb) ); 

//Th_ IMa, Th_ IMb, Th _FMa, Th _FMb, Th _SMa, and Th_ SMb are all predefined values and
//set as 20, 25, 40, 80, 15, and 60, respectively.
always @(posedge iClk or negedge iRst)
begin
	if(iRst)
	begin
		for(i=0; i<9 ;i =i+1)
		begin
			rv9x8ImgArray[i]			<= 8'd0;
		end
	end
	else
	begin
		if(iDataValid)
		begin
			rv9x8ImgArray[0]		<= iv8Pixel_a;
			rv9x8ImgArray[1]		<= iv8Pixel_b;
			rv9x8ImgArray[2]		<= iv8Pixel_c;
			rv9x8ImgArray[3]		<= iv8Pixel_d;
			rv9x8ImgArray[4]		<= iv8Pixel_fij;
			rv9x8ImgArray[5]		<= iv8Pixel_e;
			rv9x8ImgArray[6]		<= iv8Pixel_f;
			rv9x8ImgArray[7]		<= iv8Pixel_g;
			rv9x8ImgArray[8]		<= iv8Pixel_h;
		end
		rDataValid					<= iDataValid;
	end
end


always @(posedge iClk or negedge iRst)
begin
	if(iRst) 
	begin
		ov8PixelOut 	 <= 8'd0;
		rDecisionOut 	 <= 1'b0;
		oValid 	 		 <= 1'b0;
	end
	else
	begin
		if(rDataValid)
		begin
			ov8PixelOut 	 <= wv8PixelOut;
			rDecisionOut 	 <= wDecision;
			oValid 	 		 <= wValid;
		end
		else
		begin
			ov8PixelOut 	 <= 8'd0;
			rDecisionOut 	 <= 1'b0;
			oValid 	 		 <= 1'b0;
		end
	end
end

//*************************** ********************************************
//Top half Maximum Number finding logic
//************************************************************************

mMaxNum uTopHalfMax0 (
	.iv8Num1(rv9x8ImgArray[0]),
	.iv8Num2(rv9x8ImgArray[1]),
	.ov8MaxNum(wv8TopHalfMaxIntr0)
 );
 
mMaxNum uTopHalfMax1 (
	.iv8Num1(rv9x8ImgArray[2]),
	.iv8Num2(wv8TopHalfMaxIntr0),
	.ov8MaxNum(wv8TopHalfMaxIntr1)
 );		

mMaxNum uTopHalfMax (
	.iv8Num1(rv9x8ImgArray[3]),
	.iv8Num2(wv8TopHalfMaxIntr1),
	.ov8MaxNum(wv8TopHalfMax)
 );
 
 //*************************** ********************************************
//Bottom half Maximum Number finding logic
//************************************************************************

mMaxNum uBottomHalfMax0 (
	.iv8Num1(rv9x8ImgArray[5]),
	.iv8Num2(rv9x8ImgArray[6]),
	.ov8MaxNum(wv8BottomHalfMaxIntr0)
 );
 
mMaxNum uBottomHalfMax1 (
	.iv8Num1(rv9x8ImgArray[7]),
	.iv8Num2(wv8BottomHalfMaxIntr0),
	.ov8MaxNum(wv8BottomHalfMaxIntr1)
 );		

mMaxNum uBottomHalfMax2 (
	.iv8Num1(rv9x8ImgArray[8]),
	.iv8Num2(wv8BottomHalfMaxIntr1),
	.ov8MaxNum(wv8BottomHalfMax)
 );
 
//*************************** ********************************************
//Top half Minimum Number finding logic
//************************************************************************

mMinNum uTopHalfMin0 (
	.iv8Num1(rv9x8ImgArray[0]),
	.iv8Num2(rv9x8ImgArray[1]),
	.ov8MinNum(wv8TopHalfMinIntr0)
 );
 
mMinNum uTopHalfMin1 (
	.iv8Num1(rv9x8ImgArray[2]),
	.iv8Num2(wv8TopHalfMinIntr0),
	.ov8MinNum(wv8TopHalfMinIntr1)
 );		

mMinNum uTopHalfMin2 (
	.iv8Num1(rv9x8ImgArray[3]),
	.iv8Num2(wv8TopHalfMinIntr1),
	.ov8MinNum(wv8TopHalfMin)
 );
 
//*************************** ********************************************
//Bottom half Minimum Number finding logic
//************************************************************************

mMinNum uBottomHalfMin0 (
	.iv8Num1(rv9x8ImgArray[5]),
	.iv8Num2(rv9x8ImgArray[6]),
	.ov8MinNum(wv8BottomHalfMinIntr0)
 );
 
mMinNum uBottomHalfMin1 (
	.iv8Num1(rv9x8ImgArray[7]),
	.iv8Num2(wv8BottomHalfMinIntr0),
	.ov8MinNum(wv8BottomHalfMinIntr1)
 );		

mMinNum uBottomHalfMin2 (
	.iv8Num1(rv9x8ImgArray[8]),
	.iv8Num2(wv8BottomHalfMinIntr1),
	.ov8MinNum(wv8BottomHalfMin)
 );
 
 
//*************************** ********************************************
//Top half max - Top Half Min
//************************************************************************

mDifference uTopHalfDiff (
	.iv8Num1(wv8TopHalfMax),
	.iv8Num2(wv8TopHalfMin),
	.ov8Difference(wv8TopHalfDiff)
 );
 
//*************************** ********************************************
//Bottom half max - Bottom Half Min
//************************************************************************

mDifference uBottomHalfDiff (
	.iv8Num1(wv8BottomHalfMax),
	.iv8Num2(wv8BottomHalfMin),
	.ov8Difference(wv8BottomHalfDiff)
 );
 
 //*************************** ********************************************
//|f i,j - TopHalf_ max|
//************************************************************************

mDifference FijTopHalfMaxDiff (
	.iv8Num1(rv9x8ImgArray[4]),
	.iv8Num2(wv8TopHalfMax),
	.ov8Difference(wv8FijTopHalfMaxDiff)
 );
 
//*************************** ********************************************
//| f i,j - TopHalf _min|
//************************************************************************

mDifference FijTopHalfMinDiff (
	.iv8Num1(rv9x8ImgArray[4]),
	.iv8Num2(wv8TopHalfMin),
	.ov8Difference(wv8FijTopHalfMinDiff)
 );
 
  //*************************** ********************************************
//|f i,j _ BottomHalf_max|
//************************************************************************

mDifference FijBtmHalfMaxDiff (
	.iv8Num1(rv9x8ImgArray[4]),
	.iv8Num2(wv8BottomHalfMax),
	.ov8Difference(wv8FijBtmHalfMaxDiff)
 );
 
//*************************** ********************************************
//|f i,j _ BottomHalf_min|
//************************************************************************

mDifference FijBtmHalfMinDiff (
	.iv8Num1(rv9x8ImgArray[4]),
	.iv8Num2(wv8BottomHalfMin),
	.ov8Difference(wv8FijBtmHalfMinDiff)
 );


endmodule





//*************************** ********************************************
//Maximum Number finding module
//************************************************************************

module mMaxNum (input wire [7:0] iv8Num1,
				input wire [7:0] iv8Num2,
				output wire [7:0] ov8MaxNum
				);
				
assign ov8MaxNum = (iv8Num1 > iv8Num2 ) ?  iv8Num1 : iv8Num2;

endmodule

//*************************** ********************************************
//Maximum Number finding module
//************************************************************************

module mMinNum (input wire [7:0] iv8Num1,
				input wire [7:0] iv8Num2,
				output wire [7:0] ov8MinNum
				);
				
assign ov8MinNum = (iv8Num1 < iv8Num2 ) ?  iv8Num1 : iv8Num2;

endmodule

//*************************** ********************************************
//Magnitude of Difference of two Numbers
//************************************************************************

module mDifference (input wire [7:0] iv8Num1,
				input wire [7:0] iv8Num2,
				output wire [7:0] ov8Difference
				);
				
assign ov8Difference = (iv8Num1 > iv8Num2 ) ?  (iv8Num1 - iv8Num2) : (iv8Num2 - iv8Num1) ;

endmodule