module mSimilarityModule (input wire iClk,
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
						output wire [7:0] ov8Maxij,
						output wire [7:0] ov8Minij,
						output reg [7:0] ov8PixelOut,
						output reg oValid,
						output wire oDecisionOut
						);

						
localparam [7:0] pThSMa 	= 15;
localparam[7:0] pThSMb 	= 60;				
						
wire [7:0] 	wv8Maxij;	
wire [7:0] 	wv8Minij;	
wire [7:0] 	wv8Medianij;	
wire [7:0] 	wv8Nmax;	
wire [7:0] 	wv8Nmin;			
wire [7:0] 	wv8PixelOut;		
wire [7:0] 	wv8MedianijMinusThSMb;		
	
wire [7:0]	wv9x8SortedArray [8:0];
wire		wDecision4;											
wire		wValid;											

reg			rDecisionOut;
reg [7:0]	rv9x8ImgArray [8:0];
integer		i;

assign wDecision4		= ( (rv9x8ImgArray[4] >= wv8Nmax ) | (rv9x8ImgArray[4] <= wv8Nmin ) );
assign wValid 	 		= (!wDecision4) ;
assign wv8PixelOut 		= wValid ? rv9x8ImgArray[4] : 8'd0	;

assign wv8Maxij			= wv9x8SortedArray[5] + pThSMa;
//assign wv8Minij			= wv9x8SortedArray[3] - pThSMa;
//*************************** ********************************************
//Medianij - ThSMb
//************************************************************************

mDifference uMinij (
	.iv8Num1(wv9x8SortedArray[3]),
	.iv8Num2(pThSMa),
	.ov8Difference(wv8Minij)
 );
assign wv8Medianij		= wv9x8SortedArray[4];

assign wv8Nmax 			= (wv8Maxij <= ( wv8Medianij + pThSMb) )   ? wv8Maxij : (wv8Medianij + pThSMb);
assign wv8Nmin 			= (wv8Minij >= wv8MedianijMinusThSMb )   ? wv8Minij : wv8MedianijMinusThSMb;

assign oDecisionOut 	= (rDecisionOut);
assign ov8Maxij			= wv8Maxij;
assign ov8Minij			= wv8Minij;
	 
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
		//rDataValid				<= iDataValid;
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
			rDecisionOut 	 <= wDecision4;
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
//Ascending Sorting
//************************************************************************
mSort uSortAscending (
	.iv8Data_0(rv9x8ImgArray[0]),
	.iv8Data_1(rv9x8ImgArray[1]),
	.iv8Data_2(rv9x8ImgArray[2]),
	.iv8Data_3(rv9x8ImgArray[3]),
	.iv8Data_4(rv9x8ImgArray[4]),
	.iv8Data_5(rv9x8ImgArray[5]),
	.iv8Data_6(rv9x8ImgArray[6]),
	.iv8Data_7(rv9x8ImgArray[7]),
	.iv8Data_8(rv9x8ImgArray[8]),
	.ov8Data_0(wv9x8SortedArray[0]),
	.ov8Data_1(wv9x8SortedArray[1]),
	.ov8Data_2(wv9x8SortedArray[2]),
	.ov8Data_3(wv9x8SortedArray[3]),
	.ov8Data_4(wv9x8SortedArray[4]),
	.ov8Data_5(wv9x8SortedArray[5]),
	.ov8Data_6(wv9x8SortedArray[6]),
	.ov8Data_7(wv9x8SortedArray[7]),
	.ov8Data_8(wv9x8SortedArray[8])
	);

	
//*************************** ********************************************
//Medianij - ThSMb
//************************************************************************

mDifference uMedianijMinusThSMb (
	.iv8Num1(wv8Medianij),
	.iv8Num2(pThSMb),
	.ov8Difference(wv8MedianijMinusThSMb)
 );

endmodule


// //*************************** ********************************************
// // Numbers Sorting
// //************************************************************************

module mSort (
  // input  wire iClk,
  // input  wire iRst,
  input wire [7:0] iv8Data_0,
  input wire [7:0] iv8Data_1,
  input wire [7:0] iv8Data_2,
  input wire [7:0] iv8Data_3,
  input wire [7:0] iv8Data_4,
  input wire [7:0] iv8Data_5,
  input wire [7:0] iv8Data_6,
  input wire [7:0] iv8Data_7,
  input wire [7:0] iv8Data_8,
  output reg  [7:0] ov8Data_0,
  output reg  [7:0] ov8Data_1,
  output reg  [7:0] ov8Data_2,
  output reg  [7:0] ov8Data_3,
  output reg  [7:0] ov8Data_4,
  output reg  [7:0] ov8Data_5,
  output reg  [7:0] ov8Data_6,
  output reg  [7:0] ov8Data_7,
  output reg  [7:0] ov8Data_8
  );
  
integer i, j;
reg [7:0] temp;
reg [7:0] wv9x8Array [8:0];

always @*
begin
  wv9x8Array[0] = iv8Data_0;
  wv9x8Array[1] = iv8Data_1;
  wv9x8Array[2] = iv8Data_2;
  wv9x8Array[3] = iv8Data_3;
  wv9x8Array[4] = iv8Data_4;
  wv9x8Array[5] = iv8Data_5;
  wv9x8Array[6] = iv8Data_6;
  wv9x8Array[7] = iv8Data_7;
  wv9x8Array[8] = iv8Data_8;
  
  for (i = 8; i >= 0; i = i - 1) begin
	for (j = 0 ; j < i; j = j + 1) begin
		if (wv9x8Array[j] > wv9x8Array[j + 1])
		begin
			temp 				= wv9x8Array[j];
			wv9x8Array[j]		= wv9x8Array[j + 1];
			wv9x8Array[j + 1] 	= temp;
		end 
	end
  end 
  
  ov8Data_0 = wv9x8Array[0];
  ov8Data_1 = wv9x8Array[1];
  ov8Data_2 = wv9x8Array[2];
  ov8Data_3 = wv9x8Array[3];
  ov8Data_4 = wv9x8Array[4];
  ov8Data_5 = wv9x8Array[5];
  ov8Data_6 = wv9x8Array[6];
  ov8Data_7 = wv9x8Array[7];
  ov8Data_8 = wv9x8Array[8];
  
  
  
end

 endmodule