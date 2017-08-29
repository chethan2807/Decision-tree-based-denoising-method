module mFilterModule (input wire iClk,
						input wire iRst,
						input wire iEn,
						input wire iDataValid,
						input wire [7:0] iv8Minij,
						input wire [7:0] iv8Maxij,
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
						output reg oValid
						);

wire		wDNoisePixel;
wire		wENoisePixel;
wire		wFNoisePixel;
wire		wGNoisePixel;
wire		wHNoisePixel;
							
wire [7:0]  a;						
wire [7:0]  b;						
wire [7:0]  c;
wire [7:0]  d;
wire [7:0]  e;
wire [7:0]  f;
wire [7:0]  g;
wire [7:0]  h;

reg [7:0]  wv8PixelOut;
reg [7:0]  wv8Fcapij;
						
wire [8:0]  wv9D1; // 1 bit to noise bit and 8 bit pixel data
wire [8:0]  wv9D2;
wire [8:0]  wv9D3;
wire [8:0]  wv9D4;
wire [8:0]  wv9D5;
wire [8:0]  wv9D6;
wire [8:0]  wv9D7;
wire [8:0]  wv9D8;
wire [8:0]  wv8x9DArray[7:0];
wire [7:0]  wv4x8DArray[3:0];

wire [7:0]  wv8DminusH;						
wire [7:0]  wv8AminusE;
				
wire [7:0]  wv8AminusG;						
wire [7:0]  wv8BminusH;						

wire [7:0]  wv8BminusG;						
   
wire [7:0]  wv8BminusF;						
wire [7:0]  wv8CminusG;	

wire [7:0]  wv8CminusD;						
wire [7:0]  wv8EminusF;

wire [7:0]  wv8DminusE;

wire [7:0]  wv8AminusH;

wire [7:0]  wv8CminusF;
wire [8:0]  wv9Dmin;

reg [7:0]	rv9x8ImgArray [8:0];
wire [8:0]	wv8x9EdgesSorted [7:0];
wire [7:0]	wv4x8Sorted [3:0];
reg			rDecisionOut;
integer		i;											

assign wDNoisePixel		= ((d >= iv8Maxij) | (d <= iv8Minij) )	;
assign wENoisePixel		= ((e >= iv8Maxij) | (e <= iv8Minij) )	;
assign wFNoisePixel		= ((f >= iv8Maxij) | (f <= iv8Minij) )	;
assign wGNoisePixel		= ((g >= iv8Maxij) | (g <= iv8Minij) )	;
assign wHNoisePixel		= ((h >= iv8Maxij) | (h <= iv8Minij) )	;


//Th_ IMa, Th_ IMb, Th _FMa, Th _FMb, Th _SMa, and Th_ SMb are all predefined values and
//set as 20, 25, 40, 80, 15, and 60, respectively.
always @(posedge iClk or negedge iRst)
begin
	if(iRst)
	begin
		for(i=0; i<9 ;i=i+1)
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
		oValid 	 		 <= 1'b0;
	end
	else
	begin
		if(iEn)
		begin
			ov8PixelOut 	 <= wv8PixelOut;
			oValid 	 		 <= 1'b1;
		end
		else
		begin
			ov8PixelOut 	 <= 8'd0;
			oValid 	 		 <= 1'b0;
		end
	end
end

assign	a = rv9x8ImgArray[0];
assign	b = rv9x8ImgArray[1];
assign	c = rv9x8ImgArray[2];
assign	d = rv9x8ImgArray[3];
assign	e = rv9x8ImgArray[5];
assign	f = rv9x8ImgArray[6];
assign	g = rv9x8ImgArray[7];
assign	h = rv9x8ImgArray[8];
   

//*************************** *****************************************************************************************
//D1
//*********************************************************************************************************************
assign wv9D1[8]		= (wDNoisePixel|wHNoisePixel|wENoisePixel);
assign wv9D1[7:0]	= (wv8DminusH + wv8AminusE )/2;
//*************************** ********************************************
//d-h  D1 = |d - h| + |a -e|,
//************************************************************************
mDifference uDminusH (
	.iv8Num1(d),
	.iv8Num2(h),
	.ov8Difference(wv8DminusH)
 );
 
 //*************************** ********************************************
//a-e
//************************************************************************
mDifference uAminusE (
	.iv8Num1(a),
	.iv8Num2(e),
	.ov8Difference(wv8AminusE)
 );

 //*************************** *****************************************************************************************
//D2 D2 = |a –g| + |b –h| 
//*********************************************************************************************************************
assign wv9D2[8]		= (wGNoisePixel|wHNoisePixel);
assign wv9D2[7:0]	= (wv8AminusG + wv8BminusH )/2;
//*************************** ********************************************
//a-g
//************************************************************************
mDifference uAminusG (
	.iv8Num1(a),
	.iv8Num2(g),
	.ov8Difference(wv8AminusG)
 );
 
 //*************************** ********************************************
//b-h
//************************************************************************
mDifference uBminusH (
	.iv8Num1(b),
	.iv8Num2(h),
	.ov8Difference(wv8BminusH)
 );
 
 //*************************** *****************************************************************************************
//D3 D3 = |b – g| x 2 
//*********************************************************************************************************************
assign wv9D3[8]		= wGNoisePixel;
assign wv9D3[7:0]	= wv8BminusG;
//*************************** ********************************************
//b-g
//************************************************************************
mDifference uBminusG (
	.iv8Num1(b),
	.iv8Num2(g),
	.ov8Difference(wv8BminusG)
 );
 
//*************************** *****************************************************************************************
//D4 D4 = |b -f| + |c -g| 
//*********************************************************************************************************************
assign wv9D4[8]		= (wFNoisePixel|wGNoisePixel);
assign wv9D4[7:0]	= (wv8BminusF + wv8CminusG )/2;
//*************************** ********************************************
//b-f
//************************************************************************
mDifference uBminusF (
	.iv8Num1(b),
	.iv8Num2(f),
	.ov8Difference(wv8BminusF)
 );
 
 //*************************** ********************************************
//c-g
//************************************************************************
mDifference uCminusG (
	.iv8Num1(c),
	.iv8Num2(g),
	.ov8Difference(wv8CminusG)
 );
 
 //*************************** *****************************************************************************************
//D5 D5 = |c -d| + |e -f|  
//*********************************************************************************************************************
assign wv9D5[8]		= (wDNoisePixel|wENoisePixel|wFNoisePixel);
assign wv9D5[7:0]	= (wv8CminusD + wv8EminusF )/2;
//*************************** ********************************************
//c-d
//************************************************************************
mDifference uCminusD (
	.iv8Num1(c),
	.iv8Num2(d),
	.ov8Difference(wv8CminusD)
 );
 
 //*************************** ********************************************
//e-f
//************************************************************************
mDifference uEminusF (
	.iv8Num1(e),
	.iv8Num2(f),
	.ov8Difference(wv8EminusF)
 );

//*************************** *****************************************************************************************
//D6 D6 = |d –e| x 2 
//*********************************************************************************************************************
assign wv9D6[8]		=  (wDNoisePixel|wENoisePixel);
assign wv9D6[7:0]	=  wv8DminusE;
//*************************** ********************************************
//d-e
//************************************************************************
mDifference uDminusE (
	.iv8Num1(d),
	.iv8Num2(e),
	.ov8Difference(wv8DminusE)
 );
 
//*************************** *****************************************************************************************
//D7 D7 = |a – h| x 2 
//*********************************************************************************************************************
assign wv9D7[8]		= wHNoisePixel;
assign wv9D7[7:0]	= wv8AminusH;
//*************************** ********************************************
//a-h
//************************************************************************
mDifference uAminusH (
	.iv8Num1(a),
	.iv8Num2(h),
	.ov8Difference(wv8AminusH)
 );
 
//*************************** *****************************************************************************************
//D8 ,D8 =|c – f| x 2
//*********************************************************************************************************************
assign wv9D8[8]		= wFNoisePixel;
assign wv9D8[7:0]	= wv8CminusF;
//*************************** ********************************************
//c-f
//************************************************************************
mDifference uCminusF (
	.iv8Num1(c),
	.iv8Num2(f),
	.ov8Difference(wv8CminusF)
 );

assign wv8x9DArray[0] = wv9D1;
assign wv8x9DArray[1] = wv9D2;
assign wv8x9DArray[2] = wv9D3;
assign wv8x9DArray[3] = wv9D4;
assign wv8x9DArray[4] = wv9D5;
assign wv8x9DArray[5] = wv9D6;
assign wv8x9DArray[6] = wv9D7;
assign wv8x9DArray[7] = wv9D8;
//{wv9D8,wv9D7,wv9D6,wv9D5,wv9D4,wv9D3,wv9D2,wv9D1};
//*************************** ********************************************
//Ascending Sorting to find Dmin
//************************************************************************
mSort8 uSortAscending (
	.iv8Data_0(wv8x9DArray[0]),
	.iv8Data_1(wv8x9DArray[1]),
	.iv8Data_2(wv8x9DArray[2]),
	.iv8Data_3(wv8x9DArray[3]),
	.iv8Data_4(wv8x9DArray[4]),
	.iv8Data_5(wv8x9DArray[5]),
	.iv8Data_6(wv8x9DArray[6]),
	.iv8Data_7(wv8x9DArray[7]),
	.ov8Data_0(wv8x9EdgesSorted[0]),
	.ov8Data_1(wv8x9EdgesSorted[1]),
	.ov8Data_2(wv8x9EdgesSorted[2]),
	.ov8Data_3(wv8x9EdgesSorted[3]),
	.ov8Data_4(wv8x9EdgesSorted[4]),
	.ov8Data_5(wv8x9EdgesSorted[5]),
	.ov8Data_6(wv8x9EdgesSorted[6]),
	.ov8Data_7(wv8x9EdgesSorted[7])
	);


assign wv4x8DArray[3] = b;
assign wv4x8DArray[2] = d;
assign wv4x8DArray[1] = e;
assign wv4x8DArray[0] = g;

//*************************** ********************************************
//Ascending Sorting to find Dmin
//************************************************************************
mSort4 uSortAscending4 (
	.iv8Data_0(wv4x8DArray[0]),
	.iv8Data_1(wv4x8DArray[1]),
	.iv8Data_2(wv4x8DArray[2]),
	.iv8Data_3(wv4x8DArray[3]),
	.ov8Data_0(wv4x8Sorted[0]),
	.ov8Data_1(wv4x8Sorted[1]),
	.ov8Data_2(wv4x8Sorted[2]),
	.ov8Data_3(wv4x8Sorted[3])
	);
	
//*************************** ********************************************
//Finding Fcap
//************************************************************************
assign	wv9Dmin = wv8x9EdgesSorted[0];
always @(*)
begin
	if(wDNoisePixel & wENoisePixel & wFNoisePixel & wGNoisePixel & wHNoisePixel  )
		wv8Fcapij	= (c+a + (2*b) )/4;
	else
	begin
	
		if((wv9Dmin ==wv9D1) & (!wDNoisePixel) & (!wENoisePixel) & (!wHNoisePixel) )
			wv8Fcapij	= (a+d+e+h)/4;
		else if((wv9Dmin ==wv9D2) & (!wGNoisePixel) & (!wHNoisePixel) )
			wv8Fcapij	= (a+b+g+h)/4;
		else if((wv9Dmin ==wv9D3) & (!wGNoisePixel)  )
			wv8Fcapij	= (b+g)/2;
		else if((wv9Dmin ==wv9D4) & (!wGNoisePixel) & (!wFNoisePixel) )
			wv8Fcapij	= (b+c+f+g)/4;
		else if((wv9Dmin ==wv9D5) & (!wDNoisePixel) & (!wENoisePixel) & (!wFNoisePixel) )
			wv8Fcapij	= (c+d+e+f)/4;
		else if((wv9Dmin ==wv9D6) & (!wDNoisePixel) & (!wENoisePixel) )
			wv8Fcapij	= (d+e)/2;
		else if((wv9Dmin ==wv9D7) & (!wHNoisePixel) )
			wv8Fcapij	= (a+h)/2;
		else if((wv9Dmin ==wv9D8) & (!wFNoisePixel) )
			wv8Fcapij	= (c+f)/2;
		else
			wv8Fcapij	= (c+a + (2*b) )/4;
	end		
end

always @(*)
begin
	if(wv4x8Sorted[1] > wv8Fcapij )
		wv8PixelOut	= wv4x8Sorted[1];
	else if(wv4x8Sorted[2] < wv8Fcapij )
		wv8PixelOut	= wv4x8Sorted[2];
	else
		wv8PixelOut	= wv8Fcapij;
end

endmodule


// //*************************** ********************************************
// // Numbers Sorting
// //************************************************************************

module mSort4 (
  // input  wire iClk,
  // input  wire iRst,
  input wire [7:0] iv8Data_0,
  input wire [7:0] iv8Data_1,
  input wire [7:0] iv8Data_2,
  input wire [7:0] iv8Data_3,
  output reg  [7:0] ov8Data_0,
  output reg  [7:0] ov8Data_1,
  output reg  [7:0] ov8Data_2,
  output reg  [7:0] ov8Data_3
  );

integer i, j;
reg [7:0] temp;
reg [7:0] wv4x8Array [3:0];

always @*
begin
  wv4x8Array[0] = iv8Data_0;
  wv4x8Array[1] = iv8Data_1;
  wv4x8Array[2] = iv8Data_2;
  wv4x8Array[3] = iv8Data_3;
  
  for (i = 3; i >= 0; i = i - 1) begin
	for (j = 0 ; j < i; j = j + 1) begin
		if (wv4x8Array[j] > wv4x8Array[j + 1])
		begin
			temp 				= wv4x8Array[j];
			wv4x8Array[j]		= wv4x8Array[j + 1];
			wv4x8Array[j + 1] 	= temp;
		end 
	end
  end 
  
  ov8Data_0 = wv4x8Array[0];
  ov8Data_1 = wv4x8Array[1];
  ov8Data_2 = wv4x8Array[2];
  ov8Data_3 = wv4x8Array[3];
  
 
end
endmodule

module mSort8 (
  // input  wire iClk,
  // input  wire iRst,
 input wire  [8:0]  iv8Data_0,
  input wire [8:0] iv8Data_1,
  input wire [8:0] iv8Data_2,
  input wire [8:0] iv8Data_3,
  input wire [8:0] iv8Data_4,
  input wire [8:0] iv8Data_5,
  input wire [8:0] iv8Data_6,
  input wire [8:0] iv8Data_7,
  output reg  [8:0] ov8Data_0,
  output reg  [8:0] ov8Data_1,
  output reg  [8:0] ov8Data_2,
  output reg  [8:0] ov8Data_3,
  output reg  [8:0] ov8Data_4,
  output reg  [8:0] ov8Data_5,
  output reg  [8:0] ov8Data_6,
  output reg  [8:0] ov8Data_7
  );

integer i, j;
reg [8:0] temp;
reg [8:0] wv8x9Array [7:0];

always @*
begin
  wv8x9Array[0] = iv8Data_0;
  wv8x9Array[1] = iv8Data_1;
  wv8x9Array[2] = iv8Data_2;
  wv8x9Array[3] = iv8Data_3;
  wv8x9Array[4] = iv8Data_4;
  wv8x9Array[5] = iv8Data_5;
  wv8x9Array[6] = iv8Data_6;
  wv8x9Array[7] = iv8Data_7;
  
  for (i = 7; i >= 0; i = i - 1) begin
	for (j = 0 ; j < i; j = j + 1) begin
		if (wv8x9Array[j] > wv8x9Array[j + 1])
		begin
			temp 				= wv8x9Array[j];
			wv8x9Array[j]		= wv8x9Array[j + 1];
			wv8x9Array[j + 1] 	= temp;
		end 
	end
  end 
  
  ov8Data_0 = wv8x9Array[0];
  ov8Data_1 = wv8x9Array[1];
  ov8Data_2 = wv8x9Array[2];
  ov8Data_3 = wv8x9Array[3];
  ov8Data_4 = wv8x9Array[4];
  ov8Data_5 = wv8x9Array[5];
  ov8Data_6 = wv8x9Array[6];
  ov8Data_7 = wv8x9Array[7];
  
  
  
end

 endmodule