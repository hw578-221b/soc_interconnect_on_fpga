`timescale 1ns/1ns

module tb;

reg CLOCK_100 = 0;
// connection to pio ports
reg data_requested = 1, reset = 0;

reg pipeline_design = 0; // for M10K memory wrapped target, 0: non-pipelined, 1: pipelined
// target memory bank delay cycles under non-piplined mode, (3/5 + delay) cycles per write/read
// For arbitor, max data output speed to fifo is fixed at 3 cycle/packet (arb_latency + 2) (1 for serv_req to drop, 1 for busy to drop, 1 for new req_grant to raise)
reg [9:0] mem_delay_cy = 5;  // applies to non-pipelined design

// mixed read and write requests
// If the masters are not continuously backlogged, then WRR will not necessarily produce the exact configured 4:3:2:1 issue ratio. 
// A ratio like ~2:2:1:1 can absolutely happen, set all issue gap to 0 when testing WRR
// minimum arbitration latency 1 when no waiting (from latching data_out)
// ab_latency = gen_latency + 1(fixed_p & rr mode) (fixed latency due to arbiter design)
// minimum fifo latency 3: enqueue(1) + fifo_rd_en goes high(1) + dequeue(1)

reg [1:0] arb_mode = 1; // 0: fixed priority  1: round robin 2: weighted round robin
reg [2:0] address_gen_mode = 1; // 0: linear address generation, 1: pseudo random address generation, 2: hot spot address generation

reg [9:0] issue_gap0 = 0; // actual generation period when no delay should be issue_gap + 3, considering the delay of arbitration and state transition
reg [9:0] issue_gap1 = 0;
reg [9:0] issue_gap2 = 0;
reg [9:0] issue_gap3 = 0;

// address 0000-3FFF goes to bank0, 4000-7FFF goes to bank1, 8000-BFFF goes to bank2, C000-FFFF goes to bank3
reg [15:0] master0_seed = 16'h1ACE;
reg [15:0] master1_seed = 16'h45AB;
reg [15:0] master2_seed = 16'h8DF1;
reg [15:0] master3_seed = 16'hCEEF;

reg [15:0] addr_base0 = 16'h0000;
reg [15:0] addr_base1 = 16'h4000;
reg [15:0] addr_base2 = 16'h8000;
reg [15:0] addr_base3 = 16'hC000;

wire [134:0] data_packet [3:0];
wire [3:0] req_granted;
wire [3:0] serv_req;

// watch for the combinational path from serv_req->out_valid->winner->addr->fifo_full when synthesizing into FGPA!
wire [63:0] ab_latency0, ab_latency1, ab_latency2, ab_latency3;
wire [3:0] arb_lat_valid;

wire latency_valid0, latency_valid1, latency_valid2, latency_valid3;
wire [53:0] mem_out_dpacket0, mem_out_dpacket1, mem_out_dpacket2, mem_out_dpacket3;
// each master has its own fifo for recording fifo latency in qsys (4 in total), each of the fifo latency could come from 4 target sources
wire [63:0] fifo_latency0, fifo_latency1, fifo_latency2, fifo_latency3;

wire [2:0] capacity0, capacity1, capacity2, capacity3;
wire fifo_full0, fifo_full1, fifo_full2, fifo_full3, fifo_empty0, fifo_empty1, fifo_empty2, fifo_empty3;
wire fifo_wr_en;
reg fifo_wr_en0, fifo_wr_en1, fifo_wr_en2, fifo_wr_en3;
wire [134:0] dpacket_fifo_in, dpacket_fifo_out0, dpacket_fifo_out1, dpacket_fifo_out2, dpacket_fifo_out3;
wire fifo_rd_en0, fifo_rd_en1, fifo_rd_en2, fifo_rd_en3;

// For debug propose!!!
wire [2:0] out_master_id0, out_master_id1, out_master_id2, out_master_id3;
wire [31:0] out_txn_id0, out_txn_id1, out_txn_id2, out_txn_id3;
wire [15:0] out_addr0, out_addr1, out_addr2, out_addr3;
wire out_write0, out_write1, out_write2, out_write3;
wire [18:0] out_wdata0, out_wdata1, out_wdata2, out_wdata3;
wire [63:0] out_issue_ts0, out_issue_ts1, out_issue_ts2, out_issue_ts3;

assign {out_master_id0, out_txn_id0, out_addr0, out_write0, out_wdata0, out_issue_ts0} = dpacket_fifo_out0;
assign {out_master_id1, out_txn_id1, out_addr1, out_write1, out_wdata1, out_issue_ts1} = dpacket_fifo_out1;
assign {out_master_id2, out_txn_id2, out_addr2, out_write2, out_wdata2, out_issue_ts2} = dpacket_fifo_out2;
assign {out_master_id3, out_txn_id3, out_addr3, out_write3, out_wdata3, out_issue_ts3} = dpacket_fifo_out3;

wire [18:0] mem_out_data0 = mem_out_dpacket0[18:0];
wire [18:0] mem_out_data1 = mem_out_dpacket1[18:0];
wire [18:0] mem_out_data2 = mem_out_dpacket2[18:0];
wire [18:0] mem_out_data3 = mem_out_dpacket3[18:0];
// For debug propose!!!


// Latency statistics & fifo interface of master0's fifo_latency
wire m0_match0 = (latency_valid0 && (out_master_id0 == 0));
wire m0_match1 = (latency_valid1 && (out_master_id1 == 0));
wire m0_match2 = (latency_valid2 && (out_master_id2 == 0));
wire m0_match3 = (latency_valid3 && (out_master_id3 == 0));

wire [31:0] m0_fifo_lat_sum_high, m0_fifo_lat_sum_low, m0_fifo_lat_count_high, m0_fifo_lat_count_low, m0_min_fifo_lat, m0_max_fifo_lat, m0_fifo_lat_data;
wire m0_sum_overflow_flag, m0_fifo_lat_valid;

fifo_latency_stat m0_fifo_stat (.lat_sum_high(m0_fifo_lat_sum_high), .lat_sum_low(m0_fifo_lat_sum_low), .lat_count_high(m0_fifo_lat_count_high), .lat_count_low(m0_fifo_lat_count_low),
    .min_latency(m0_min_fifo_lat), .max_latency(m0_max_fifo_lat), .sum_overflow_flag(m0_sum_overflow_flag), .fifo_lat_data(m0_fifo_lat_data), .fifo_lat_valid(m0_fifo_lat_valid), 
    .data_requested(data_requested), .match0(m0_match0), .match1(m0_match1), .match2(m0_match2), .match3(m0_match3), .fifo_latency0(fifo_latency0), 
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master1's fifo_latency
wire m1_match0 = (latency_valid0 && (out_master_id0 == 1));
wire m1_match1 = (latency_valid1 && (out_master_id1 == 1));
wire m1_match2 = (latency_valid2 && (out_master_id2 == 1));
wire m1_match3 = (latency_valid3 && (out_master_id3 == 1));

wire [31:0] m1_fifo_lat_sum_high, m1_fifo_lat_sum_low, m1_fifo_lat_count_high, m1_fifo_lat_count_low, m1_min_fifo_lat, m1_max_fifo_lat, m1_fifo_lat_data;
wire m1_sum_overflow_flag, m1_fifo_lat_valid;

fifo_latency_stat m1_fifo_stat (.lat_sum_high(m1_fifo_lat_sum_high), .lat_sum_low(m1_fifo_lat_sum_low), .lat_count_high(m1_fifo_lat_count_high), .lat_count_low(m1_fifo_lat_count_low),
    .min_latency(m1_min_fifo_lat), .max_latency(m1_max_fifo_lat), .sum_overflow_flag(m1_sum_overflow_flag), .fifo_lat_data(m1_fifo_lat_data), .fifo_lat_valid(m1_fifo_lat_valid), 
    .data_requested(data_requested), .match0(m1_match0), .match1(m1_match1), .match2(m1_match2), .match3(m1_match3), .fifo_latency0(fifo_latency0), 
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master2's fifo_latency
wire m2_match0 = (latency_valid0 && (out_master_id0 == 2));
wire m2_match1 = (latency_valid1 && (out_master_id1 == 2));
wire m2_match2 = (latency_valid2 && (out_master_id2 == 2));
wire m2_match3 = (latency_valid3 && (out_master_id3 == 2));

wire [31:0] m2_fifo_lat_sum_high, m2_fifo_lat_sum_low, m2_fifo_lat_count_high, m2_fifo_lat_count_low, m2_min_fifo_lat, m2_max_fifo_lat, m2_fifo_lat_data;
wire m2_sum_overflow_flag, m2_fifo_lat_valid;

fifo_latency_stat m2_fifo_stat (.lat_sum_high(m2_fifo_lat_sum_high), .lat_sum_low(m2_fifo_lat_sum_low), .lat_count_high(m2_fifo_lat_count_high), .lat_count_low(m2_fifo_lat_count_low),
    .min_latency(m2_min_fifo_lat), .max_latency(m2_max_fifo_lat), .sum_overflow_flag(m2_sum_overflow_flag), .fifo_lat_data(m2_fifo_lat_data), .fifo_lat_valid(m2_fifo_lat_valid), 
    .data_requested(data_requested), .match0(m2_match0), .match1(m2_match1), .match2(m2_match2), .match3(m2_match3), .fifo_latency0(fifo_latency0), 
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master3's fifo_latency
wire m3_match0 = (latency_valid0 && (out_master_id0 == 3));
wire m3_match1 = (latency_valid1 && (out_master_id1 == 3));
wire m3_match2 = (latency_valid2 && (out_master_id2 == 3));
wire m3_match3 = (latency_valid3 && (out_master_id3 == 3));

wire [31:0] m3_fifo_lat_sum_high, m3_fifo_lat_sum_low, m3_fifo_lat_count_high, m3_fifo_lat_count_low, m3_min_fifo_lat, m3_max_fifo_lat, m3_fifo_lat_data;
wire m3_sum_overflow_flag, m3_fifo_lat_valid;

fifo_latency_stat m3_fifo_stat (.lat_sum_high(m3_fifo_lat_sum_high), .lat_sum_low(m3_fifo_lat_sum_low), .lat_count_high(m3_fifo_lat_count_high), .lat_count_low(m3_fifo_lat_count_low),
    .min_latency(m3_min_fifo_lat), .max_latency(m3_max_fifo_lat), .sum_overflow_flag(m3_sum_overflow_flag), .fifo_lat_data(m3_fifo_lat_data), .fifo_lat_valid(m3_fifo_lat_valid), 
    .data_requested(data_requested), .match0(m3_match0), .match1(m3_match1), .match2(m3_match2), .match3(m3_match3), .fifo_latency0(fifo_latency0), 
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_100), .reset(reset));


// Statistical & fifo interface of master0's arb_latency
wire [31:0] m0_ab_lat_sum_high, m0_ab_lat_sum_low, m0_ab_lat_count_high, m0_ab_lat_count_low, m0_ab_min_latency, m0_ab_max_latency;
wire m0_ab_sum_overflow_flag;

arb_latency_stat m0_ab_stat (.lat_sum_high(m0_ab_lat_sum_high), .lat_sum_low(m0_ab_lat_sum_low), .lat_count_high(m0_ab_lat_count_high), .lat_count_low(m0_ab_lat_count_low),
    .min_latency(m0_ab_min_latency), .max_latency(m0_ab_max_latency), .sum_overflow_flag(m0_ab_sum_overflow_flag), .ab_latency(ab_latency0), .ab_lat_valid(arb_lat_valid[0]),
    .data_requested(data_requested), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master1's arb_latency
wire [31:0] m1_ab_lat_sum_high, m1_ab_lat_sum_low, m1_ab_lat_count_high, m1_ab_lat_count_low, m1_ab_min_latency, m1_ab_max_latency;
wire m1_ab_sum_overflow_flag;

arb_latency_stat m1_ab_stat (.lat_sum_high(m1_ab_lat_sum_high), .lat_sum_low(m1_ab_lat_sum_low), .lat_count_high(m1_ab_lat_count_high), .lat_count_low(m1_ab_lat_count_low),
    .min_latency(m1_ab_min_latency), .max_latency(m1_ab_max_latency), .sum_overflow_flag(m1_ab_sum_overflow_flag), .ab_latency(ab_latency1), .ab_lat_valid(arb_lat_valid[1]),
    .data_requested(data_requested), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master2's arb_latency
wire [31:0] m2_ab_lat_sum_high, m2_ab_lat_sum_low, m2_ab_lat_count_high, m2_ab_lat_count_low, m2_ab_min_latency, m2_ab_max_latency;
wire m2_ab_sum_overflow_flag;

arb_latency_stat m2_ab_stat (.lat_sum_high(m2_ab_lat_sum_high), .lat_sum_low(m2_ab_lat_sum_low), .lat_count_high(m2_ab_lat_count_high), .lat_count_low(m2_ab_lat_count_low),
    .min_latency(m2_ab_min_latency), .max_latency(m2_ab_max_latency), .sum_overflow_flag(m2_ab_sum_overflow_flag), .ab_latency(ab_latency2), .ab_lat_valid(arb_lat_valid[2]),
    .data_requested(data_requested), .clk(CLOCK_100), .reset(reset));

// Statistical & fifo interface of master3's arb_latency
wire [31:0] m3_ab_lat_sum_high, m3_ab_lat_sum_low, m3_ab_lat_count_high, m3_ab_lat_count_low, m3_ab_min_latency, m3_ab_max_latency;
wire m3_ab_sum_overflow_flag;

arb_latency_stat m3_ab_stat (.lat_sum_high(m3_ab_lat_sum_high), .lat_sum_low(m3_ab_lat_sum_low), .lat_count_high(m3_ab_lat_count_high), .lat_count_low(m3_ab_lat_count_low),
    .min_latency(m3_ab_min_latency), .max_latency(m3_ab_max_latency), .sum_overflow_flag(m3_ab_sum_overflow_flag), .ab_latency(ab_latency3), .ab_lat_valid(arb_lat_valid[3]),
    .data_requested(data_requested), .clk(CLOCK_100), .reset(reset));

// Module instantiation

// Memory bank 0
memory_bank_target target0 (.fifo_rd_en(fifo_rd_en0), .out_dpacket(mem_out_dpacket0), .out_valid(latency_valid0), .fifo_latency(fifo_latency0),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out0), .fifo_empty(fifo_empty0), .clk(CLOCK_100), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo0 (.dpacket_out(dpacket_fifo_out0), .capacity(capacity0),
    .full(fifo_full0), .empty(fifo_empty0), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en0), .rd_en(fifo_rd_en0), .clk(CLOCK_100), .reset(reset));

// Memory bank 1
memory_bank_target target1 (.fifo_rd_en(fifo_rd_en1), .out_dpacket(mem_out_dpacket1), .out_valid(latency_valid1), .fifo_latency(fifo_latency1),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out1), .fifo_empty(fifo_empty1), .clk(CLOCK_100), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo1 (.dpacket_out(dpacket_fifo_out1), .capacity(capacity1),
    .full(fifo_full1), .empty(fifo_empty1), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en1), .rd_en(fifo_rd_en1), .clk(CLOCK_100), .reset(reset));

// Memory bank 2
memory_bank_target target2 (.fifo_rd_en(fifo_rd_en2), .out_dpacket(mem_out_dpacket2), .out_valid(latency_valid2), .fifo_latency(fifo_latency2),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out2), .fifo_empty(fifo_empty2), .clk(CLOCK_100), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo2 (.dpacket_out(dpacket_fifo_out2), .capacity(capacity2),
    .full(fifo_full2), .empty(fifo_empty2), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en2), .rd_en(fifo_rd_en2), .clk(CLOCK_100), .reset(reset));

// Memory bank 3
memory_bank_target target3 (.fifo_rd_en(fifo_rd_en3), .out_dpacket(mem_out_dpacket3), .out_valid(latency_valid3), .fifo_latency(fifo_latency3),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out3), .fifo_empty(fifo_empty3), .clk(CLOCK_100), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo3 (.dpacket_out(dpacket_fifo_out3), .capacity(capacity3),
    .full(fifo_full3), .empty(fifo_empty3), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en3), .rd_en(fifo_rd_en3), .clk(CLOCK_100), .reset(reset));

// Arbiter ouput goes to different target memory banks/fifos based on the data address decoding
wire [15:0] addr = dpacket_fifo_in[99:84];
always @(*) begin
    if(addr >= 0 && addr < 16'h4000) // goes to target bank0
        fifo_wr_en0 = fifo_wr_en;
    else fifo_wr_en0 = 0;

    if(addr >= 16'h4000 && addr < 16'h8000) // goes to target bank1
        fifo_wr_en1 = fifo_wr_en;
    else fifo_wr_en1 = 0;

    if(addr >= 16'h8000 && addr < 16'hC000) // goes to target bank2
        fifo_wr_en2 = fifo_wr_en;
    else fifo_wr_en2 = 0;
   
    if(addr >= 16'hC000 && addr <= 16'hFFFF) // goes to target bank3
        fifo_wr_en3 = fifo_wr_en;
    else fifo_wr_en3 = 0;
end

// Record the issue count for different masters
reg [31:0] m0_issue_ctr, m1_issue_ctr, m2_issue_ctr, m3_issue_ctr;
always @(posedge CLOCK_100) begin
    if(reset) begin
        m0_issue_ctr <= 0;
        m1_issue_ctr <= 0;
        m2_issue_ctr <= 0;
        m3_issue_ctr <= 0;
    end
    else begin
        if(arb_lat_valid[0])
            m0_issue_ctr <= m0_issue_ctr + 1;
        else if(arb_lat_valid[1])
            m1_issue_ctr <= m1_issue_ctr + 1;
        else if(arb_lat_valid[2])
            m2_issue_ctr <= m2_issue_ctr + 1;
        else if(arb_lat_valid[3])
            m3_issue_ctr <= m3_issue_ctr + 1;       
        
        // overflow prevention while keeping relative ratio the same
        if(m0_issue_ctr >= 16'hFFFF || m1_issue_ctr >= 16'hFFFF || m2_issue_ctr >= 16'hFFFF || m3_issue_ctr >= 16'hFFFF) begin
            m0_issue_ctr <= m0_issue_ctr >> 2;
            m1_issue_ctr <= m1_issue_ctr >> 2;
            m2_issue_ctr <= m2_issue_ctr >> 2;
            m3_issue_ctr <= m3_issue_ctr >> 2;
        end
    end
end

arbiter arb (.fifo_wr_en(fifo_wr_en), .data_out(dpacket_fifo_in), .arb_lat_valid(arb_lat_valid), .ab_latency0(ab_latency0), .ab_latency1(ab_latency1), .ab_latency2(ab_latency2), .ab_latency3(ab_latency3),
        .arb_mode(arb_mode), .fifo_full0(fifo_full0), .fifo_full1(fifo_full1), .fifo_full2(fifo_full2), .fifo_full3(fifo_full3),
        .req_granted(req_granted), .data_in0(data_packet[0]), .data_in1(data_packet[1]), .data_in2(data_packet[2]), .data_in3(data_packet[3]), 
        .serv_req(serv_req), .clk(CLOCK_100), .reset(reset));

traffic_gen #(.MASTER_ID(0))
traffic0 (.data_packet(data_packet[0]), .serv_req(serv_req[0]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master0_seed),
        .addr_base(addr_base0), .issue_gap(issue_gap0), .req_granted(req_granted[0]), .clk(CLOCK_100), .reset(reset));

traffic_gen #(.MASTER_ID(1))
traffic1 (.data_packet(data_packet[1]), .serv_req(serv_req[1]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master1_seed),
        .addr_base(addr_base1), .issue_gap(issue_gap1), .req_granted(req_granted[1]), .clk(CLOCK_100), .reset(reset));

traffic_gen #(.MASTER_ID(2))
traffic2 (.data_packet(data_packet[2]), .serv_req(serv_req[2]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master2_seed),
        .addr_base(addr_base2), .issue_gap(issue_gap2), .req_granted(req_granted[2]), .clk(CLOCK_100), .reset(reset));

traffic_gen #(.MASTER_ID(3))
traffic3 (.data_packet(data_packet[3]), .serv_req(serv_req[3]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master3_seed),
        .addr_base(addr_base3), .issue_gap(issue_gap3), .req_granted(req_granted[3]), .clk(CLOCK_100), .reset(reset));


// Generate 100MHz clock
always #5 CLOCK_100 = ~ CLOCK_100;

initial begin
    reset = 1;
    repeat(2) @(posedge CLOCK_100);
    reset = 0;
end

initial begin
    forever begin
        m0_flat_ready = 1;
        repeat(300) @(posedge CLOCK_100);
        m0_flat_ready = 0;
        repeat(300) @(posedge CLOCK_100);
    end
end

endmodule

// change the clock speed to be slower than arbiter & fifo speed (for piplined design), so CDC issues and asynchonous fifo could be part of the story!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module fifo_latency_stat (
    output reg [31:0] lat_sum_high,
    output reg [31:0] lat_sum_low,
    output reg [31:0] lat_count_high,
    output reg [31:0] lat_count_low,
    output reg [31:0] min_latency,
    output reg [31:0] max_latency,
    output reg sum_overflow_flag,  // for debug purpose, should not happen in normal operation with 64 bit accumulator
    output [31:0] fifo_lat_data, // Avalon fifo interface
    output fifo_lat_valid, // Avalon fifo interface
    input data_requested, // send by hps to request data read
    input match0, // check if the data for certain master comes from bank0
    input match1,
    input match2,
    input match3,
    input [63:0] fifo_latency0, // fifo latency data from bank 0
    input [63:0] fifo_latency1,
    input [63:0] fifo_latency2,
    input [63:0] fifo_latency3,
    input clk,
    input reset
);

reg[63:0] min_lat, max_lat, min_lat_next, max_lat_next, lat_sum, lat_count;

// add latency in case more than 1 memory bank have the same master data input
wire [63:0] latency_allbank = (match0? fifo_latency0 : 0) + (match1? fifo_latency1 : 0) + (match2? fifo_latency2 : 0) + (match3? fifo_latency3 : 0);
wire [2:0] data_count_allbank = match0 + match1 + match2 + match3;

assign fifo_lat_data ={latency_allbank[28:0], data_count_allbank}; // pack the latency and the number of contributed sources together to send through fifo
assign fifo_lat_valid = (match0 || match1 || match2 || match3);

// combinationally calculate next min & max latency
always @(*) begin
    // set default value avoid inferred latch
    // default is the current min/max value, so it updates only when new latency is smaller/larger than current value
    min_lat_next = min_lat;
    max_lat_next = max_lat;

    if (match0) begin
        if (fifo_latency0 < min_lat_next) min_lat_next = fifo_latency0;
        if (fifo_latency0 > max_lat_next) max_lat_next = fifo_latency0;
    end
    if (match1) begin
        if (fifo_latency1 < min_lat_next) min_lat_next = fifo_latency1;
        if (fifo_latency1 > max_lat_next) max_lat_next = fifo_latency1;
    end
    if (match2) begin
        if (fifo_latency2 < min_lat_next) min_lat_next = fifo_latency2;
        if (fifo_latency2 > max_lat_next) max_lat_next = fifo_latency2;
    end
    if (match3) begin
        if (fifo_latency3 < min_lat_next) min_lat_next = fifo_latency3;
        if (fifo_latency3 > max_lat_next) max_lat_next = fifo_latency3;
    end
end

// calculate/latch latency statistics, reset at fpga reset
always @(posedge clk) begin
    if(reset) begin
        lat_sum <= 0;
        lat_count <= 0;
        min_lat <= 64'hFFFFFFFF;
        max_lat <= 0;
        sum_overflow_flag <= 0;
    end
    else begin
        if (fifo_lat_valid) begin
            // update current min and max latency
            min_lat <= min_lat_next;
            max_lat <= max_lat_next;
            // calculate latency sum and latency count
            lat_sum <= lat_sum + latency_allbank;
            lat_count <= lat_count + data_count_allbank;
            sum_overflow_flag <= (lat_sum + latency_allbank < lat_sum)? 1 : 0;
        end
        // hps only read the latched statitics register by sending request instead of the raw register, to avoid inconsistent data caused by read latency in hps
        if (data_requested) begin
            lat_sum_high <= lat_sum[63:32];
            lat_sum_low <= lat_sum[31:0];
            lat_count_high <= lat_count[63:32];
            lat_count_low <= lat_count[31:0];
            min_latency <= min_lat[31:0];
            max_latency <= max_lat[31:0];
        end
    end
end
endmodule

module arb_latency_stat (
    output reg [31:0] lat_sum_high,
    output reg [31:0] lat_sum_low,
    output reg [31:0] lat_count_high,
    output reg [31:0] lat_count_low,
    output reg [31:0] min_latency,
    output reg [31:0] max_latency,
    output reg sum_overflow_flag,
    input [63:0] ab_latency,
    input ab_lat_valid,
    input data_requested,
    input clk,
    input reset
);

reg [63:0] min_lat, max_lat, lat_sum, lat_count;

always@ (posedge clk) begin
    if(reset) begin
        lat_sum <= 0;
        lat_count <= 0;
        min_lat <= 64'hFFFFFFFF;
        max_lat <= 0;
        sum_overflow_flag <= 0;
    end
    else begin
        if(ab_lat_valid) begin
            min_lat <= (ab_latency < min_lat)? ab_latency : min_lat;
            max_lat <= (ab_latency > max_lat)? ab_latency : max_lat;
            lat_sum <= lat_sum + ab_latency;
            lat_count <= lat_count + 1;
            sum_overflow_flag <= (lat_sum + ab_latency < lat_sum)? 1 : 0;
        end
        if(data_requested) begin
            lat_sum_high <= lat_sum[63:32];
            lat_sum_low <= lat_sum[31:0];
            lat_count_high <= lat_count[63:32];
            lat_count_low <= lat_count[31:0];
            min_latency <= min_lat[31:0];
            max_latency <= max_lat[31:0];
        end
    end
end
endmodule

// piplined design for high throughput processing (accpets new data every cycle)
module memory_bank_target (
    output fifo_rd_en,                 // pull high to get data from fifo, controlled by fifo_empty and bank_ready
    output reg [53:0] out_dpacket,     // data read from memory if the data packet is read request
    output reg out_valid,              // latency read from new data packet is ready
    output reg [63:0] fifo_latency,   // time wait in the fifo for request from master before entering target
    input pipelined,
    input [9:0] delay_cycles,
    input [134:0] data_in,             // controlled by fifo_rd_en
    input fifo_empty,
    input clk,
    input reset
);

reg we, bank_ready; // pulse high when ready to get data from fifo (always 1 in piplined design)
reg [2:0] state;
reg [9:0] counter;
reg [18:0] memory_write;
wire [18:0] memory_read;
reg [13:0] write_address, read_address; // address from 0 to 16384

wire [2:0] master_id;
wire [31:0] txn_id;
wire [15:0] addr;
wire write;
wire [18:0] wdata;
wire [63:0] latency;
assign {master_id, txn_id, addr, write, wdata, latency} = data_in;

reg s0_valid, s1_valid, s2_valid, s3_valid;
reg [2:0] master_id1, master_id2;
reg [31:0] txn_id1, txn_id2;

assign fifo_rd_en = (~fifo_empty) & bank_ready;

M10K memory (.q(memory_read), .d(memory_write), .we(we), .write_address(write_address), .read_address(read_address), .clk(clk));

always @(posedge clk) begin
    if(reset) begin
        write_address <= 0;
        read_address <= 0;
        we <= 0;
        out_valid <= 0;
        fifo_latency <= 0;
        s0_valid <= 1;  // s0 is always valid (check every cycle for fifo_rd_en)
        s1_valid <= 0;
        s2_valid <= 0;
        s3_valid <= 0;
        bank_ready <= 0;
        state <= 0;
        counter <= 0;
    end
    else begin
        // Pipelined architecture design (accept read/write request every cycle)
        if(pipelined) begin
            // Ensure they only pulse high for 1 cycle when needed
            out_valid <= 0;
            we <= 0;
            // always ready to accept new data
            bank_ready <= 1;

            // S0: Wait until fifo is not empty before reading it (1 cycle delay from fifo_rd_en goes high to data latched into data_in)
            if(s0_valid) begin
                s1_valid <= (fifo_rd_en)? 1 : 0;
            end
            // S1: Determine the request type and process, ends here if it's a write request
            if(s1_valid) begin
                if (write == 1) begin // data will be in memory 2 cycles later
                    we <= 1;
                    write_address <= (addr >> 2); // divide by 4 to accomodate memory capacity (16 bit to 14 bit address)
                    memory_write <= wdata;
                    s2_valid <= 0;
                end
                else begin
                    read_address <= (addr >> 2); // data will be ready 2 cycles later due to double-registered read
                    master_id1 <= master_id;
                    txn_id1 <= txn_id;
                    s2_valid <= 1;
                end
                out_valid <= 1;
                fifo_latency <= latency; // minimum latency 2: enqueue(1) + dequeue(1)
            end
            else begin
                s2_valid <= 0;
            end
            // S2: buffer stage to wait for data read (takes 2 cycles)
            if(s2_valid) begin
                master_id2 <= master_id1;
                txn_id2 <= txn_id1;
                s3_valid <= 1;
            end
            else begin
                s3_valid <= 0;
            end
            // S3: get the data from memory read
            if(s3_valid) begin
                out_dpacket <= {master_id2, txn_id2, memory_read};
            end
        end

        // Non-pipelined architecture design (accept write/read every (3/5 + delay) cycles)
        else begin
            // reset we and out_valid so that they only pulsed high for 1 cycle
            out_valid <= 0;
            we <= 0;
            case(state)
                // Wait until fifo is not empty before reading it
                0: begin
                    counter <= 0; // reset the counter
                    if(!fifo_empty) begin // if there is data inside fifo, go to next stage (delay/read)
                        if(delay_cycles == 0) begin // if no delay, directly go to process data stage
                            bank_ready <= 1;
                            state <= 2;
                        end
                        else state <= 1; // else go to delay stage                
                    end
                    else state <= 0; // else stay until fifo has data
                end
                // Delay stage
                1: begin
                    counter <= counter + 1;
                    if(counter == delay_cycles - 1) begin
                        bank_ready <= 1;
                        state <= 2;
                    end
                    else state <= 1;
                end
                // Account for 1 cycle delay from fifo_rd_en goes high to data latched into data_in
                2: begin
                    bank_ready <= 0; // reset bank_ready so it pulse high for only 1 cycle
                    state <= 3;
                end
                // Determine the request type, latch the data from fifo if write type
                3: begin
                    if (write == 1) begin // data will be in memory 2 cycles later
                        we <= write;
                        write_address <= (addr >> 2); // divide by 4 to accomodate memory capacity (16 bit to 14 bit address)
                        memory_write <= wdata;
                        state <= 0;
                    end
                    else begin
                        read_address <= (addr >> 2); // memory_read will get the data 2 cycles later
                        state <= 4;
                    end
                    out_valid <= 1;
                    fifo_latency <= latency; // minimum latency 3: enqueue(1) + fifo_rd_en goes high(1) + dequeue(1)
                end
                // Wait for memory read to complete
                4: begin
                    state <= 5;
                end
                // Read data from memory and output result
                5: begin
                    out_dpacket <= {master_id, txn_id, memory_read};
                    state <= 0;
                end
            endcase
        end
    end
end

endmodule


// In the future, consider changing it to asynchronous fifo!!!!!!!!!!
// write and read are in different clock domains; gray-coded pointers, synchronizers, CDC issues

module sync_ring_fifo #(
    parameter WIDTH = 135,
    parameter DEPTH = 8,
    parameter ADDRESS_W = 3 // log2(DEPTH) 
)(
    output reg [WIDTH-1:0] dpacket_out,
    output reg [ADDRESS_W-1:0] capacity,
    output full,
    output empty,
    input [WIDTH-1:0] dpacket_in,
    input wr_en,
    input rd_en,
    input clk,
    input reset
);

reg [WIDTH-1:0] mem [DEPTH-1:0];
reg [ADDRESS_W-1:0] rd_ptr, wr_ptr;

assign empty = (capacity == 0);
assign full = (capacity == (DEPTH - 1));

wire [63:0] time_stamp;
global_ctr ts (.time_stamp(time_stamp), .clk(clk), .reset(reset));

always @(posedge clk) begin
    if(reset) begin
        capacity <= 0;
        rd_ptr <= 0;
        wr_ptr <= 0;
    end
    else begin
        case ({wr_en && !full, rd_en && !empty})
            // enqueue only
            2'b10 : begin
                mem[wr_ptr] <= dpacket_in;
                wr_ptr <= (wr_ptr == (DEPTH - 1))? 0 : (wr_ptr + 1);
                capacity <= capacity + 1;
            end

            // dequeue only
            2'b01 : begin
                dpacket_out <= {mem[rd_ptr][134:64], (time_stamp - mem[rd_ptr][63:0])};
                rd_ptr <= (rd_ptr == (DEPTH - 1))? 0 : (rd_ptr + 1);
                capacity <= capacity - 1;
            end

            // enqueue and dequeue at the same time
            2'b11 : begin
                mem[wr_ptr] <= dpacket_in;
                dpacket_out <= {mem[rd_ptr][134:64], (time_stamp - mem[rd_ptr][63:0])};
                wr_ptr <= (wr_ptr == (DEPTH - 1))? 0 : (wr_ptr + 1);
                rd_ptr <= (rd_ptr == (DEPTH - 1))? 0 : (rd_ptr + 1);
                capacity <= capacity; // capacity unchanged
            end
        endcase
    end
end

endmodule

// Handshake mechanism: (with traffic_gen masters)
// aribter side, init req_granted to 0, if this master is selected, if serv_req == 1, change req_granted to 1, others to 0, then process data
// master side, after exit gap interval, generate data, then pull serv_req high, wait until req_granted == 1 (arbiter has processed the data), then enter gap interval and pull serv_req low
module arbiter #(
    parameter MASTER_NUM = 4
)(
    output fifo_wr_en,
    output reg [134:0] data_out,
    output reg [MASTER_NUM-1:0] req_granted,
    output reg [MASTER_NUM-1:0] arb_lat_valid,
    output reg [63:0] ab_latency0,
    output reg [63:0] ab_latency1,
    output reg [63:0] ab_latency2,
    output reg [63:0] ab_latency3,
    input [1:0] arb_mode,
    input fifo_full0,
    input fifo_full1,
    input fifo_full2,
    input fifo_full3,
    input [134:0] data_in0,
    input [134:0] data_in1,
    input [134:0] data_in2,
    input [134:0] data_in3,
    input [MASTER_NUM-1:0] serv_req,
    input clk,
    input reset
);

localparam [2:0] weight_m0 = 4, weight_m1 = 3, weight_m2 = 2, weight_m3 = 1; // can be changed according to priority needs!

reg [2:0] rr_ptr;
reg [2:0] quota_m0, quota_m1, quota_m2, quota_m3;
reg busy;
// record if there is any valid output from the arbiter (any of the master requested)
reg [MASTER_NUM-1:0] out_valid; // combinational signal used when not busy, to reduce arbitration processing cycles!!!
reg [MASTER_NUM-1:0] active_valid; // registered version of out_valid when busy, used to remember which master is being processed!!!
wire [MASTER_NUM-1:0] winner = busy? active_valid : out_valid; // used for bank/fifo selection
reg [31:0] prev_txn_id;
reg [31:0] out_txn_id;

// only write to fifo when new data comes (with a different txn_id)
assign fifo_wr_en = (prev_txn_id != out_txn_id)? 1 : 0;

wire [63:0] time_stamp;
global_ctr ts (.time_stamp(time_stamp), .clk(clk), .reset(reset));

// Combinationally change the out_valid to reduce arbitration processing cycles
always @(*) begin
    out_valid = 0; // default value to aviod latch inference (use active_valid to remember winner when not busy)
    if(!busy) begin // arbitrate only when there is no actively processing request (avoid mid winner switching + reduce switching & save power)
        case (arb_mode)
            // fixed prority arbitration mode
            2'd0: begin
                if (serv_req[0]) out_valid = 4'b0001;
                else if (serv_req[1]) out_valid = 4'b0010;
                else if (serv_req[2]) out_valid = 4'b0100;
                else if (serv_req[3]) out_valid = 4'b1000;
                else out_valid = 0;
            end

            // round robin/ weighted-rr arbitration mode
            2'd1, 2'd2: begin
                case(rr_ptr)
                    3'd0: begin
                        if (serv_req[0]) out_valid = 4'b0001;
                        else if (serv_req[1]) out_valid = 4'b0010;
                        else if (serv_req[2]) out_valid = 4'b0100;
                        else if (serv_req[3]) out_valid = 4'b1000;
                        else out_valid = 0;
                    end
                    3'd1: begin
                        if (serv_req[1]) out_valid = 4'b0010;
                        else if (serv_req[2]) out_valid = 4'b0100;
                        else if (serv_req[3]) out_valid = 4'b1000;
                        else if (serv_req[0]) out_valid = 4'b0001;
                        else out_valid = 0;
                    end
                    3'd2: begin
                        if (serv_req[2]) out_valid = 4'b0100;
                        else if (serv_req[3]) out_valid = 4'b1000;
                        else if (serv_req[0]) out_valid = 4'b0001;
                        else if (serv_req[1]) out_valid = 4'b0010;
                        else out_valid = 0;
                    end
                    3'd3: begin
                        if (serv_req[3]) out_valid = 4'b1000;
                        else if (serv_req[0]) out_valid = 4'b0001;
                        else if (serv_req[1]) out_valid = 4'b0010;
                        else if (serv_req[2]) out_valid = 4'b0100;
                        else out_valid = 0;
                    end
                    default: out_valid = 0;
                endcase
            end
        endcase
    end
end

reg [15:0] addr;
reg fifo_full;

// combinationally select which fifo to check based on the address of the arbitration winner data
always @(*) begin
    case (winner)
        4'b0001: addr = data_in0[99:84];
        4'b0010: addr = data_in1[99:84];
        4'b0100: addr = data_in2[99:84];
        4'b1000: addr = data_in3[99:84];
        default: addr = 0;
    endcase
    
    case (addr[15:14])
        2'b00: fifo_full = fifo_full0;
        2'b01: fifo_full = fifo_full1;
        2'b10: fifo_full = fifo_full2;
        2'b11: fifo_full = fifo_full3;
        default: fifo_full = 1; // block if no valid winner/address 
    endcase
end

// Main procedural block for arbitration output
always @(posedge clk) begin
    if (reset) begin
        rr_ptr <= 3'd0;
        busy <= 0;
        req_granted <= 0;
        prev_txn_id <= 32'hFFFFFFFF;
        out_txn_id <= 32'hFFFFFFFF;
        active_valid <= 0;
        arb_lat_valid <= 0;
        ab_latency0 <= 0;
        ab_latency1 <= 0;
        ab_latency2 <= 0;
        ab_latency3 <= 0;
        quota_m0 <= weight_m0;
        quota_m1 <= weight_m1;
        quota_m2 <= weight_m2;
        quota_m3 <= weight_m3;
    end
    else begin
        case (arb_mode)
            // process requests of different masters in fixed-priority manner
            2'd0: begin
                // process arbiteration result only when not already busy processing another one                 
                if(!busy) begin
                    // Check if FIFO is full & there is active request before processing
                    if (!fifo_full && out_valid != 0) begin
                        active_valid <= out_valid; // save 1 cycle of arbitration processing time by registering it in the meantime 

                        case(out_valid) // update timestamp to when data goes out of arbiter
                            4'b0001: begin
                                data_out <= {data_in0[134:64], time_stamp}; out_txn_id <= data_in0[131:100]; 
                                req_granted <= 4'b0001; busy <= 1;
                            end
                            4'b0010: begin
                                data_out <= {data_in1[134:64], time_stamp}; out_txn_id <= data_in1[131:100]; 
                                req_granted <= 4'b0010; busy <= 1;
                            end
                            4'b0100: begin
                                data_out <= {data_in2[134:64], time_stamp}; out_txn_id <= data_in2[131:100]; 
                                req_granted <= 4'b0100; busy <= 1;
                            end
                            4'b1000: begin
                                data_out <= {data_in3[134:64], time_stamp}; out_txn_id <= data_in3[131:100]; 
                                req_granted <= 4'b1000; busy <= 1;
                            end
                        endcase
                    end
                end
                // when busy, wait current request for winner master to complete
                else begin
                    // since active_valid is one-hot type (only one bit is 1 per time), can use active_valid & serv_req to determine if serv_req for selected master is low
                    if (((active_valid & serv_req) == 0)) begin
                        busy <= 0;
                        req_granted <= 0;
                        active_valid <= 0;
                    end
                end
            end

            // process requests in round robin manner
            2'd1: begin       
                // process arbiteration result only when not already busy processing another one                 
                if(!busy) begin
                    // Check if FIFO is full & there is active request before processing
                    if (!fifo_full && out_valid != 0) begin
                        active_valid <= out_valid;

                        case(out_valid) // update timestamp to when data goes out of arbiter
                            4'b0001: begin
                                data_out <= {data_in0[134:64], time_stamp}; out_txn_id <= data_in0[131:100]; 
                                req_granted <= 4'b0001; busy <= 1;
                            end
                            4'b0010: begin
                                data_out <= {data_in1[134:64], time_stamp}; out_txn_id <= data_in1[131:100]; 
                                req_granted <= 4'b0010; busy <= 1;
                            end
                            4'b0100: begin
                                data_out <= {data_in2[134:64], time_stamp}; out_txn_id <= data_in2[131:100]; 
                                req_granted <= 4'b0100; busy <= 1;
                            end
                            4'b1000: begin
                                data_out <= {data_in3[134:64], time_stamp}; out_txn_id <= data_in3[131:100]; 
                                req_granted <= 4'b1000; busy <= 1;
                            end
                        endcase
                    end
                end
                // when busy, wait current request for winner master to complete before switching rr_ptr
                else begin
                    case(active_valid)
                        4'b0001: begin
                            if(serv_req[0] == 0) begin // wait until winner (master0) finishes its request (serv_req goes low)
                                rr_ptr <= 1;    // move the rr_ptr to (winner_id + 1) % master_num
                                busy <= 0; // go back to idle state
                                req_granted <= 0; // clear request grant
                                active_valid <= 0; // clear active_valid to wait for next winner selection
                            end
                        end
                        4'b0010: begin
                            if(serv_req[1] == 0) begin
                                rr_ptr <= 2; busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                        4'b0100: begin
                            if(serv_req[2] == 0) begin
                                rr_ptr <= 3; busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                        4'b1000: begin
                            if(serv_req[3] == 0) begin
                                rr_ptr <= 0; busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                    endcase
                end
            end

            // process requests in weighted round robin manner
            2'd2: begin                    
                if(!busy) begin
                    if (!fifo_full && out_valid != 0) begin
                        active_valid <= out_valid;

                        case(out_valid) // update timestamp to when data goes out of arbiter
                            4'b0001: begin
                                data_out <= {data_in0[134:64], time_stamp}; out_txn_id <= data_in0[131:100]; 
                                req_granted <= 4'b0001; busy <= 1;
                            end
                            4'b0010: begin
                                data_out <= {data_in1[134:64], time_stamp}; out_txn_id <= data_in1[131:100]; 
                                req_granted <= 4'b0010; busy <= 1;
                            end
                            4'b0100: begin
                                data_out <= {data_in2[134:64], time_stamp}; out_txn_id <= data_in2[131:100]; 
                                req_granted <= 4'b0100; busy <= 1;
                            end
                            4'b1000: begin
                                data_out <= {data_in3[134:64], time_stamp}; out_txn_id <= data_in3[131:100]; 
                                req_granted <= 4'b1000; busy <= 1;
                            end
                        endcase
                    end
                end
                else begin
                    case(active_valid)
                        4'b0001: begin
                            if(serv_req[0] == 0) begin
                                quota_m0 <= (quota_m0 == 1)? weight_m0 : (quota_m0 -1); // decrease its quota if the master get served
                                rr_ptr <= (quota_m0 == 1)? 1 : rr_ptr; // move rr_ptr if this is the last quota, also reload quota, otherwise no change
                                busy <= 0; // go back to idle state
                                req_granted <= 0; // clear request grant
                                active_valid <= 0; // clear active_valid to wait for next winner selection
                            end
                        end
                        4'b0010: begin
                            if(serv_req[1] == 0) begin
                                quota_m1 <= (quota_m1 == 1)? weight_m1 : (quota_m1 -1); rr_ptr <= (quota_m1 == 1)? 2 : rr_ptr;
                                busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                        4'b0100: begin
                            if(serv_req[2] == 0) begin
                                quota_m2 <= (quota_m2 == 1)? weight_m2 : (quota_m2 -1); rr_ptr <= (quota_m2 == 1)? 3 : rr_ptr;
                                busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                        4'b1000: begin
                            if(serv_req[3] == 0) begin
                                quota_m3 <= (quota_m3 == 1)? weight_m3 : (quota_m3 -1); rr_ptr <= (quota_m3 == 1)? 0 : rr_ptr;
                                busy <= 0; req_granted <= 0; active_valid <= 0;
                            end
                        end
                    endcase
                end
            end
        endcase

        // ensure valid signal only pulsed high for 1 cycle when new latency is calculated
        arb_lat_valid <= 0;
        // check if new data has come, record the latency
        if (prev_txn_id != out_txn_id) begin
            prev_txn_id <= out_txn_id;
            arb_lat_valid <= winner; // they have the same one-hot information encoding, so can directly use winner to update both latency valid signal
            case (winner) // select by master (winner) to record latency
                4'b0001: ab_latency0 <= time_stamp - data_in0[63:0];
                4'b0010: ab_latency1 <= time_stamp - data_in1[63:0];
                4'b0100: ab_latency2 <= time_stamp - data_in2[63:0];
                4'b1000: ab_latency3 <= time_stamp - data_in3[63:0];
            endcase
        end
    end
end
endmodule


module traffic_gen #(
    parameter MASTER_ID = 0
)(
    output [134:0] data_packet,
    output reg serv_req,
    input [2:0] addr_gen_mode,
    input [15:0] lfsr_seed,
    input [15:0] addr_base,
    input [9:0] issue_gap,
    input req_granted, // controlled by arbiter, set to 0 initially
    input clk,
    input reset
);

reg [2:0] master_id;
reg [31:0] txn_id;
reg [15:0] addr;
reg write;
reg [18:0] wdata;
reg [63:0] issue_ts;

assign data_packet = {master_id, txn_id, addr, write, wdata, issue_ts};

wire [63:0] time_stamp;
wire [15:0] rand_addr;
reg [28:0] id_counter;
reg [9:0] gap_counter;
reg [2:0] state;

global_ctr ts (.time_stamp(time_stamp), .clk(clk), .reset(reset));

lfsr16 rand (.num(rand_addr), .seed(lfsr_seed), .clk(clk), .reset(reset));

always @(posedge clk) begin
    if (reset) begin
        master_id <= MASTER_ID;
        addr <= addr_base;
        write <= 0; // start from read mode
        serv_req <= 0;
        issue_ts <= 0;

        id_counter <= 29'd0;
        gap_counter <= 10'd0;
        state <= (issue_gap != 0)? 0 : 1;
    end
    else begin
        case (state)
            // inside the gap interval
            0 : begin
                gap_counter <= gap_counter + 1;
                state <= (gap_counter == issue_gap - 1)? 1 : 0;
            end
            // generate new data packet
            1 : begin
                txn_id <= {master_id, id_counter};
                case (addr_gen_mode)
                    0: addr <= addr + 1; // linear address generation
                    1: addr <= rand_addr; // random address generation
                    2: addr <= {2'b00, rand_addr[13:0]}; // hot spot address generation (all goes to bank 0)
                    // 2: begin // hot spot address generation
                    //     if(rand_addr[15:8] <= 8'd205) // 205/256 = 80.1%
                    //         addr <= {2'b00, rand_addr[13:0]}; // ~80% goes to bank 0 (0x0000 - 0x3ffff)
                    //     else
                    //         addr <= {2'b01, rand_addr[13:0]}; // ~20% goes to bank 1 (0x4000 - 0x7ffff)
                    // end
                    default: addr <= addr + 1; // default linear addr gen
                endcase
                write <= write ^ 1; // toggle between read and write request type!
                wdata <= {master_id, addr};
                issue_ts <= (time_stamp + 1); // +1 to account for the actual time when data is latched/posted into datapacket

                serv_req <= 1; // raise the service request
                id_counter <= id_counter + 1;
                gap_counter <= 0; // reset gap_counter
                state <= 2;
            end
            // wait for arbiter until service request is granted before starting new generation cycle
            2 : begin
                if(req_granted== 1) begin
                    serv_req <= 0; // serv_req will be high for 2 (fixed_p/rr) clk cycles when no generation delay
                    state <= (issue_gap != 0)? 0 : 1;
                end
            end
        endcase
    end
end
endmodule


// Pesudo random number generator via linear feedback shift register (Fibonacci), seed value can be any combination except 0!
module lfsr16 (
    output reg [15:0] num,
    input [15:0] seed,
    input clk,
    input reset
);

// tap positions 16, 14, 13, 11 are relative to the output bit, so if left shift, output bit is at LSB 
wire bit = num[15] ^ num[13] ^ num[12] ^ num[10];

always @(posedge clk) begin
    if(reset) begin
        num <= seed;
    end
    else begin
        num <= {num[14:0], bit};
    end
end
endmodule


module global_ctr (
    output reg [63:0] time_stamp,
    input clk,
    input reset
);

always @(posedge clk) begin
    if (reset)
        time_stamp <= 0;
    else
        time_stamp <= time_stamp + 1;
end
endmodule


module M10K ( 
    output reg signed [18:0] q,
    input signed [18:0] d,
    input [13:0] write_address, read_address,
    input we, clk
);

// force M10K ram style (32 * M10k blocks, 390 in total)
reg [18:0] mem [16383:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;

integer i;

// loop must terminate within 5000 iterations in quartus
// Initalize all memory values to be equal to their addresses
initial begin : init_memory
    for (i = 0; i < 4096; i = i + 1)
        mem[i] = i;

    for (i = 4096; i < 8192; i = i + 1)
        mem[i] = i;

    for (i = 8192; i < 12288; i = i + 1)
        mem[i] = i;

    for (i = 12288; i < 16384; i = i + 1)
        mem[i] = i;
end
    
always @ (posedge clk) begin
    if (we) begin
        mem[write_address] <= d;
    end
    q <= mem[read_address]; // q doesn't get d in this clock cycle
end
endmodule


// // fifo_latency dropped data rate calculation

// reg [31:0] data_ctr0, data_ctr1, data_ctr2, data_ctr3, drop_fifo_lat0, drop_fifo_lat1, drop_fifo_lat2, drop_fifo_lat3;
// // connected to pio ports
// reg [31:0] flat0_drop_pio, flat1_drop_pio, flat2_drop_pio, flat3_drop_pio; // number of dropped fifo latency data per 1024 data

// always @(posedge CLOCK_100) begin
//   if(reset) begin
// 		drop_fifo_lat0 <= 0;
// 		drop_fifo_lat1 <= 0;
// 		drop_fifo_lat2 <= 0;
// 		drop_fifo_lat3 <= 0;
//         data_ctr0 <= 0;
//         data_ctr1 <= 0;
//         data_ctr2 <= 0;
//         data_ctr3 <= 0;
//         flat0_drop_pio <= 0;
//         flat1_drop_pio <= 0;
//         flat2_drop_pio <= 0;
//         flat3_drop_pio <= 0;
//     end
//     else begin
//         if(m0_fifo_lat_valid) begin
//             if(!m0_flat_ready)
//                 drop_fifo_lat0 <= drop_fifo_lat0 + 1;

//             if(data_ctr0 < 64'd16384) // calculate the drop rate every 16384 (2^14) data to get average rate
//                 data_ctr0 <= data_ctr0 + 1;
//             else begin
//                 flat0_drop_pio <= (drop_fifo_lat0 >> 4);
//                 drop_fifo_lat0 <= 0; // reset dropped data counter and data counter for next round of calculation
//                 data_ctr0 <= 0;
//             end
//         end
//         if(m1_fifo_lat_valid) begin
//             if(!m1_flat_ready)
//                 drop_fifo_lat1 <= drop_fifo_lat1 + 1;

//             if(data_ctr1 < 64'd16384)
//                 data_ctr1 <= data_ctr1 + 1;
//             else begin
//                 flat1_drop_pio <= (drop_fifo_lat1 >> 4);
//                 drop_fifo_lat1 <= 0;
//                 data_ctr1 <= 0;
//             end
//         end
//         if(m2_fifo_lat_valid) begin
//             if(!m2_flat_ready)
//                 drop_fifo_lat2 <= drop_fifo_lat2 + 1;

//             if(data_ctr2 < 64'd16384)
//                 data_ctr2 <= data_ctr2 + 1;
//             else begin
//                 flat2_drop_pio <= (drop_fifo_lat2 >> 4);
//                 drop_fifo_lat2 <= 0;
//                 data_ctr2 <= 0;
//             end
//         end
//         if(m3_fifo_lat_valid) begin
//             if(!m3_flat_ready)
//                 drop_fifo_lat3 <= drop_fifo_lat3 + 1;

//             if(data_ctr3 < 64'd16384)
//                 data_ctr3 <= data_ctr3 + 1;
//             else begin
//                 flat3_drop_pio <= (drop_fifo_lat3 >> 4);
//                 drop_fifo_lat3 <= 0;
//                 data_ctr3 <= 0;
//             end
//         end
//     end
// end

// case (mem[rd_ptr][134:132]) // calculated fifo latency when dequeue, select by master_id
//     3'd0:
//         fifo_latency0 <= time_stamp - mem[rd_ptr][63:0]; // minimum latency 2: enqueue(1) + dequeue(1) 
//     3'd1:
//         fifo_latency1 <= time_stamp - mem[rd_ptr][63:0];
//     3'd2:
//         fifo_latency2 <= time_stamp - mem[rd_ptr][63:0];
//     3'd3:
//         fifo_latency3 <= time_stamp - mem[rd_ptr][63:0];
// endcase


// Non-piplined version for memory write handling (code haven't tested)

// case(state)
//     // Wait until fifo is not empty before reading it (1 cycle delay from fifo_rd_en goes high to data latched into data_in)
//     0: begin
//         we <= 0; // Reset we if it's pulled high in state 1
//         state <= (fifo_rd_en)? 1 : 0;
//     end
//     // Latch the data from fifo
//     1: begin
//         if (write == 1) begin // data will be in memory 2 cycles later
//             we <= write;
//             write_address <= (addr >> 2); // divide by 4 to accomodate memory capacity (16 bit to 14 bit address)
//             memory_write <= wdata;
//         end
//         else begin
//             read_address <= (addr >> 2); // memory_read will get the data 2 cycles later
//         end
//         state <= 0;
//     end
// endcase


// Original arbiter design with registered out_valid

// if(out_valid == 0) begin
//     if (serv_req[0]) out_valid <= 4'b0001;
//     else if (serv_req[1]) out_valid <= 4'b0010;
//     else if (serv_req[2]) out_valid <= 4'b0100;
//     else if (serv_req[3]) out_valid <= 4'b1000;
//     else out_valid <= 0;
// end

// case(out_valid) 
//     4'b0001: begin
//         data_out <= {data_in0[134:64], time_stamp};
//         out_txn_id <= data_in0[131:100];
//         req_granted <= 4'b0001; // grant request to master 0, set other masters' req_granted to 0
//         if(serv_req[0] == 0) begin
//             out_valid <= 0; // reset winner
//             req_granted <= 0; // clear request grant
//         end
//     end
//     4'b0010: begin
//         data_out <= {data_in1[134:64], time_stamp};
//         out_txn_id <= data_in1[131:100];
//         req_granted <= 4'b0010;
//         if(serv_req[1] == 0) begin
//             out_valid <= 0;
//             req_granted <= 0;
//         end
//     end
//     4'b0100: begin
//         data_out <= {data_in2[134:64], time_stamp};
//         out_txn_id <= data_in2[131:100];
//         req_granted <= 4'b0100;
//         if(serv_req[2] == 0) begin
//             out_valid <= 0;
//             req_granted <= 0;
//         end
//     end
//     4'b1000: begin
//         data_out <= {data_in3[134:64], time_stamp};
//         out_txn_id <= data_in3[131:100];
//         req_granted <= 4'b1000;
//         if(serv_req[3] == 0) begin
//             out_valid <= 0;
//             req_granted <= 0;
//         end
//     end
// endcase


// Original fixed_prority design

// if (serv_req[0]) begin
//     data_out <= {data_in0[134:64], time_stamp};
//     out_txn_id <= data_in0[131:100];
//     req_granted <= 4'b0001; // grant request to master 0, set other masters' req_granted to 0
// end
// else if (serv_req[1]) begin
//     data_out <= {data_in1[134:64], time_stamp};
//     out_txn_id <= data_in1[131:100];
//     req_granted <= 4'b0010;
// end
// else if (serv_req[2]) begin
//     data_out <= {data_in2[134:64], time_stamp};
//     out_txn_id <= data_in2[131:100];
//     req_granted <= 4'b0100;
// end
// else if (serv_req[3]) begin
//     data_out <= {data_in3[134:64], time_stamp};
//     out_txn_id <= data_in3[131:100];
//     req_granted <= 4'b1000;
// end
// else begin
//     req_granted <= 0;
// end


// Original RR design

// case(rr_ptr)
//     3'd1 : begin
//         if (serv_req[1]) begin
//             data_out <= {data_in1[134:64], time_stamp}; out_txn_id <= data_in1[131:100]; req_granted <= 2'b10;
//         end
//         else if (serv_req[0]) begin
//             data_out <= {data_in0[134:64], time_stamp}; out_txn_id <= data_in0[131:100]; req_granted <= 2'b01; 
//         end
//         else begin
//             req_granted <= 2'b00;
//         end
//         rr_ptr <= 3'd0;
//     end
// endcase