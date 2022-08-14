
/**
 * Instruction format
 *
 * f ddd dddd ssss ssss
 * 1 dest mod src mod
 * 0 dest mod constant
 */
module CPU16(input wire reset, input wire clock,
    output wire [15:0] pmAddress, input wire [15:0] pmDataIn, output wire [15:0] pmDataOut, output wire pmWrite,
    output wire [15:0] dmAddress, input wire [15:0] dmDataIn, output wire [15:0] dmDataOut, output wire dmWrite);
    
    // Edge triggered registers
    reg [15:0] pc, a, b, p;
    reg [7:0] prefix;

    // Combinational
    reg [15:0] sourceValue;

    // Wires
    wire format = pmData[15];
    wire [6:0] destMod = pmData[14:8];
    wire [7:0] sourceMod = pmData[7:0];
    wire [15:0] constant = { prefix, sourceMod };

    // Guideline #3: When modeling combinational logic with an "always" 
    //              block, use blocking assignments.
    always @(*) begin
        sourceValue = 0;
        if (format == 0) begin
            sourceValue = { prefix, sourceMod };
        end else begin
            case (sourceMod)
                0: ;
                1: sourceValue = a;
                2: sourceValue = b;
                3: sourceValue = p;
                4: sourceValue = pc;
                5: sourceValue = a + b;
                6: sourceValue = a - b;
                7: sourceValue = a & b;
                8: sourceValue = a | b;
                9: sourceValue = a ^ b;
                10: sourceValue = a < b;
                11: sourceValue = a <= b;
                12: sourceValue = a == b;
                13: sourceValue = a >= b;
                14: sourceValue = a > b;
            endcase
        end
    end
    
    // Guideline #1: When modeling sequential logic, use nonblocking 
    //              assignments.
    always @(posedge clock, posedge reset) begin
        if (reset == 1) begin
        end else begin
            prefix <= 0;
            case (dest)
                0: if (format == 0) prefix <= source;
                1: a <= sourceValue;
                2: b <= sourceValue;
                3: p <= sourceValue;
                4: pc <= sourceValue;
                5: if (a == 0) pc <= sourceValue;
                6: if (a != 0) pc <= sourceValue;
            endcase
        end
    end
endmodule
