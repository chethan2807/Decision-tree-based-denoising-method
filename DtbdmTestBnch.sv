`timescale 1ns/1ns
module DtbdmTestBnch ();

 // For reading 512x512 gray scale image
//file = $fopen("filename",w); // For writing
localparam pImageWidth 	= 512;
localparam pImageHight 	= 512;
localparam pWindowHight	= 3;
localparam pWindowWidth = 3;
localparam pWindowSize  = pWindowHight*pWindowWidth;
localparam pImageSize  	= (pImageWidth)*(pImageHight);
//******************************************************************/
/* 2X2 Image with zero padding
-----------------
| 0	| 0	| 0	| 0	|
-----------------
| 0	|p0	|p1	| 0	|
-----------------
| 0	|p2	|p3	| 0	|
-----------------
| 0	| 0	| 0	| 0	|
-----------------
*/
wire		wPixelValid;
wire [7:0]	wv8ValidPixel;;

reg  		DataValid;
reg  		rRst;
reg  		rClk;
reg [7:0] 	rv8Pixel, rv8ValidPixel;
reg [31:0] 	rv32InPixelCnt, rv32RowCnt, rv32ColmCnt, rv32OutPixelCnt  ;
integer 	statusI,statusO;
integer unsigned lena512In, lena512out, i; //File handler

reg [7:0] rvImageArray [(pImageSize-1):0] ; 
reg [7:0] rv9x8WindowArray [(pWindowSize-1):0] ; // 3x3 window used for Decision tree based denoising  ; 3X3 array is converted in to [0:8] flat array for simplicity


initial begin
	rClk = 0;
	lena512In = $fopen("TestImages/lena512_Salt_papper.txt","r"); // This text file contains pixel values of lena512.bmp gray scale image
	lena512out = $fopen("OutputImage/ResultOut.txt","w"); // This text file contains pixel values of filtered image
end

always  #10 rClk = ~rClk;

initial
begin
	for (i=0; i<pWindowSize; i=i+1 )
	begin
		rv9x8WindowArray[i]		= 8'd0;
	end
end

initial
begin
	rv32InPixelCnt	= 32'd0;
	rv32OutPixelCnt	= 32'd0;
	rv32RowCnt		= 32'd0;
	rv32ColmCnt		= 32'd0;
	rv8Pixel 		= 0;
	DataValid			= 0;
	rRst 			= 1;
	//rv8Test 		= 8'd0;
	while ( ! $feof(lena512In)) 
	begin
		@ (posedge rClk);
		statusI 					= $fscanf(lena512In,"%d",rv8Pixel[7:0]);
		rvImageArray[rv32InPixelCnt]  = rv8Pixel;
		rv32InPixelCnt				= rv32InPixelCnt + 1;	
	end
	@ (posedge rClk);
	@ (posedge rClk);
	@ (posedge rClk);
	rRst 			= 0;
	@ (posedge rClk);
	@ (posedge rClk);

	for (rv32RowCnt=0; rv32RowCnt<pImageHight; rv32RowCnt=rv32RowCnt+1 )
	begin
		for (rv32ColmCnt=0; rv32ColmCnt<pImageWidth; rv32ColmCnt=rv32ColmCnt+1 )
		begin
			@ (posedge rClk);
				DataValid			= 1'b1; 
			
			rv9x8WindowArray[4]		= rvImageArray[(rv32RowCnt*pImageWidth) + rv32ColmCnt]; //Pixel to be processed
			
			//Top Half
			
			if ((rv32RowCnt >= 1) && (rv32ColmCnt >= 1)) // Check for the image boundary (i-1, j-1)
			begin
				rv9x8WindowArray[0]		= rvImageArray[((rv32RowCnt-1)*pImageWidth)+ (rv32ColmCnt-1)];
			end
			else
				rv9x8WindowArray[0]		= 8'd0;
			
			if(rv32RowCnt >= 1) // (i-1, j)
				rv9x8WindowArray[1]		= rvImageArray[((rv32RowCnt-1)*pImageWidth)+ (rv32ColmCnt)]; 
			else
				rv9x8WindowArray[1]		= 8'd0;
				
			if((rv32RowCnt >= 1) && ((rv32ColmCnt+1) < pImageWidth)) // (i-1, j+1)
				rv9x8WindowArray[2]		= rvImageArray[((rv32RowCnt-1)*pImageWidth)+ (rv32ColmCnt+1)];
			else
				rv9x8WindowArray[2]		= 8'd0;
				
			if(rv32ColmCnt >= 1) // (i, j-1)
				rv9x8WindowArray[3]		= rvImageArray[((rv32RowCnt)*pImageWidth)+ (rv32ColmCnt-1)];
			else
				rv9x8WindowArray[3]		= 8'd0;
				
			//Bottom Half
				
			if((rv32ColmCnt+1) < pImageWidth) // (i, j+1)
				rv9x8WindowArray[5]		= rvImageArray[((rv32RowCnt)*pImageWidth)+ (rv32ColmCnt+1)];
			else
				rv9x8WindowArray[5]		= 8'd0;
				
			if(((rv32RowCnt+1) < pImageHight) && (rv32ColmCnt >= 1)) // (i+1, j-1)
				rv9x8WindowArray[6]		= rvImageArray[((rv32RowCnt+1)*pImageWidth)+ (rv32ColmCnt-1)];
			else
				rv9x8WindowArray[6]		= 8'd0;
			
			if((rv32RowCnt+1) < pImageHight) // (i+1, j)
				rv9x8WindowArray[7]		= rvImageArray[((rv32RowCnt+1)*pImageWidth)+ (rv32ColmCnt)];
			else
				rv9x8WindowArray[7]		= 8'd0;
				
			if(((rv32RowCnt+1) < pImageHight) && ((rv32ColmCnt+1) < pImageWidth)) // (i+1, j+1)
				rv9x8WindowArray[8]		= rvImageArray[((rv32RowCnt+1)*pImageWidth)+ (rv32ColmCnt+1)];
			else
				rv9x8WindowArray[8]		= 8'd0;
	
			@ (posedge rClk);
				DataValid	= 1'b0; 
			wait (wPixelValid == 1); //
				rv8ValidPixel = wv8ValidPixel;
			
			rv32OutPixelCnt				= rv32OutPixelCnt + 1;	
			if((rv32OutPixelCnt % pImageWidth) != 0)
				$fwrite(lena512out,"%d\t",rv8ValidPixel);
			else
				$fwrite(lena512out,"%d\n",rv8ValidPixel);  
				
		end//Column count
		
	end // Row count
	
	$stop();
end

mTopModule  uTopModule
	(	.iClk(rClk),
		.iRst(rRst),
		.iDataValid(DataValid),
		.iv8Pixel_a(rv9x8WindowArray[0]),
		.iv8Pixel_b(rv9x8WindowArray[1]),
		.iv8Pixel_c(rv9x8WindowArray[2]),
		.iv8Pixel_d(rv9x8WindowArray[3]),
		.iv8Pixel_fij(rv9x8WindowArray[4]),
		.iv8Pixel_e(rv9x8WindowArray[5]),
		.iv8Pixel_f(rv9x8WindowArray[6]),
		.iv8Pixel_g(rv9x8WindowArray[7]),
		.iv8Pixel_h(rv9x8WindowArray[8]),
		.ov8PixelOut(wv8ValidPixel),
		.oValid(wPixelValid)
	);
	

endmodule

