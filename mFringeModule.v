module mFringeModule (input wire iClk,
						input wire iRst,
						input wire iEn,
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

						
localparam pThFMa 	= 25;//512;
localparam pThFMb 	= 80;//512;					
						
wire [7:0]  wv8AminusFij;						
wire [7:0]  wv8HminusFij;						
wire [7:0]  wv8AminusH;

wire [7:0]  wv8CminusFij;						
wire [7:0]  wv8FminusFij;						
wire [7:0]  wv8CminusF;

wire [7:0]  wv8BminusFij;						
wire [7:0]  wv8GminusFij;						
wire [7:0]  wv8BminusG;

wire [7:0]  wv8DminusFij;						
wire [7:0]  wv8EminusFij;						
wire [7:0]  wv8DminusE;
wire [7:0]  wv8PixelOut;


wire   		wFE1;	
wire   		wFE2;	
wire   		wFE3;	
wire   		wFE4;	
wire   		wDecision3;	
wire   		wValid;	

reg [7:0]	rv9x8ImgArray [8:0];
reg			rDecisionOut;
integer		i;											

assign wDecision3	 = !(wFE1 | wFE2 | wFE3 | wFE4) ;//& !rDecisionOut;
assign wValid 	 	 = (!wDecision3) ;
assign wv8PixelOut 	 = wValid ? rv9x8ImgArray[4] : 8'd0	;

assign wFE1 		 = !((wv8AminusFij >= pThFMa) | (wv8HminusFij >= pThFMa) | (wv8AminusH >= pThFMb)  ) ;  // a-h
assign wFE2 		 = !((wv8CminusFij >= pThFMa) | (wv8FminusFij >= pThFMa) | (wv8CminusF >= pThFMb)  ) ;  // c-f
assign wFE3 		 = !((wv8BminusFij >= pThFMa) | (wv8GminusFij >= pThFMa) | (wv8BminusG >= pThFMb)  ) ;  // b-g
assign wFE4 		 = !((wv8DminusFij >= pThFMa) | (wv8EminusFij >= pThFMa) | (wv8DminusE >= pThFMb)  ) ;  // d-e

assign oDecisionOut  = (rDecisionOut);

//Th_ IMa, Th_ IMb, Th _FMa, Th _FMb, Th _SMa, and Th_ SMb are all predefined values and
//set as 20, 25, 40, 80, 15, and 60, respectively.
always @(posedge iClk or negedge iRst)
begin
	if(iRst)
	begin
		for(i=0; i<9 ;i = i+1)
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
		if(iEn)
		begin
			ov8PixelOut 	 <= wv8PixelOut;
			rDecisionOut 	 <= wDecision3;
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
//Edge 1 (E1 a-h) | a - fi,j|
//************************************************************************
mDifference uAminusFij (
	.iv8Num1(rv9x8ImgArray[0]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8AminusFij)
 );
 
//*************************** ********************************************
//Edge 1 (E1 a-h) | h - fi,j|
//************************************************************************

mDifference uHminusFij (
	.iv8Num1(rv9x8ImgArray[8]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8HminusFij)
 );
 
 
 //*************************** ********************************************
//Edge 1 (E1 a-h) | a - h|
//************************************************************************

mDifference uAminusH (
	.iv8Num1(rv9x8ImgArray[0]),
	.iv8Num2(rv9x8ImgArray[8]),
	.ov8Difference(wv8AminusH)
 );
 
 
//*************************** ********************************************
//Edge 2 (E2 c-f) | c - fi,j|
//************************************************************************
mDifference uCminusFij (
	.iv8Num1(rv9x8ImgArray[2]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8CminusFij)
 );
 
//*************************** ********************************************
//Edge 2 (E2 c-f) | f - fi,j|
//************************************************************************

mDifference uFminusFij (
	.iv8Num1(rv9x8ImgArray[6]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8FminusFij)
 );
 
 
 //*************************** ********************************************
//Edge 2 (E2 c-f) | c - f|
//************************************************************************

mDifference uCminusF (
	.iv8Num1(rv9x8ImgArray[2]),
	.iv8Num2(rv9x8ImgArray[6]),
	.ov8Difference(wv8CminusF)
 ); 

 
//*************************** ********************************************
//Edge 3 (E3 b-g) | b - fi,j|
//************************************************************************
mDifference uBminusFij (
	.iv8Num1(rv9x8ImgArray[1]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8BminusFij)
 );
 
//*************************** ********************************************
//Edge 3 (E3 b-g) | g - fi,j|
//************************************************************************

mDifference uGminusFij (
	.iv8Num1(rv9x8ImgArray[7]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8GminusFij)
 );
 
 
 //*************************** ********************************************
//Edge 3 (E3 b-g) | b - g|
//************************************************************************

mDifference uBminusG (
	.iv8Num1(rv9x8ImgArray[1]),
	.iv8Num2(rv9x8ImgArray[7]),
	.ov8Difference(wv8BminusG)
 ); 
 
 //*************************** ********************************************
//Edge 4 (E4 d-e) | d - fi,j|
//************************************************************************
mDifference uDminusFij (
	.iv8Num1(rv9x8ImgArray[3]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8DminusFij)
 );
 
//*************************** ********************************************
//Edge 4 (E4 d-e) | e - fi,j|
//************************************************************************

mDifference uEminusFij (
	.iv8Num1(rv9x8ImgArray[5]),
	.iv8Num2(rv9x8ImgArray[4]),
	.ov8Difference(wv8EminusFij)
 );
 
 
 //*************************** ********************************************
//Edge 4 (E4 d-e) | d - e|
//************************************************************************

mDifference uDminusE (
	.iv8Num1(rv9x8ImgArray[3]),
	.iv8Num2(rv9x8ImgArray[5]),
	.ov8Difference(wv8DminusE)
 ); 

endmodule
