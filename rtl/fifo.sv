module fifo #(
  parameter int DATA_WIDTH = 8,
  parameter int DEPTH      = 16
)(
  input  logic                  clk,
  input  logic                  rst_n,

  input  logic                  wr_en,
  input  logic [DATA_WIDTH-1:0] wr_data,
  output logic                  full,

  input  logic                  rd_en,
  output logic [DATA_WIDTH-1:0] rd_data,
  output logic                  empty
);

  localparam int ADDR_W = $clog2(DEPTH);

  logic [DATA_WIDTH-1:0] mem   [0:DEPTH-1];
  logic [ADDR_W-1:0]     wr_ptr, rd_ptr;
  logic [$clog2(DEPTH+1)-1:0] count;

  assign full  = (count == DEPTH);
  assign empty = (count == 0);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr  <= '0;
      rd_ptr  <= '0;
      count   <= '0;
      rd_data <= '0;
    end else begin
      logic do_wr, do_rd;
      do_wr = wr_en && !full;
      do_rd = rd_en && !empty;

      if (do_wr) begin
        mem[wr_ptr] <= wr_data;
        wr_ptr      <= wr_ptr + 1'b1;
      end

      if (do_rd) begin
        rd_data <= mem[rd_ptr];
        rd_ptr  <= rd_ptr + 1'b1;
      end

      case ({do_wr, do_rd})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end

endmodule
