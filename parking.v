// First we build our main module that we will call later to execute all the tests
// The main module uses three inputs to determine if a car has entered or left the parking 
// and five outputs to show the status of each floor and that of the parking lot plus how many cars are inside and how many spots are available
module parking(out0,out1,in,cars,available,floor0,floor1,full);

// Our three inputs are determined as wire and the outputs as reg because we want to set each output based on what we get as an input
// We use two integers for internal use and to determine how many cars are in each floor
input wire out0,out1,in;
output reg floor0,floor1,full;
output reg [9:0] cars,available;
integer maxfloor0;
integer maxfloor1;

// On the initial part we set up our outputs and the two integers to their default value.
// Cars is 0 but available to 1000 because we will adding to the first one and subtracking from the second one.
initial begin
cars=10'b0000000000;
available=10'b1111101000;
floor0=1'b1;
floor1=1'b0;
full=1'b0;
maxfloor0=10'b0000000000;
maxfloor1=10'b0000000000;
end

// We fire our logic each time we get a change on our three inputs.
always @ (out0 or out1 or in)

// The main if, we check the values of each inputs and we continue based on the input that was fired.
// For the in we check also if there any available spots.
// For the two out inputs we check also if we have any car in the parking lot and in which floor.
// This way we avoid negative values in case of false positives.
if (in && available > 0) begin
cars=cars+1;
available=available-1;
	// Aftet changing cars and available, we must fire the right outputs so we have some nested ifs for each case.
    if (maxfloor0 < 500) begin
        maxfloor0=maxfloor0+1;
        if (available > 0 && maxfloor0 < 500) begin
            floor0=1'b1;
            floor1=1'b0;
            full=1'b0;
        end else
        if (available > 0 && maxfloor0 >= 500) begin
            floor0=1'b0;
            floor1=1'b1;
            full=1'b0;
        end else begin 
            floor0=1'b0;
            floor1=1'b0;
            full=1'b1;
        end
    end else begin
        maxfloor1=maxfloor1+1;
        if (available > 0 && maxfloor1 < 500) begin
            floor0=1'b0;
            floor1=1'b1;
            full=1'b0;
        end else begin 
            floor0=1'b0;
            floor1=1'b0;
            full=1'b1;
        end
    end  
end else
if (out0 && available < 1000 && maxfloor0 > 0) begin
cars=cars-1;
available=available+1;
maxfloor0=maxfloor0-1;
floor0=1'b1;
floor1=1'b0;
full=1'b0;
end else
if (out1 && available < 1000 && maxfloor1 > 0) begin
cars=cars-1;
available=available+1;
maxfloor1=maxfloor1-1;
// For the second floor a second if was needed because we want to keep the first floor output enabled if a spot is available and car leaves from the second floor.
    if (maxfloor0 < 500) begin
        floor0=1'b1;
        floor1=1'b0;
        full=1'b0;
        end else begin
        floor0=1'b0;
        floor1=1'b1;
        full=1'b0;
        end
end
endmodule

// Our top module where we will make all our tests.
module top();

// We invert our variables or else we cannot use the previous module. We also use an interger to iterate our tests.
reg OUT0,OUT1,IN;
wire FLOOR0,FLOOR1,FULL;
wire [9:0] CARS,AVAILABLE;
integer i;

parking myparking(OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);

initial begin

	// We dump everything to vcd file to use with gtkwave.
    $dumpfile("parking.vcd");
    $dumpvars(0);

  // We setup our default values and start testing.
  OUT0=1'b0;
  OUT1=1'b0;
  IN=1'b0;

    $display ("Some manual tests to verify that our three inputs work");
    $display ("\nFirst line shows all inputs and outputs initiated");
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    
    #5 $display ("\nAdding two cars");
    
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    
    #5 $display ("\nRemoving the two cars");
    
    #5 OUT0=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT0=1'b0;
    
    #5 OUT0=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT0=1'b0;
  
  $display ("\nAutomated tests to trigger FLOOR1 and FULL output");
  $display ("\nFirst fill the first floor and trigger FLOOR1");
  for (i=1; i<=505; i=i+1 ) begin
    #5 IN=1'b1;
    #5 if (i <= 10) begin
     $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end else
    if (i >= 498 && i <= 505) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end
    #5 IN=1'b0;
  end
  
    $display ("\nWe have triggered the FLOOR1 and now some more manual tests");
    $display ("\nWith triggered FLOOR1, we remove a car from the first floor to check that FLOOR1 deactivates and FLOOR0 gets fired");
    #5 OUT0=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT0=1'b0;
    
    $display ("\nWith triggered the FLOOR0, we remove a car from the second floor to check that FLOOR0 keeps its state");
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    
    $display ("\nWe add a car to check if the first floor fills up and the FLOOR1 gets triggered");
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    
    $display ("\nWe emptying the second floor but keeping the first floor filled to see if FLOOR1 keeps its state");
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    
    $display ("\nNow with empty the second floor we check that false triggering OUT1 doesn;t change anything");
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
  
  $display ("\nWe fill up everything to check what happens when FULL is triggered.");
  for (i=500; i<=1005; i=i+1 ) begin
    #5 IN=1'b1;
    if (i >= 998 && i <= 1002) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end 
    #5 IN=1'b0;
  end
  
    $display ("\nWe added some more cars to check that nothing overflows!");
    $display ("\nWe have triggered the FULL and now some more manual tests");
    $display ("\nWith triggered FULL, we remove couple of cars from the first floor to check that FULL deactivates and FLOOR0 gets fired");
    #5 OUT0=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT0=1'b0;
    #5 OUT0=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT0=1'b0;
    $display ("\nWe add back the two cars and trigger FULL then we remove a car from second floor to trigger FLOOR1!");
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    #5 OUT1=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 OUT1=1'b0;
    $display ("\nWe add back the missing car and trigger FULL again.");
    #5 IN=1'b1;
    #5 $display ("OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    #5 IN=1'b0;
    
  $display ("\nFinally we empty everything.");
  for (i=1000; i>500; i=i-1 ) begin
    #5 OUT1=1'b1;
    #5 if (i >= 995) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end else
    if (i <= 505 && i >= 500) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end
    #5 OUT1=1'b0;
  end
    for (i=500; i>0; i=i-1 ) begin
    #5 OUT0=1'b1;
    #5 if (i >= 495) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end else
    if (i <= 5 && i >= 1) begin
    $display ("%4d,OUT0=%b,OUT1=%b,IN=%b,CARS=%4d,AVAILABLE=%4d,FLOOR0=%b,FLOOR1=%b,FULL=%b", i,OUT0,OUT1,IN,CARS,AVAILABLE,FLOOR0,FLOOR1,FULL);
    end
    #5 OUT0=1'b0;
    end
 # 5 $display ("End of simulation");
 $finish;


 end
 endmodule

