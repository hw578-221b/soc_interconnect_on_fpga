module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,
	CLOCK4_50,

	// ADC
	ADC_CS_N,
	ADC_DIN,
	ADC_DOUT,
	ADC_SCLK,

	// Audio
	AUD_ADCDAT,
	AUD_ADCLRCK,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,

	// SDRAM
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	FPGA_I2C_SCLK,
	FPGA_I2C_SDAT,

	// 40-Pin Headers
	GPIO_0,
	GPIO_1,
	
	// Seven Segment Displays
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,

	// IR
	IRDA_RXD,
	IRDA_TXD,

	// Pushbuttons
	KEY,

	// LEDs
	LEDR,

	// PS2 Ports
	PS2_CLK,
	PS2_DAT,
	
	PS2_CLK2,
	PS2_DAT2,

	// Slider Switches
	SW,

	// Video-In
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_RESET_N,
	TD_VS,

	// VGA
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 
	HPS_DDR3_ADDR,
	HPS_DDR3_BA,
	HPS_DDR3_CAS_N,
	HPS_DDR3_CKE,
	HPS_DDR3_CK_N,
	HPS_DDR3_CK_P,
	HPS_DDR3_CS_N,
	HPS_DDR3_DM,
	HPS_DDR3_DQ,
	HPS_DDR3_DQS_N,
	HPS_DDR3_DQS_P,
	HPS_DDR3_ODT,
	HPS_DDR3_RAS_N,
	HPS_DDR3_RESET_N,
	HPS_DDR3_RZQ,
	HPS_DDR3_WE_N,

	// Ethernet
	HPS_ENET_GTX_CLK,
	HPS_ENET_INT_N,
	HPS_ENET_MDC,
	HPS_ENET_MDIO,
	HPS_ENET_RX_CLK,
	HPS_ENET_RX_DATA,
	HPS_ENET_RX_DV,
	HPS_ENET_TX_DATA,
	HPS_ENET_TX_EN,

	// Flash
	HPS_FLASH_DATA,
	HPS_FLASH_DCLK,
	HPS_FLASH_NCSO,

	// Accelerometer
	HPS_GSENSOR_INT,
		
	// General Purpose I/O
	HPS_GPIO,
		
	// I2C
	HPS_I2C_CONTROL,
	HPS_I2C1_SCLK,
	HPS_I2C1_SDAT,
	HPS_I2C2_SCLK,
	HPS_I2C2_SDAT,

	// Pushbutton
	HPS_KEY,

	// LED
	HPS_LED,
		
	// SD Card
	HPS_SD_CLK,
	HPS_SD_CMD,
	HPS_SD_DATA,

	// SPI
	HPS_SPIM_CLK,
	HPS_SPIM_MISO,
	HPS_SPIM_MOSI,
	HPS_SPIM_SS,

	// UART
	HPS_UART_RX,
	HPS_UART_TX,

	// USB
	HPS_CONV_USB_N,
	HPS_USB_CLKOUT,
	HPS_USB_DATA,
	HPS_USB_DIR,
	HPS_USB_NXT,
	HPS_USB_STP
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

////////////////////////////////////
// FPGA Pins
////////////////////////////////////

// Clock pins
input						CLOCK_50;
input						CLOCK2_50;
input						CLOCK3_50;
input						CLOCK4_50;

// ADC
inout						ADC_CS_N;
output					ADC_DIN;
input						ADC_DOUT;
output					ADC_SCLK;

// Audio
input						AUD_ADCDAT;
inout						AUD_ADCLRCK;
inout						AUD_BCLK;
output					AUD_DACDAT;
inout						AUD_DACLRCK;
output					AUD_XCK;

// SDRAM
output 		[12: 0]	DRAM_ADDR;
output		[ 1: 0]	DRAM_BA;
output					DRAM_CAS_N;
output					DRAM_CKE;
output					DRAM_CLK;
output					DRAM_CS_N;
inout			[15: 0]	DRAM_DQ;
output					DRAM_LDQM;
output					DRAM_RAS_N;
output					DRAM_UDQM;
output					DRAM_WE_N;

// I2C Bus for Configuration of the Audio and Video-In Chips
output					FPGA_I2C_SCLK;
inout						FPGA_I2C_SDAT;

// 40-pin headers
inout			[35: 0]	GPIO_0;
inout			[35: 0]	GPIO_1;

// Seven Segment Displays
output		[ 6: 0]	HEX0;
output		[ 6: 0]	HEX1;
output		[ 6: 0]	HEX2;
output		[ 6: 0]	HEX3;
output		[ 6: 0]	HEX4;
output		[ 6: 0]	HEX5;

// IR
input						IRDA_RXD;
output					IRDA_TXD;

// Pushbuttons
input			[ 3: 0]	KEY;

// LEDs
output		[ 9: 0]	LEDR;

// PS2 Ports
inout						PS2_CLK;
inout						PS2_DAT;

inout						PS2_CLK2;
inout						PS2_DAT2;

// Slider Switches
input			[ 9: 0]	SW;

// Video-In
input						TD_CLK27;
input			[ 7: 0]	TD_DATA;
input						TD_HS;
output					TD_RESET_N;
input						TD_VS;

// VGA
output		[ 7: 0]	VGA_B;
output					VGA_BLANK_N;
output					VGA_CLK;
output		[ 7: 0]	VGA_G;
output					VGA_HS;
output		[ 7: 0]	VGA_R;
output					VGA_SYNC_N;
output					VGA_VS;



////////////////////////////////////
// HPS Pins
////////////////////////////////////
	
// DDR3 SDRAM
output		[14: 0]	HPS_DDR3_ADDR;
output		[ 2: 0]  HPS_DDR3_BA;
output					HPS_DDR3_CAS_N;
output					HPS_DDR3_CKE;
output					HPS_DDR3_CK_N;
output					HPS_DDR3_CK_P;
output					HPS_DDR3_CS_N;
output		[ 3: 0]	HPS_DDR3_DM;
inout			[31: 0]	HPS_DDR3_DQ;
inout			[ 3: 0]	HPS_DDR3_DQS_N;
inout			[ 3: 0]	HPS_DDR3_DQS_P;
output					HPS_DDR3_ODT;
output					HPS_DDR3_RAS_N;
output					HPS_DDR3_RESET_N;
input						HPS_DDR3_RZQ;
output					HPS_DDR3_WE_N;

// Ethernet
output					HPS_ENET_GTX_CLK;
inout						HPS_ENET_INT_N;
output					HPS_ENET_MDC;
inout						HPS_ENET_MDIO;
input						HPS_ENET_RX_CLK;
input			[ 3: 0]	HPS_ENET_RX_DATA;
input						HPS_ENET_RX_DV;
output		[ 3: 0]	HPS_ENET_TX_DATA;
output					HPS_ENET_TX_EN;

// Flash
inout			[ 3: 0]	HPS_FLASH_DATA;
output					HPS_FLASH_DCLK;
output					HPS_FLASH_NCSO;

// Accelerometer
inout						HPS_GSENSOR_INT;

// General Purpose I/O
inout			[ 1: 0]	HPS_GPIO;

// I2C
inout						HPS_I2C_CONTROL;
inout						HPS_I2C1_SCLK;
inout						HPS_I2C1_SDAT;
inout						HPS_I2C2_SCLK;
inout						HPS_I2C2_SDAT;

// Pushbutton
inout						HPS_KEY;

// LED
inout						HPS_LED;

// SD Card
output					HPS_SD_CLK;
inout						HPS_SD_CMD;
inout			[ 3: 0]	HPS_SD_DATA;

// SPI
output					HPS_SPIM_CLK;
input						HPS_SPIM_MISO;
output					HPS_SPIM_MOSI;
inout						HPS_SPIM_SS;

// UART
input						HPS_UART_RX;
output					HPS_UART_TX;

// USB
inout						HPS_CONV_USB_N;
input						HPS_USB_CLKOUT;
inout			[ 7: 0]	HPS_USB_DATA;
input						HPS_USB_DIR;
input						HPS_USB_NXT;
output					HPS_USB_STP;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire reset_pio, pll_locked;
// hold in reset when pll hasn't been locked
wire reset = (~KEY[0]) || reset_pio || (~pll_locked);

reg pipeline_design; // for M10K memory wrapped target, 0: non-pipelined, 1: pipelined
// target delay cycles under non-piplined mode, (3/5 + delay) cycles per write/read
// For fixed priority and (weighted) rr arbitration, max data output speed to fifo is fixed at 3 cycle/packet (1 for serv_req to drop, 1 for busy to drop, 1 for new req_grant to raise)
reg [9:0] mem_delay_cy;  // applies to non-pipelined design
// mixed read and write requests

// If the masters are not continuously backlogged, then WRR will not necessarily produce the exact configured 4:3:2:1 issue ratio. A ratio like ~2:2:1:1 can absolutely happen
// Set all issue gap to 0 when testing WRR
reg [1:0] arb_mode; // 0: fixed priority  1: round robin 2: weighted round robin
reg [2:0] address_gen_mode; // 0: linear address generation, 1: pseudo random address generation, 2: hot spot address generation
// actual generation period when no delay should be issue_gap + 3, considering the delay of arbitration and state transition
reg [9:0] issue_gap0;
reg [9:0] issue_gap1;
reg [9:0] issue_gap2;
reg [9:0] issue_gap3;

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

// watch for the combinational path from serv_req->out_valid->winner->addr->fifo_full when synthesizing into FGPA !!!
// ab_latency = gen_latency + 1(fixed_p & rr mode) (fixed latency due to arbiter design)
// minimum latency 1 when no waiting (from latching data_out)
wire [63:0] ab_latency0, ab_latency1, ab_latency2, ab_latency3;
wire [3:0] arb_lat_valid;

// each master has its own fifo for recording fifo latency in qsys (4 in total), each of the fifo latency could come from 4 target sources
wire latency_valid0, latency_valid1, latency_valid2, latency_valid3;
wire [53:0] mem_out_dpacket0, mem_out_dpacket1, mem_out_dpacket2, mem_out_dpacket3;
wire [63:0] fifo_latency0, fifo_latency1, fifo_latency2, fifo_latency3;
reg [63:0] total_latency; // latency from the data generation to it goes inside target memory; From dequeue (when fifo_latency calculated) to data enters memory has a fixed latency of 3 cycles

wire [2:0] capacity0, capacity1, capacity2, capacity3;
wire fifo_full0, fifo_full1, fifo_full2, fifo_full3, fifo_empty0, fifo_empty1, fifo_empty2, fifo_empty3;
wire fifo_wr_en;
reg fifo_wr_en0, fifo_wr_en1, fifo_wr_en2, fifo_wr_en3;
wire [134:0] dpacket_fifo_in, dpacket_fifo_out0, dpacket_fifo_out1, dpacket_fifo_out2, dpacket_fifo_out3;
wire fifo_rd_en0, fifo_rd_en1, fifo_rd_en2, fifo_rd_en3;
wire [2:0] out_master_id0, out_master_id1, out_master_id2, out_master_id3;

wire data_requested; // hps request a latency statistics read by pulling this signal high

assign out_master_id0 = dpacket_fifo_out0[134:132];
assign out_master_id1 = dpacket_fifo_out1[134:132];
assign out_master_id2 = dpacket_fifo_out2[134:132];
assign out_master_id3 = dpacket_fifo_out3[134:132];

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
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_50), .reset(reset));

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
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_50), .reset(reset));

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
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_50), .reset(reset));

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
    .fifo_latency1(fifo_latency1), .fifo_latency2(fifo_latency2), .fifo_latency3(fifo_latency3), .clk(CLOCK_50), .reset(reset));


// Statistical & fifo interface of master0's arb_latency
wire [31:0] m0_ab_lat_sum_high, m0_ab_lat_sum_low, m0_ab_lat_count_high, m0_ab_lat_count_low, m0_ab_min_latency, m0_ab_max_latency;
wire m0_ab_sum_overflow_flag;

arb_latency_stat m0_ab_stat (.lat_sum_high(m0_ab_lat_sum_high), .lat_sum_low(m0_ab_lat_sum_low), .lat_count_high(m0_ab_lat_count_high), .lat_count_low(m0_ab_lat_count_low),
    .min_latency(m0_ab_min_latency), .max_latency(m0_ab_max_latency), .sum_overflow_flag(m0_ab_sum_overflow_flag), .ab_latency(ab_latency0), .ab_lat_valid(arb_lat_valid[0]),
    .data_requested(data_requested), .clk(CLOCK_50), .reset(reset));

// Statistical & fifo interface of master1's arb_latency
wire [31:0] m1_ab_lat_sum_high, m1_ab_lat_sum_low, m1_ab_lat_count_high, m1_ab_lat_count_low, m1_ab_min_latency, m1_ab_max_latency;
wire m1_ab_sum_overflow_flag;

arb_latency_stat m1_ab_stat (.lat_sum_high(m1_ab_lat_sum_high), .lat_sum_low(m1_ab_lat_sum_low), .lat_count_high(m1_ab_lat_count_high), .lat_count_low(m1_ab_lat_count_low),
    .min_latency(m1_ab_min_latency), .max_latency(m1_ab_max_latency), .sum_overflow_flag(m1_ab_sum_overflow_flag), .ab_latency(ab_latency1), .ab_lat_valid(arb_lat_valid[1]),
    .data_requested(data_requested), .clk(CLOCK_50), .reset(reset));

// Statistical & fifo interface of master2's arb_latency
wire [31:0] m2_ab_lat_sum_high, m2_ab_lat_sum_low, m2_ab_lat_count_high, m2_ab_lat_count_low, m2_ab_min_latency, m2_ab_max_latency;
wire m2_ab_sum_overflow_flag;

arb_latency_stat m2_ab_stat (.lat_sum_high(m2_ab_lat_sum_high), .lat_sum_low(m2_ab_lat_sum_low), .lat_count_high(m2_ab_lat_count_high), .lat_count_low(m2_ab_lat_count_low),
    .min_latency(m2_ab_min_latency), .max_latency(m2_ab_max_latency), .sum_overflow_flag(m2_ab_sum_overflow_flag), .ab_latency(ab_latency2), .ab_lat_valid(arb_lat_valid[2]),
    .data_requested(data_requested), .clk(CLOCK_50), .reset(reset));

// Statistical & fifo interface of master3's arb_latency
wire [31:0] m3_ab_lat_sum_high, m3_ab_lat_sum_low, m3_ab_lat_count_high, m3_ab_lat_count_low, m3_ab_min_latency, m3_ab_max_latency;
wire m3_ab_sum_overflow_flag;

arb_latency_stat m3_ab_stat (.lat_sum_high(m3_ab_lat_sum_high), .lat_sum_low(m3_ab_lat_sum_low), .lat_count_high(m3_ab_lat_count_high), .lat_count_low(m3_ab_lat_count_low),
    .min_latency(m3_ab_min_latency), .max_latency(m3_ab_max_latency), .sum_overflow_flag(m3_ab_sum_overflow_flag), .ab_latency(ab_latency3), .ab_lat_valid(arb_lat_valid[3]),
    .data_requested(data_requested), .clk(CLOCK_50), .reset(reset));


// Module instantiation

// Memory bank 0
memory_bank_target target0 (.fifo_rd_en(fifo_rd_en0), .out_dpacket(mem_out_dpacket0), .out_valid(latency_valid0), .fifo_latency(fifo_latency0),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out0), .fifo_empty(fifo_empty0), .clk(CLOCK_50), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo0 (.dpacket_out(dpacket_fifo_out0), .capacity(capacity0),
    .full(fifo_full0), .empty(fifo_empty0), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en0), .rd_en(fifo_rd_en0), .clk(CLOCK_50), .reset(reset));

// Memory bank 1
memory_bank_target target1 (.fifo_rd_en(fifo_rd_en1), .out_dpacket(mem_out_dpacket1), .out_valid(latency_valid1), .fifo_latency(fifo_latency1),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out1), .fifo_empty(fifo_empty1), .clk(CLOCK_50), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo1 (.dpacket_out(dpacket_fifo_out1), .capacity(capacity1),
    .full(fifo_full1), .empty(fifo_empty1), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en1), .rd_en(fifo_rd_en1), .clk(CLOCK_50), .reset(reset));

// Memory bank 2
memory_bank_target target2 (.fifo_rd_en(fifo_rd_en2), .out_dpacket(mem_out_dpacket2), .out_valid(latency_valid2), .fifo_latency(fifo_latency2),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out2), .fifo_empty(fifo_empty2), .clk(CLOCK_50), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo2 (.dpacket_out(dpacket_fifo_out2), .capacity(capacity2),
    .full(fifo_full2), .empty(fifo_empty2), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en2), .rd_en(fifo_rd_en2), .clk(CLOCK_50), .reset(reset));

// Memory bank 3
memory_bank_target target3 (.fifo_rd_en(fifo_rd_en3), .out_dpacket(mem_out_dpacket3), .out_valid(latency_valid3), .fifo_latency(fifo_latency3),
        .pipelined(pipeline_design), .delay_cycles(mem_delay_cy), .data_in(dpacket_fifo_out3), .fifo_empty(fifo_empty3), .clk(CLOCK_50), .reset(reset));

sync_ring_fifo #(.WIDTH(135), .DEPTH(8), .ADDRESS_W(3))
fifo3 (.dpacket_out(dpacket_fifo_out3), .capacity(capacity3),
    .full(fifo_full3), .empty(fifo_empty3), .dpacket_in(dpacket_fifo_in), .wr_en(fifo_wr_en3), .rd_en(fifo_rd_en3), .clk(CLOCK_50), .reset(reset));

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
always @(posedge CLOCK_50) begin
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
        .serv_req(serv_req), .clk(CLOCK_50), .reset(reset));

traffic_gen #(.MASTER_ID(0))
traffic0 (.data_packet(data_packet[0]), .serv_req(serv_req[0]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master0_seed),
        .addr_base(addr_base0), .issue_gap(issue_gap0), .req_granted(req_granted[0]), .clk(CLOCK_50), .reset(reset));

traffic_gen #(.MASTER_ID(1))
traffic1 (.data_packet(data_packet[1]), .serv_req(serv_req[1]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master1_seed),
        .addr_base(addr_base1), .issue_gap(issue_gap1), .req_granted(req_granted[1]), .clk(CLOCK_50), .reset(reset));

traffic_gen #(.MASTER_ID(2))
traffic2 (.data_packet(data_packet[2]), .serv_req(serv_req[2]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master2_seed),
        .addr_base(addr_base2), .issue_gap(issue_gap2), .req_granted(req_granted[2]), .clk(CLOCK_50), .reset(reset));

traffic_gen #(.MASTER_ID(3))
traffic3 (.data_packet(data_packet[3]), .serv_req(serv_req[3]), .addr_gen_mode(address_gen_mode), .lfsr_seed(master3_seed),
        .addr_base(addr_base3), .issue_gap(issue_gap3), .req_granted(req_granted[3]), .clk(CLOCK_50), .reset(reset));


//=======================================================
//  Structural coding
//=======================================================

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),

	// VGA Subsystem
	.vga_pll_ref_clk_clk 					(CLOCK2_50),
	.vga_pll_ref_reset_reset				(1'b0),
	.vga_CLK										(VGA_CLK),
	.vga_BLANK									(VGA_BLANK_N),
	.vga_SYNC									(VGA_SYNC_N),
	.vga_HS										(VGA_HS),
	.vga_VS										(VGA_VS),
	.vga_R										(VGA_R),
	.vga_G										(VGA_G),
	.vga_B										(VGA_B),
	
	// **Custom components**
	.pll_50mhz_locked_export						(pll_locked),
	.reset_controller_100mhz_reset_in1_reset	(reset),
	.reset_controller_50mhz_reset_in1_reset	(reset),
	
	// **Custom PIO connection**
	.reset_pio_external_connection_export      			(reset_pio),
	.arb_mode_pio_external_connection_export   			(arb_mode),
	.addr_gen_mode_pio_external_connection_export 		(address_gen_mode),
	.mem_delay_cycle_pio_external_connection_export 	(mem_delay_cy),
	.pipeline_design_pio_external_connection_export 	(pipeline_design),
	.m0_issue_gap_pio_external_connection_export 		(issue_gap0),
	.m1_issue_gap_pio_external_connection_export 		(issue_gap1),
	.m2_issue_gap_pio_external_connection_export 		(issue_gap2),
	.m3_issue_gap_pio_external_connection_export 		(issue_gap3),
	
	.m0_service_count_pio_external_connection_export 	(m0_issue_ctr),
	.m1_service_count_pio_external_connection_export 	(m1_issue_ctr),
	.m2_service_count_pio_external_connection_export 	(m2_issue_ctr),
	.m3_service_count_pio_external_connection_export 	(m3_issue_ctr),
	
	.data_requested_pio_external_connection_export     (data_requested),
	
	.m0_fifo_lat_sum_high_external_connection_export   (m0_fifo_lat_sum_high),
	.m0_fifo_lat_sum_low_external_connection_export    (m0_fifo_lat_sum_low),
	.m0_fifo_lat_count_high_external_connection_export (m0_fifo_lat_count_high),
	.m0_fifo_lat_count_low_external_connection_export  (m0_fifo_lat_count_low),
	.m0_min_lat_external_connection_export             (m0_min_fifo_lat),
	.m0_max_lat_external_connection_export             (m0_max_fifo_lat),
	.m0_fifo_lat_sum_ovrflw_external_connection_export (m0_sum_overflow_flag),
	.m0_arb_lat_sum_high_external_connection_export    (m0_ab_lat_sum_high),
	.m0_arb_lat_sum_low_external_connection_export     (m0_ab_lat_sum_low),
	.m0_arb_lat_count_high_external_connection_export  (m0_ab_lat_count_high),
	.m0_arb_lat_count_low_external_connection_export   (m0_ab_lat_count_low),
	.m0_min_lat_arb_external_connection_export         (m0_ab_min_latency),
	.m0_max_lat_arb_external_connection_export         (m0_ab_max_latency),
	.m0_arb_lat_sum_ovrflw_external_connection_export  (m0_ab_sum_overflow_flag),

	.m1_fifo_lat_sum_high_external_connection_export   (m1_fifo_lat_sum_high),
	.m1_fifo_lat_sum_low_external_connection_export    (m1_fifo_lat_sum_low),
	.m1_fifo_lat_count_high_external_connection_export (m1_fifo_lat_count_high),
	.m1_fifo_lat_count_low_external_connection_export  (m1_fifo_lat_count_low),
	.m1_min_lat_external_connection_export             (m1_min_fifo_lat),
	.m1_max_lat_external_connection_export             (m1_max_fifo_lat),
	.m1_fifo_lat_sum_ovrflw_external_connection_export (m1_sum_overflow_flag),
	.m1_arb_lat_sum_high_external_connection_export    (m1_ab_lat_sum_high),
	.m1_arb_lat_sum_low_external_connection_export     (m1_ab_lat_sum_low),
	.m1_arb_lat_count_high_external_connection_export  (m1_ab_lat_count_high),
	.m1_arb_lat_count_low_external_connection_export   (m1_ab_lat_count_low),
	.m1_min_lat_arb_external_connection_export         (m1_ab_min_latency),
	.m1_max_lat_arb_external_connection_export         (m1_ab_max_latency),
	.m1_arb_lat_sum_ovrflw_external_connection_export  (m1_ab_sum_overflow_flag),

	.m2_fifo_lat_sum_high_external_connection_export   (m2_fifo_lat_sum_high),
	.m2_fifo_lat_sum_low_external_connection_export    (m2_fifo_lat_sum_low),
	.m2_fifo_lat_count_high_external_connection_export (m2_fifo_lat_count_high),
	.m2_fifo_lat_count_low_external_connection_export  (m2_fifo_lat_count_low),
	.m2_min_lat_external_connection_export             (m2_min_fifo_lat),
	.m2_max_lat_external_connection_export             (m2_max_fifo_lat),
	.m2_fifo_lat_sum_ovrflw_external_connection_export (m2_sum_overflow_flag),
	.m2_arb_lat_sum_high_external_connection_export    (m2_ab_lat_sum_high),
	.m2_arb_lat_sum_low_external_connection_export     (m2_ab_lat_sum_low),
	.m2_arb_lat_count_high_external_connection_export  (m2_ab_lat_count_high),
	.m2_arb_lat_count_low_external_connection_export   (m2_ab_lat_count_low),
	.m2_min_lat_arb_external_connection_export         (m2_ab_min_latency),
	.m2_max_lat_arb_external_connection_export         (m2_ab_max_latency),
	.m2_arb_lat_sum_ovrflw_external_connection_export  (m2_ab_sum_overflow_flag),

	.m3_fifo_lat_sum_high_external_connection_export   (m3_fifo_lat_sum_high),
	.m3_fifo_lat_sum_low_external_connection_export    (m3_fifo_lat_sum_low),
	.m3_fifo_lat_count_high_external_connection_export (m3_fifo_lat_count_high),
	.m3_fifo_lat_count_low_external_connection_export  (m3_fifo_lat_count_low),
	.m3_min_lat_external_connection_export             (m3_min_fifo_lat),
	.m3_max_lat_external_connection_export             (m3_max_fifo_lat),
	.m3_fifo_lat_sum_ovrflw_external_connection_export (m3_sum_overflow_flag),
	.m3_arb_lat_sum_high_external_connection_export    (m3_ab_lat_sum_high),
	.m3_arb_lat_sum_low_external_connection_export     (m3_ab_lat_sum_low),
	.m3_arb_lat_count_high_external_connection_export  (m3_ab_lat_count_high),
	.m3_arb_lat_count_low_external_connection_export   (m3_ab_lat_count_low),
	.m3_min_lat_arb_external_connection_export         (m3_ab_min_latency),
	.m3_max_lat_arb_external_connection_export         (m3_ab_max_latency),
	.m3_arb_lat_sum_ovrflw_external_connection_export  (m3_ab_sum_overflow_flag),
	
	// **Custom FIFO memory IP**
	.fifo_flat0_in_valid						(m0_fifo_lat_valid),
	.fifo_flat0_in_data						(m0_fifo_lat_data),
	.fifo_flat1_in_valid						(m1_fifo_lat_valid),
	.fifo_flat1_in_data						(m1_fifo_lat_data),
	.fifo_flat2_in_valid						(m2_fifo_lat_valid),
	.fifo_flat2_in_data						(m2_fifo_lat_data),
	.fifo_flat3_in_valid						(m3_fifo_lat_valid),
	.fifo_flat3_in_data						(m3_fifo_lat_data),
	
	.fifo_ablat0_in_valid					(arb_lat_valid[0]),
	.fifo_ablat0_in_data						(ab_latency0[31:0]),
	.fifo_ablat1_in_valid					(arb_lat_valid[1]),
	.fifo_ablat1_in_data						(ab_latency1[31:0]),
	.fifo_ablat2_in_valid					(arb_lat_valid[2]),
	.fifo_ablat2_in_data						(ab_latency2[31:0]),
	.fifo_ablat3_in_valid					(arb_lat_valid[3]),
	.fifo_ablat3_in_data						(ab_latency3[31:0]),
	
	// SDRAM
	.sdram_clk_clk								(DRAM_CLK),
   .sdram_addr									(DRAM_ADDR),
	.sdram_ba									(DRAM_BA),
	.sdram_cas_n								(DRAM_CAS_N),
	.sdram_cke									(DRAM_CKE),
	.sdram_cs_n									(DRAM_CS_N),
	.sdram_dq									(DRAM_DQ),
	.sdram_dqm									({DRAM_UDQM,DRAM_LDQM}),
	.sdram_ras_n								(DRAM_RAS_N),
	.sdram_we_n									(DRAM_WE_N),
	
	////////////////////////////////////
	// HPS Side
	////////////////////////////////////
	// DDR3 SDRAM
	.memory_mem_a			(HPS_DDR3_ADDR),
	.memory_mem_ba			(HPS_DDR3_BA),
	.memory_mem_ck			(HPS_DDR3_CK_P),
	.memory_mem_ck_n		(HPS_DDR3_CK_N),
	.memory_mem_cke		(HPS_DDR3_CKE),
	.memory_mem_cs_n		(HPS_DDR3_CS_N),
	.memory_mem_ras_n		(HPS_DDR3_RAS_N),
	.memory_mem_cas_n		(HPS_DDR3_CAS_N),
	.memory_mem_we_n		(HPS_DDR3_WE_N),
	.memory_mem_reset_n	(HPS_DDR3_RESET_N),
	.memory_mem_dq			(HPS_DDR3_DQ),
	.memory_mem_dqs		(HPS_DDR3_DQS_P),
	.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
	.memory_mem_odt		(HPS_DDR3_ODT),
	.memory_mem_dm			(HPS_DDR3_DM),
	.memory_oct_rzqin		(HPS_DDR3_RZQ),
		  
	// Ethernet
	.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
	.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
	.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
	.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
	.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
	.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
	.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
	.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
	.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
	.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
	.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
	.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
	.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),

	// Flash
	.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
	.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
	.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
	.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
	.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
	.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),

	// Accelerometer
	.hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),

	//.adc_sclk                        (ADC_SCLK),
	//.adc_cs_n                        (ADC_CS_N),
	//.adc_dout                        (ADC_DOUT),
	//.adc_din                         (ADC_DIN),

	// General Purpose I/O
	.hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
	.hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),

	// I2C
	.hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
	.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
	.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
	.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
	.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

	// Pushbutton
	.hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),

	// LED
	.hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),

	// SD Card
	.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
	.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
	.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),

	// SPI
	.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
	.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
	.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
	.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

	// UART
	.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
	.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),

	// USB
	.hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
	.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
	.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
	.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
	.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
	.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
	.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
	.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
	.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
	.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
	.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
	.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
	.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT)
);


endmodule


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
    output reg [63:0] fifo_latency,   // time wait in the fifo for request from master0 before entering target
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