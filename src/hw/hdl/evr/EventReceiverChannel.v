`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2015 12:21:48 PM
// Design Name: 
// Module Name: evr_EventReceiverChannel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EventReceiverChannel(
		input				Clock,
		input 				Reset,
		input   [7:0]       eventStream,
		input 	[7:0]	 	myEvent,
		input 	[31:0]		myDelay,
		input	[31:0]		myWidth,
		input				myPolarity,
		output 				trigger
    );

	 reg [31:0] delayCounter;
	 reg [31:0] widthCounter;
	 reg startDelay;
	 reg startWidth;
	 reg gen; 

	 wire trigVal;
	 wire nodelay; 
    
     assign nodelay = (myDelay == 0) ? 1 : 0; 
     
	 always @ (posedge Clock)
	 begin
		if (Reset) delayCounter <= 0;
		else if (delayCounter >= (myDelay)) delayCounter <= 0;
		else if (!startWidth && gen == 1) delayCounter <= delayCounter + 1;
		else delayCounter <= delayCounter;
	 end
	 
	 always @ (posedge Clock)
	 begin
		if (Reset) widthCounter <= 0;
		else if (widthCounter >= (myWidth)) widthCounter <= 0;
		else if (startWidth) widthCounter <= widthCounter + 1;
		else widthCounter <= widthCounter;
	 end
	 
	 always @ (posedge Clock)
	 begin
		if (Reset) startDelay <= 0;
		else if (myEvent == eventStream) startDelay <= 1; 
		else if (delayCounter == (myDelay - 1) || (nodelay)) startDelay <= 0;
		else startDelay <= startDelay;
	 end
	 
	 always @ (posedge Clock)
	 begin
		if (Reset) startWidth <= 0;
		else if (( delayCounter == (myDelay)) && gen == 1) startWidth <= 1;
		else if (widthCounter == (myWidth-1)) startWidth <= 0;
		else startWidth <= startWidth;
	 end
	 
	 always @ (posedge Clock)
	 begin 
	   if (Reset) gen <= 0; 
	   else if (myEvent == eventStream) gen <= 1;
	   else if (widthCounter == (myWidth - 2)) gen <= 0; 
	   else gen <= gen; 
	 end
	 
	 assign triggVal = (myPolarity) ? !startWidth : startWidth;
	 assign trigger = ((myDelay >= 32'd0) && (myWidth != 32'd0)) ? triggVal : 1'b0;
endmodule
