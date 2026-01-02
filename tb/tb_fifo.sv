`timescale 1ns/1ps

module tb_fifo;

  localparam int DATA_WIDTH = 8;
  localparam int DEPTH      = 16;

  logic                  clk;
  logic                  rst_n;

  logic                  wr_en;
  logic [DATA_WIDTH-1:0] wr_data;
  logic                  full;

  logic                  rd_en;
  logic [DATA_WIDTH-1:0] rd_data;
  logic                  empty;

  fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk     (clk),
    .rst_n   (rst_n),
    .wr_en   (wr_en),
    .wr_data (wr_data),
    .full    (full),
    .rd_en   (rd_en),
    .rd_data (rd_data),
    .empty   (empty)
  );

  logic [DATA_WIDTH-1:0] model_q[$];
  int model_count;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, tb_fifo);
  end

  task automatic reset_dut;
    begin
      rst_n   = 1'b0;
      wr_en   = 1'b0;
      wr_data = '0;
      rd_en   = 1'b0;
      model_q.delete();
      model_count = 0;
      repeat (3) @(posedge clk);
      rst_n = 1'b1;
      repeat (2) @(posedge clk);
    end
  endtask

  task automatic check_flags(input string tag);
    begin
      #1;
      if (empty !== (model_count == 0)) begin
        $display("ERROR: empty flag wrong. model_count=%0d empty=%0b tag=%s time=%0t",
                 model_count, empty, tag, $time);
        $finish;
      end
      if (full !== (model_count == DEPTH)) begin
        $display("ERROR: full flag wrong. model_count=%0d full=%0b tag=%s time=%0t",
                 model_count, full, tag, $time);
        $finish;
      end
    end
  endtask

  task automatic drive_one_cycle(
    input bit do_wr_req,
    input logic [DATA_WIDTH-1:0] wdata,
    input bit do_rd_req
  );
    bit wr_accept, rd_accept;
    logic [DATA_WIDTH-1:0] exp;

    begin
      @(negedge clk);
      wr_en   = do_wr_req;
      wr_data = wdata;
      rd_en   = do_rd_req;

      wr_accept = do_wr_req && !full;
      rd_accept = do_rd_req && !empty;

      if (wr_accept) begin
        model_q.push_back(wdata);
      end

      if (rd_accept) begin
        exp = model_q.pop_front();
      end

      @(posedge clk);
      #1;

      if (wr_accept) $display("Write accepted, data=%0d", wdata);
      if (rd_accept) begin
        $display("Read accepted, data=%0d", rd_data);
        if (rd_data !== exp) begin
          $display("ERROR: data mismatch. expected=%0d got=%0d time=%0t", exp, rd_data, $time);
          $finish;
        end
      end

      model_count = model_q.size();
      check_flags("post_cycle");

      @(negedge clk);
      wr_en   = 1'b0;
      wr_data = '0;
      rd_en   = 1'b0;
    end
  endtask

  task automatic directed_test;
    int i;
    begin
      for (i = 0; i < 5; i++) begin
        drive_one_cycle(1'b1, logic'(i[DATA_WIDTH-1:0]), 1'b0);
      end
      for (i = 0; i < 5; i++) begin
        drive_one_cycle(1'b0, '0, 1'b1);
      end
      $display("PASS: Directed test OK");
    end
  endtask

  task automatic fill_to_full_test;
    int i;
    begin
      for (i = 0; i < DEPTH; i++) begin
        drive_one_cycle(1'b1, $urandom_range(0,255), 1'b0);
      end
      drive_one_cycle(1'b1, $urandom_range(0,255), 1'b0);
      if (full !== 1'b1) begin
        $display("ERROR: expected full=1 after filling time=%0t", $time);
        $finish;
      end
      $display("PASS: Full flag test OK");
    end
  endtask

  task automatic drain_to_empty_test;
    begin
      while (model_q.size() > 0) begin
        drive_one_cycle(1'b0, '0, 1'b1);
      end
      drive_one_cycle(1'b0, '0, 1'b1);
      if (empty !== 1'b1) begin
        $display("ERROR: expected empty=1 after draining time=%0t", $time);
        $finish;
      end
      $display("PASS: Empty flag test OK");
    end
  endtask

  task automatic random_stress(input int ncycles);
    int c;
    bit wreq, rreq;
    logic [DATA_WIDTH-1:0] wdata;
    begin
      for (c = 0; c < ncycles; c++) begin
        wreq  = ($urandom_range(0,99) < 60);
        rreq  = ($urandom_range(0,99) < 60);
        wdata = $urandom_range(0,255);
        drive_one_cycle(wreq, wdata, rreq);
      end
      $display("PASS: Random stress OK");
    end
  endtask

  initial begin
    reset_dut();
    check_flags("after_reset");

    directed_test();

    fill_to_full_test();
    drain_to_empty_test();

    random_stress(300);

    $display("PASS: All tests OK");
    #20;
    $finish;
  end

endmodule
