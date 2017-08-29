module mTopModule (input wire iClk,
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
						output reg oValid
						);

						
wire		wIsolateValid;
wire		wFringeValid;
wire		wFilterValid;
wire		wSimilarityValid;
wire [7:0]	wv8IsolateValidPixel;
wire [7:0]	wv8FingeValidPixel;
wire [7:0]	wv8SimilarityValidPixel;
wire [7:0]	wv8FilterValidPixel;
wire [7:0]	wv8Minij;
wire [7:0]	wv8Maxij;						

wire		wFringeDecisionOut;
wire		wIsolateDecisionOut;
wire		wSimilarityDecisionOut;						
						
mIsolateModule  uIsolateModule
	(	.iClk(iClk),
		.iRst(iRst),
		.iDataValid(iDataValid),
		.iv8Pixel_a(iv8Pixel_a),
		.iv8Pixel_b(iv8Pixel_b),
		.iv8Pixel_c(iv8Pixel_c),
		.iv8Pixel_d(iv8Pixel_d),
		.iv8Pixel_fij(iv8Pixel_fij),
		.iv8Pixel_e(iv8Pixel_e),
		.iv8Pixel_f(iv8Pixel_f),
		.iv8Pixel_g(iv8Pixel_g),
		.iv8Pixel_h(iv8Pixel_h),
		.ov8PixelOut(wv8IsolateValidPixel),
		.oValid(wIsolateValid),
		.oDecisionOut(wIsolateDecisionOut)
	);
	
mFringeModule  uFringeModule
	(	.iClk(iClk),
		.iRst(iRst),
		.iDataValid(iDataValid),
		.iEn(wIsolateDecisionOut),
		.iv8Pixel_a(iv8Pixel_a),
		.iv8Pixel_b(iv8Pixel_b),
		.iv8Pixel_c(iv8Pixel_c),
		.iv8Pixel_d(iv8Pixel_d),
		.iv8Pixel_fij(iv8Pixel_fij),
		.iv8Pixel_e(iv8Pixel_e),
		.iv8Pixel_f(iv8Pixel_f),
		.iv8Pixel_g(iv8Pixel_g),
		.iv8Pixel_h(iv8Pixel_h),
		.ov8PixelOut(wv8FingeValidPixel),
		.oValid(wFringeValid),
		.oDecisionOut(wFringeDecisionOut)
	);

mSimilarityModule  uSimilarityModule
	(	.iClk(iClk),
		.iRst(iRst),
		.iDataValid(iDataValid),
		.iEn(wFringeDecisionOut),
		.iv8Pixel_a(iv8Pixel_a),
		.iv8Pixel_b(iv8Pixel_b),
		.iv8Pixel_c(iv8Pixel_c),
		.iv8Pixel_d(iv8Pixel_d),
		.iv8Pixel_fij(iv8Pixel_fij),
		.iv8Pixel_e(iv8Pixel_e),
		.iv8Pixel_f(iv8Pixel_f),
		.iv8Pixel_g(iv8Pixel_g),
		.iv8Pixel_h(iv8Pixel_h),
		.ov8PixelOut(wv8SimilarityValidPixel),
		.oValid(wSimilarityValid),
		.ov8Maxij(wv8Maxij),
		.ov8Minij(wv8Minij),
		.oDecisionOut(wSimilarityDecisionOut)
	);
	
mFilterModule  uFilterModule
	(	.iClk(iClk),
		.iRst(iRst),
		.iDataValid(iDataValid),
		.iEn(wSimilarityDecisionOut),
		.iv8Minij(wv8Minij),
		.iv8Maxij(wv8Maxij),
		.iv8Pixel_a(iv8Pixel_a),
		.iv8Pixel_b(iv8Pixel_b),
		.iv8Pixel_c(iv8Pixel_c),
		.iv8Pixel_d(iv8Pixel_d),
		.iv8Pixel_fij(iv8Pixel_fij),
		.iv8Pixel_e(iv8Pixel_e),
		.iv8Pixel_f(iv8Pixel_f),
		.iv8Pixel_g(iv8Pixel_g),
		.iv8Pixel_h(iv8Pixel_h),
		.ov8PixelOut(wv8FilterValidPixel),
		.oValid(wFilterValid)
		//.oDecisionOut(wSimilarityDecisionOut)
	);
	
always @ (*)
begin
	if(wIsolateValid)
		ov8PixelOut		= wv8IsolateValidPixel;
	else if(wFringeValid)
		ov8PixelOut		= wv8FingeValidPixel;
	else if(wSimilarityValid)
		ov8PixelOut		= wv8SimilarityValidPixel;
	else if(wFilterValid)
		ov8PixelOut		= wv8FilterValidPixel;
	else
		ov8PixelOut		= 8'd0;
		
	oValid				= wIsolateValid |  wSimilarityValid | wFilterValid | wFringeValid;
end

endmodule