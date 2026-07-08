///////////////////////////////////////
/// compile with gcc -Wall -Wextra final_project_v4.c vga_graphics.c -o control -lm -pthread -lrt
///////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <pthread.h>
#include <sched.h>
#include <semaphore.h>

#include "vga_graphics.h"

#define NSEC_PER_MSEC 		  1000000
#define NSEC_PER_SEC		  1000000000

// video display
#define SDRAM_BASE            0xC0000000   // Axi bus base
#define SDRAM_END             0xC3FFFFFF
#define SDRAM_SPAN			  0x04000000
// characters
#define FPGA_CHAR_BASE        0xC9000000
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000
// Cyclone V FPGA devices & PIO ports
#define HW_REGS_BASE          0xff200000   // lw-Axi bus base
#define HW_REGS_SPAN          0x00005000
// fifo memory for latency data
#define FIFO_BASE			  0xC4000000
#define FIFO_SPAN			  0x00001000
// fifo latency data
#define M0_FLAT_DATA		  0x0000
#define M1_FLAT_DATA	      0x0040
#define M2_FLAT_DATA	      0x0080
#define M3_FLAT_DATA	      0x00c0
// arbitration latency data
#define M0_ABLAT_DATA		  0x0100
#define M1_ABLAT_DATA	      0x0140
#define M2_ABLAT_DATA	      0x0180
#define M3_ABLAT_DATA	      0x01c0
// pio ports
#define RESET_PIO 			  0x3040
#define ARB_MODE_PIO 		  0x3090
#define ADDR_GEN_MODE_PIO     0x30a0
#define MEM_DELAY_CYCLE_PIO	  0x30b0
#define PIPELINE_DESIGN_PIO   0x30c0
#define DATA_REQUEST_PIO      0x34e0
#define M0_ISSUE_GAP_PIO      0x30d0
#define M1_ISSUE_GAP_PIO      0x30e0
#define M2_ISSUE_GAP_PIO      0x3100
#define M3_ISSUE_GAP_PIO      0x3110
#define M0_SERV_COUNT_PIO     0x3120
#define M1_SERV_COUNT_PIO     0x3130
#define M2_SERV_COUNT_PIO     0x3140
#define M3_SERV_COUNT_PIO     0x3150

#define M0_FIFO_LAT_SUM_HIGH    0x3160
#define M0_FIFO_LAT_SUM_LOW     0x3170
#define M0_FIFO_LAT_COUNT_HIGH  0x3180
#define M0_FIFO_LAT_COUNT_LOW   0x3190
#define M0_FIFO_LAT_MIN         0x31a0
#define M0_FIFO_LAT_MAX         0x31b0
#define M0_FIFO_LAT_SUM_OVRFLW  0x31c0
#define M1_FIFO_LAT_SUM_HIGH    0x31d0
#define M1_FIFO_LAT_SUM_LOW     0x31e0
#define M1_FIFO_LAT_COUNT_HIGH  0x31f0
#define M1_FIFO_LAT_COUNT_LOW   0x3200
#define M1_FIFO_LAT_MIN         0x3210
#define M1_FIFO_LAT_MAX         0x3220
#define M1_FIFO_LAT_SUM_OVRFLW  0x3230
#define M2_FIFO_LAT_SUM_HIGH    0x3240
#define M2_FIFO_LAT_SUM_LOW     0x3250
#define M2_FIFO_LAT_COUNT_HIGH  0x3260
#define M2_FIFO_LAT_COUNT_LOW   0x3270
#define M2_FIFO_LAT_MIN         0x3280
#define M2_FIFO_LAT_MAX         0x3290
#define M2_FIFO_LAT_SUM_OVRFLW  0x32a0
#define M3_FIFO_LAT_SUM_HIGH    0x32b0
#define M3_FIFO_LAT_SUM_LOW     0x32c0
#define M3_FIFO_LAT_COUNT_HIGH  0x32d0
#define M3_FIFO_LAT_COUNT_LOW   0x32e0
#define M3_FIFO_LAT_MIN         0x32f0
#define M3_FIFO_LAT_MAX         0x3300
#define M3_FIFO_LAT_SUM_OVRFLW  0x3310

#define M0_ARB_LAT_SUM_HIGH    0x3320
#define M0_ARB_LAT_SUM_LOW     0x3330
#define M0_ARB_LAT_COUNT_HIGH  0x3340
#define M0_ARB_LAT_COUNT_LOW   0x3350
#define M0_ARB_LAT_MIN         0x3360
#define M0_ARB_LAT_MAX         0x3370
#define M0_ARB_LAT_SUM_OVRFLW  0x3380
#define M1_ARB_LAT_SUM_HIGH    0x3390
#define M1_ARB_LAT_SUM_LOW     0x33a0
#define M1_ARB_LAT_COUNT_HIGH  0x33b0
#define M1_ARB_LAT_COUNT_LOW   0x33c0
#define M1_ARB_LAT_MIN         0x33d0
#define M1_ARB_LAT_MAX         0x33e0
#define M1_ARB_LAT_SUM_OVRFLW  0x33f0
#define M2_ARB_LAT_SUM_HIGH    0x3400
#define M2_ARB_LAT_SUM_LOW     0x3410
#define M2_ARB_LAT_COUNT_HIGH  0x3420
#define M2_ARB_LAT_COUNT_LOW   0x3430
#define M2_ARB_LAT_MIN         0x3440
#define M2_ARB_LAT_MAX         0x3450
#define M2_ARB_LAT_SUM_OVRFLW  0x3460
#define M3_ARB_LAT_SUM_HIGH    0x3470
#define M3_ARB_LAT_SUM_LOW     0x3480
#define M3_ARB_LAT_COUNT_HIGH  0x3490
#define M3_ARB_LAT_COUNT_LOW   0x34a0
#define M3_ARB_LAT_MIN         0x34b0
#define M3_ARB_LAT_MAX         0x34c0
#define M3_ARB_LAT_SUM_OVRFLW  0x34d0

#define RGB565(r, g, b) ((short)(((b) & 0x1f) | (((g) & 0x3f) << 5) | (((r) & 0x1f) << 11)))
#define UI_BG          RGB565(1, 4, 4)
#define UI_HEADER      RGB565(2, 8, 9)
#define UI_PANEL       RGB565(2, 7, 6)
#define UI_TOP_PANEL   RGB565(2, 7, 6)
#define UI_BORDER      RGB565(8, 35, 28)
#define UI_BORDER_DIM  RGB565(5, 18, 16)
#define UI_TITLE       RGB565(18, 56, 20)
#define UI_TEXT        RGB565(15, 48, 18)
#define UI_MUTED       RGB565(9, 28, 13)
#define UI_VALUE       RGB565(31, 38, 5)
#define UI_BAR         RGB565(3, 55, 4)
#define UI_BAR_EDGE    RGB565(10, 63, 10)
#define UI_MASTER      RGB565(6, 13, 19)
#define UI_ARB         RGB565(4, 22, 14)
#define UI_FIFO        RGB565(18, 12, 9)
#define UI_BANK        RGB565(7, 13, 22)
#define UI_LINE        RGB565(12, 46, 31)
int fd;
void *h2p_lw_virtual_base, *vga_pixel_virtual_base, *vga_char_virtual_base, *fifo_virtual_base;
FILE *flat_log0, *flat_log1, *flat_log2, *flat_log3, *ablat_log0, *ablat_log1, *ablat_log2, *ablat_log3;
struct timespec t1, t2;

sem_t reset_sem;

// updating speed in ms
int lat_stat_gap = 100;
int config_gap = 1000;
// bar chart plotting parameters
int bar_height = 72, bar_width = 25, bar_distance = 15;
int bar_plot_x0 = 280, bar_plot_y0 = 150;
int bar_plot_x1 = 32, bar_plot_y1 = 300, bar_plot_x2 = 242, bar_plot_y2 = 300, bar_plot_x3 = 452, bar_plot_y3 = 300;
int bar_plot_x4 = 32, bar_plot_y4 = 450, bar_plot_x5 = 242, bar_plot_y5 = 450, bar_plot_x6 = 452, bar_plot_y6 = 450;

volatile unsigned int *vga_pixel_ptr, *vga_char_ptr;
volatile unsigned int *m0_fLat_data, *m1_fLat_data, *m2_fLat_data, *m3_fLat_data;
volatile unsigned int *m0_abLat_data, *m1_abLat_data, *m2_abLat_data, *m3_abLat_data;
volatile unsigned int *reset_pio, *arb_mode_pio, *addr_gen_mode_pio, *mem_delay_cycle_pio, *pipeline_design_pio, *read_request_pio;
volatile unsigned int *m0_issue_gap_pio, *m1_issue_gap_pio, *m2_issue_gap_pio, *m3_issue_gap_pio;
volatile unsigned int *m0_serv_count_pio, *m1_serv_count_pio, *m2_serv_count_pio, *m3_serv_count_pio;
volatile unsigned int *m0_fifo_lat_sum_high, *m0_fifo_lat_sum_low, *m0_fifo_lat_count_high, *m0_fifo_lat_count_low, *m0_fifo_lat_min, *m0_fifo_lat_max, *m0_fifo_lat_sum_ovrflw;
volatile unsigned int *m1_fifo_lat_sum_high, *m1_fifo_lat_sum_low, *m1_fifo_lat_count_high, *m1_fifo_lat_count_low, *m1_fifo_lat_min, *m1_fifo_lat_max, *m1_fifo_lat_sum_ovrflw;
volatile unsigned int *m2_fifo_lat_sum_high, *m2_fifo_lat_sum_low, *m2_fifo_lat_count_high, *m2_fifo_lat_count_low, *m2_fifo_lat_min, *m2_fifo_lat_max, *m2_fifo_lat_sum_ovrflw;
volatile unsigned int *m3_fifo_lat_sum_high, *m3_fifo_lat_sum_low, *m3_fifo_lat_count_high, *m3_fifo_lat_count_low, *m3_fifo_lat_min, *m3_fifo_lat_max, *m3_fifo_lat_sum_ovrflw;
volatile unsigned int *m0_arb_lat_sum_high, *m0_arb_lat_sum_low, *m0_arb_lat_count_high, *m0_arb_lat_count_low, *m0_arb_lat_min, *m0_arb_lat_max, *m0_arb_lat_sum_ovrflw;
volatile unsigned int *m1_arb_lat_sum_high, *m1_arb_lat_sum_low, *m1_arb_lat_count_high, *m1_arb_lat_count_low, *m1_arb_lat_min, *m1_arb_lat_max, *m1_arb_lat_sum_ovrflw;
volatile unsigned int *m2_arb_lat_sum_high, *m2_arb_lat_sum_low, *m2_arb_lat_count_high, *m2_arb_lat_count_low, *m2_arb_lat_min, *m2_arb_lat_max, *m2_arb_lat_sum_ovrflw;
volatile unsigned int *m3_arb_lat_sum_high, *m3_arb_lat_sum_low, *m3_arb_lat_count_high, *m3_arb_lat_count_low, *m3_arb_lat_min, *m3_arb_lat_max, *m3_arb_lat_sum_ovrflw;


/***************************************************************************************
 * helper functions
****************************************************************************************/

// helper function for finding the minimum value inside an array
static unsigned int find_max (unsigned int *array, int size) {
	if(!array || size <= 0) {
		printf("invalid parameters for find_max!\n");
		return -1;
	}
	
	unsigned int max = array[0];
	int i;

	for(i = 0; i < size; i++) {
		max = (array[i] > max)? array[i] : max;
	}

	return max;
}

// Draw one centered normal-size text string inside [x1, x2].
static void draw_centered_string(int x1, int x2, int y, char *text, short color, short bg) {
	int text_width = (int)strlen(text) * 6;
	int text_x = x1 + ((x2 - x1 + 1) - text_width) / 2;
	VGA_drawString(text_x, y, text, color, bg, 1);
}

static void draw_centered_string_big(int x1, int x2, int y, char *text, short color, short bg) {
	int text_width = (int)strlen(text) * 8;
	int text_x = x1 + ((x2 - x1 + 1) - text_width) / 2;
	VGA_drawStringBig(text_x, y, text, color, bg, 1);
}

static void draw_labeled_box(int x1, int y1, int x2, int y2, char *label, short box_color, short text_color) {
	int label_width = (int)strlen(label) * 6;
	int label_x = x1 + ((x2 - x1 + 1) - label_width) / 2;
	int label_y = y1 + ((y2 - y1 + 1) - 8) / 2;

	VGA_box(x1, y1, x2, y2, box_color);
	VGA_rect(x1, y1, x2, y2, UI_BORDER);
	VGA_drawString(label_x, label_y, label, text_color, box_color, 1);
}

static void draw_system_architecture(int x, int y) {
	int i;
	int master_x[4] = {x + 0, x + 45, x + 90, x + 135};
	int bank_x[4] = {x + 0, x + 45, x + 90, x + 135};
	char *master_label[4] = {"M0", "M1", "M2", "M3"};
	char *bank_label[4] = {"B0", "B1", "B2", "B3"};

	for(i = 0; i < 4; i++) {
		draw_labeled_box(master_x[i], y + 0, master_x[i] + 31, y + 13, master_label[i], UI_MASTER, UI_TEXT);
		VGA_line(master_x[i] + 15, y + 14, master_x[i] + 15, y + 23, UI_LINE);
	}

	draw_labeled_box(x + 0, y + 24, x + 166, y + 41, "Arbiter", UI_ARB, UI_VALUE);
	VGA_line(x + 83, y + 42, x + 83, y + 53, UI_LINE);
	VGA_Hline(x + 15, y + 53, x + 150, UI_LINE);

	for(i = 0; i < 4; i++) {
		VGA_line(bank_x[i] + 15, y + 53, bank_x[i] + 15, y + 59, UI_LINE);
		draw_labeled_box(bank_x[i], y + 60, bank_x[i] + 31, y + 72, "FIFO", UI_FIFO, white);
		VGA_line(bank_x[i] + 15, y + 73, bank_x[i] + 15, y + 77, UI_LINE);
		draw_labeled_box(bank_x[i], y + 78, bank_x[i] + 31, y + 91, bank_label[i], UI_BANK, UI_TEXT);
	}
}

static void draw_panel(int x1, int y1, int x2, int y2, char *title) {
	short panel_bg = (y2 <= 168) ? UI_TOP_PANEL : UI_PANEL;
	VGA_box(x1, y1, x2, y2, panel_bg);
	VGA_rect(x1, y1, x2, y2, UI_BORDER_DIM);
	VGA_Hline(x1 + 1, y1 + 1, x2 - 1, UI_BORDER);
	if(title && title[0]) {
		draw_centered_string(x1, x2, y1 + 5, title, UI_TITLE, panel_bg);
		VGA_Hline(x1 + 8, y1 + 18, x2 - 8, UI_BORDER_DIM);
	}
}

static short plot_bg_for_y(int y) {
	return (y < 176) ? UI_TOP_PANEL : UI_PANEL;
}
static void draw_dashboard_frame(void) {
	VGA_box(0, 0, 639, 479, UI_BG);
	VGA_box(0, 0, 639, 34, UI_HEADER);
	VGA_Hline(0, 34, 639, UI_BORDER);
	draw_centered_string_big(0, 639, 8, "Performance monitoring SoC interconnect subsystem on FPGA", UI_TITLE, UI_HEADER);

	draw_panel(8, 40, 262, 171, "Configuration");
	draw_panel(272, 40, 432, 171, "");
	draw_panel(444, 40, 632, 171, "System Architecture");

	draw_panel(10, 176, 205, 326, "");
	draw_panel(220, 176, 415, 326, "");
	draw_panel(430, 176, 625, 326, "");
	draw_panel(10, 330, 205, 474, "");
	draw_panel(220, 330, 415, 474, "");
	draw_panel(430, 330, 625, 474, "");

	draw_system_architecture(455, 68);
}

// helper function to draw a config row with stable label/value colors
static void draw_config_line(int x, int y, char *label, char *value) {
	int value_x = x + (int)strlen(label) * 6;
	VGA_drawString(x, y, label, UI_MUTED, UI_TOP_PANEL, 1);
	VGA_box(value_x, y, value_x + 92, y + 8, UI_TOP_PANEL);
	VGA_drawString(value_x, y, value, UI_VALUE, UI_TOP_PANEL, 1);
}

static void draw_bar(int x, int y, int width, int height) {
	if(height <= 0) {
		VGA_Hline(x, y, x + width, UI_BAR_EDGE);
		return;
	}
	VGA_box(x, y, x + width, y - height, UI_BAR);
	VGA_rect(x, y - height, x + width, y, UI_BAR_EDGE);
}

static void draw_bar_value(int bar_x, int panel_value_right, int y, int width, char *text, short color, short bg) {
	int text_width = (int)strlen(text) * 6;
	int text_x = bar_x + (width - text_width) / 2;
	if(text_x + text_width > panel_value_right) text_x = panel_value_right - text_width;
	if(text_x < bar_x - 8) text_x = bar_x - 8;
	VGA_drawString(text_x, y, text, color, bg, 1);
}
void int_bar_plot(int x, int y, int max_height, int width, int distance, char *title, 
	unsigned int d0, unsigned int d1, unsigned int d2, unsigned int d3, int *prev_height) {

	int i, bar_height[4];
	unsigned int max_data, data[4];
	short plot_bg = plot_bg_for_y(y);
	char buf[128];

	data[0] = d0;
	data[1] = d1;
	data[2] = d2;
	data[3] = d3;

	for(i = 0; i < 4; i++) {
		if(data[i] == 0xFFFFFFFF) data[i] = 0;
	}

	max_data = find_max(data, 4);
	if(max_data == 0) max_data = 1;

	draw_centered_string(x - 14, x + 165, y - max_height - 30, title, UI_TITLE, plot_bg);

	for(i = 0; i < 4; i++) {
		bar_height[i] = max_height * data[i] / max_data;
	}
	
	for(i = 0; i < 4; i++) {
		int bar_x = x + i * (distance + width);
		VGA_box(bar_x - 7, y - prev_height[i] - 14, bar_x + width + 2, y - prev_height[i] + 1, plot_bg);
		if(prev_height[i] > bar_height[i]) {
			VGA_box(bar_x, y - prev_height[i] - 1, bar_x + width, y - bar_height[i] - 1, plot_bg);
		}
	}

	for(i = 0; i < 4; i++) {
		int bar_x = x + i * (distance + width);
		draw_bar(bar_x, y, width, bar_height[i]);
		sprintf(buf, "%u", data[i]);
		draw_bar_value(bar_x, x + 150, y - 12 - bar_height[i], width, buf, UI_VALUE, plot_bg);
		sprintf(buf, "M%d", i);
		draw_bar_value(bar_x, x + 150, y + 10, width, buf, UI_TEXT, plot_bg);
		prev_height[i] = bar_height[i];
	}
}

void float_bar_plot(int x, int y, int max_height, int width, int distance, char *title, 
	float d0, float d1, float d2, float d3, int *prev_height) {

	int i, bar_height[4];
	unsigned int max_data, data[4];
	short plot_bg = plot_bg_for_y(y);
	float value[4];
	char buf[128];

	value[0] = d0;
	value[1] = d1;
	value[2] = d2;
	value[3] = d3;
	data[0] = (unsigned int)d0;
	data[1] = (unsigned int)d1;
	data[2] = (unsigned int)d2;
	data[3] = (unsigned int)d3;

	max_data = find_max(data, 4);
	if(max_data == 0) max_data = 1;

	draw_centered_string(x - 14, x + 165, y - max_height - 30, title, UI_TITLE, plot_bg);

	for(i = 0; i < 4; i++) {
		bar_height[i] = max_height * data[i] / max_data;
	}

	for(i = 0; i < 4; i++) {
		int bar_x = x + i * (distance + width);
		VGA_box(bar_x - 7, y - prev_height[i] - 14, bar_x + width + 2, y - prev_height[i] + 1, plot_bg);
		if(prev_height[i] > bar_height[i]) {
			VGA_box(bar_x, y - prev_height[i] - 1, bar_x + width, y - bar_height[i] - 1, plot_bg);
		}
	}

	for(i = 0; i < 4; i++) {
		int bar_x = x + i * (distance + width);
		draw_bar(bar_x, y, width, bar_height[i]);
		sprintf(buf, "%.2f", value[i]);
		draw_bar_value(bar_x, x + 150, y - 12 - bar_height[i], width, buf, UI_VALUE, plot_bg);
		sprintf(buf, "M%d", i);
		draw_bar_value(bar_x, x + 150, y + 10, width, buf, UI_TEXT, plot_bg);
		prev_height[i] = bar_height[i];
	}
}
/***************************************************************************************
 * Threads definition 
****************************************************************************************/

void* user_input (void *arg) {

	char input_buffer[64];
	unsigned int mode, cycles, gap0, gap1, gap2, gap3;

	*mem_delay_cycle_pio = 5; // applies to non-pipelined design
	*m0_issue_gap_pio = 0; // actual generation period when no delay is issue_gap + 3,

	printf("Available commands: arb_mode, addr_gen_mode, mem_access_mode, mem_delay_cycle, req_gen_gap, reset\n");

	while(1) {
		printf("Enter a command: ");
		scanf("%63s",input_buffer); // limit input to 63 characters to prevent input buffer overflow
		if(strcmp(input_buffer, "arb_mode") == 0) {
			printf("Input arbitraiton mode (0: fixed priority  1: round robin 2: weighted round robin): ");
			int n = scanf("%u", &mode);
			if(n != 1 || mode >= 3) {
				printf("Invalid input for arbitraiton mode!\n");
				int ch;
				// EOF is a special constant defined in <stdio.h> that signals “end of input.”
				while((ch = getchar()) != '\n' && ch != EOF) {} // clear the input buffer
				continue;
			}
			// set the desired mode then signal reset/log thread to reset fpga
			*arb_mode_pio = mode;
			sem_post(&reset_sem);
		}
		else if(strcmp(input_buffer, "addr_gen_mode") == 0) {
			printf("Input request address generation mode (0: linear, 1: pseudo random, 2: hot spot): ");
			int n = scanf("%u", &mode);
			if(n != 1 || mode >= 3) {
				printf("Invalid input for address generation mode!\n");
				int ch;
				while((ch = getchar()) != '\n' && ch != EOF) {}
				continue;
			}
			*addr_gen_mode_pio = mode;
			sem_post(&reset_sem);
		}
		else if(strcmp(input_buffer, "mem_access_mode") == 0) {
			printf("Input memory access mode (0: non-pipelined, 1: pipelined): ");
			int n = scanf("%u", &mode);
			if(n != 1 || mode >= 2) {
				printf("Invalid input for memory access mode!\n");
				int ch;
				while((ch = getchar()) != '\n' && ch != EOF) {}
				continue;
			}
			*pipeline_design_pio = mode;
			sem_post(&reset_sem);
		}
		else if(strcmp(input_buffer, "mem_delay_cycle") == 0) {
			printf("Input memory access delay cycles (valid only for non-pipelined design): ");
			int n = scanf("%u", &cycles);
			if(n != 1) {
				printf("Invalid input for memory delay cycles!\n");
				int ch;
				while((ch = getchar()) != '\n' && ch != EOF) {}
				continue;
			}
			*mem_delay_cycle_pio = cycles;
			sem_post(&reset_sem);
		}
		else if(strcmp(input_buffer, "req_gen_gap") == 0) {
			printf("Input request generation gap for 4 masters sequentially: ");
			int n = scanf("%u %u %u %u", &gap0, &gap1, &gap2, &gap3);
			if(n != 4) {
				printf("Invalid input for request generation gaps!\n");
				int ch;
				while((ch = getchar()) != '\n' && ch != EOF) {}
				continue;
			}
			*m0_issue_gap_pio = gap0;
			*m1_issue_gap_pio = gap1;
			*m2_issue_gap_pio = gap2;
			*m3_issue_gap_pio = gap3;
			sem_post(&reset_sem);
		}
		else if(strcmp(input_buffer, "reset") == 0) {
			// clear the whole screen
			memset(vga_pixel_ptr, 0x0000, 640*480*sizeof(short));
			// draw all the static part of the dashboard again
			draw_dashboard_frame();
			sem_post(&reset_sem);
		}
		else {
			printf("Invalid command!\r\n");
		}
	}
}

void* latency_stat_read (void *arg) {

	int prev_height1[4] = {0, 0, 0, 0}, prev_height2[4] = {0, 0, 0, 0}, prev_height3[4] = {0, 0, 0, 0};
	int prev_height4[4] = {0, 0, 0, 0}, prev_height5[4] = {0, 0, 0, 0}, prev_height6[4] = {0, 0, 0, 0};

	while(1) {

		if(clock_gettime(CLOCK_MONOTONIC, &t1) == -1) {
			perror("clock_gettime");
			return NULL;
		}
		t1.tv_nsec += lat_stat_gap * NSEC_PER_MSEC; // sample latency statistics every 100ms
		// accounts for 1 sec rollover
		while(t1.tv_nsec >= NSEC_PER_SEC) {
			t1.tv_nsec -= NSEC_PER_SEC;
			t1.tv_sec++;
		}
		
		// // clear precviously drawn content
		// VGA_box(bar_plot_x1 - 10, bar_plot_y1 - 120, 640, bar_plot_y1 + 10, black);

		// send request to FPGA to read data
		*read_request_pio = 1;
		usleep(5);
		*read_request_pio = 0;
		usleep(5);

		float m0_fifo_lat_avg = ((long long)(*m0_fifo_lat_sum_high) << 32 | (long long)(*m0_fifo_lat_sum_low)) / (float)((long long)(*m0_fifo_lat_count_high) << 32 | (long long)(*m0_fifo_lat_count_low));
		float m0_arb_lat_avg = ((long long)(*m0_arb_lat_sum_high) << 32 | (long long)(*m0_arb_lat_sum_low)) / (float)((long long)(*m0_arb_lat_count_high) << 32 | (long long)(*m0_arb_lat_count_low));

		float m1_fifo_lat_avg = ((long long)(*m1_fifo_lat_sum_high) << 32 | (long long)(*m1_fifo_lat_sum_low)) / (float)((long long)(*m1_fifo_lat_count_high) << 32 | (long long)(*m1_fifo_lat_count_low));
		float m1_arb_lat_avg = ((long long)(*m1_arb_lat_sum_high) << 32 | (long long)(*m1_arb_lat_sum_low)) / (float)((long long)(*m1_arb_lat_count_high) << 32 | (long long)(*m1_arb_lat_count_low));

		float m2_fifo_lat_avg = ((long long)(*m2_fifo_lat_sum_high) << 32 | (long long)(*m2_fifo_lat_sum_low)) / (float)((long long)(*m2_fifo_lat_count_high) << 32 | (long long)(*m2_fifo_lat_count_low));
		float m2_arb_lat_avg = ((long long)(*m2_arb_lat_sum_high) << 32 | (long long)(*m2_arb_lat_sum_low)) / (float)((long long)(*m2_arb_lat_count_high) << 32 | (long long)(*m2_arb_lat_count_low));

		float m3_fifo_lat_avg = ((long long)(*m3_fifo_lat_sum_high) << 32 | (long long)(*m3_fifo_lat_sum_low)) / (float)((long long)(*m3_fifo_lat_count_high) << 32 | (long long)(*m3_fifo_lat_count_low));
		float m3_arb_lat_avg = ((long long)(*m3_arb_lat_sum_high) << 32 | (long long)(*m3_arb_lat_sum_low)) / (float)((long long)(*m3_arb_lat_count_high) << 32 | (long long)(*m3_arb_lat_count_low));

		float_bar_plot(bar_plot_x1, bar_plot_y1, bar_height, bar_width, bar_distance, "Average Arbitration",
			m0_arb_lat_avg, m1_arb_lat_avg, m2_arb_lat_avg, m3_arb_lat_avg, prev_height1);

		int_bar_plot(bar_plot_x2, bar_plot_y2, bar_height, bar_width, bar_distance, "Maximum Arbitration",
			*m0_arb_lat_max, *m1_arb_lat_max, *m2_arb_lat_max, *m3_arb_lat_max, prev_height2);
		
		int_bar_plot(bar_plot_x3, bar_plot_y3, bar_height, bar_width, bar_distance, "Minimum Arbitration",
			*m0_arb_lat_min, *m1_arb_lat_min, *m2_arb_lat_min, *m3_arb_lat_min, prev_height3);

		float_bar_plot(bar_plot_x4, bar_plot_y4, bar_height, bar_width, bar_distance, "Average Bank Access",
			m0_fifo_lat_avg, m1_fifo_lat_avg, m2_fifo_lat_avg, m3_fifo_lat_avg, prev_height4);

		int_bar_plot(bar_plot_x5, bar_plot_y5, bar_height, bar_width, bar_distance, "Maximum Bank Access",
			*m0_fifo_lat_max, *m1_fifo_lat_max, *m2_fifo_lat_max, *m3_fifo_lat_max, prev_height5);
		
		int_bar_plot(bar_plot_x6, bar_plot_y6, bar_height, bar_width, bar_distance, "Minimum Bank Access",
			*m0_fifo_lat_min, *m1_fifo_lat_min, *m2_fifo_lat_min, *m3_fifo_lat_min, prev_height6);

		// Sleep unitl next deadline, or skip sleeping if deadline is missed
		int rc = clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &t1, NULL);
		if(rc != 0) {
			errno = rc;
			perror("clock_nanosleep");
			return NULL;
		}
	}

	return NULL;
}

void* config_display (void *arg) {

	char config_buf[256];
	char *arb_mode, *addr_gen_mode, *pipeline_mode;
	int config_x = 16, config_y = 64, config_line_gap = 10;
	int prev_height0[4] = {0, 0, 0, 0};

	while(1) {
		if(clock_gettime(CLOCK_MONOTONIC, &t2) == -1) {
			perror("clock_gettime");
			return NULL;
		}
		t2.tv_nsec += config_gap * NSEC_PER_MSEC; // sample configuration settings every 100ms
		// accounts for 1 sec rollover
		while (t2.tv_nsec >= NSEC_PER_SEC) {
			t2.tv_nsec -= NSEC_PER_SEC;
			t2.tv_sec++;
		}

		switch(*arb_mode_pio) {
			case 0: 
				arb_mode = "Fixed Priority"; break;
			case 1:
				arb_mode = "Round Robin"; break;
			case 2:
				arb_mode = "Weighted RR"; break;
			default:
				arb_mode = "NaN";
		}
		draw_config_line(config_x, config_y + config_line_gap * 0, "Arbitration: ", arb_mode);

		switch(*addr_gen_mode_pio) {
			case 0:
				addr_gen_mode = "Linear"; break;
			case 1:
				addr_gen_mode = "Pseudo Random"; break;
			case 2:
				addr_gen_mode = "Hot Spot"; break;
			default:
				addr_gen_mode = "NaN";
		}
		draw_config_line(config_x, config_y + config_line_gap * 1, "Address Mode: ", addr_gen_mode);

		switch(*pipeline_design_pio) {
			case 0:
				pipeline_mode = "Non-pipelined"; break;
			case 1:
				pipeline_mode = "Pipelined"; break;
			default:
				pipeline_mode = "NaN"; break;
		}
		draw_config_line(config_x, config_y + config_line_gap * 2, "Bank Mode: ", pipeline_mode);

		if(*pipeline_design_pio == 1)
			sprintf(config_buf, "0");
		else
			sprintf(config_buf, "%u", *mem_delay_cycle_pio);
		draw_config_line(config_x, config_y + config_line_gap * 3, "Bank Delay: ", config_buf);

		sprintf(config_buf, "%u cycles", *m0_issue_gap_pio);
		draw_config_line(config_x, config_y + config_line_gap * 4, "M0 Issue Gap: ", config_buf);

		sprintf(config_buf, "%u cycles", *m1_issue_gap_pio);
		draw_config_line(config_x, config_y + config_line_gap * 5, "M1 Issue Gap: ", config_buf);

		sprintf(config_buf, "%u cycles", *m2_issue_gap_pio);
		draw_config_line(config_x, config_y + config_line_gap * 6, "M2 Issue Gap: ", config_buf);

		sprintf(config_buf, "%u cycles", *m3_issue_gap_pio);
		draw_config_line(config_x, config_y + config_line_gap * 7, "M3 Issue Gap: ", config_buf);

		VGA_drawString(config_x, config_y + config_line_gap * 9, "Latency Units: cycles (50MHz)", UI_MUTED, UI_TOP_PANEL, 1);

		int_bar_plot(bar_plot_x0, bar_plot_y0, bar_height, bar_width, bar_distance, "Service Count",
		*m0_serv_count_pio, *m1_serv_count_pio, *m2_serv_count_pio, *m3_serv_count_pio, prev_height0);
		
		int rc = clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &t2, NULL);
		if(rc != 0) {
			errno = rc;
			perror("clock_nanosleep");
			return NULL;
		}
	}

	return NULL;
}

void* reset_and_log (void *arg) {

	unsigned int m0_flat, m1_flat, m2_flat, m3_flat;
	unsigned int m0_ablat, m1_ablat, m2_ablat, m3_ablat;

	while(1) {
		sem_wait(&reset_sem);

		*reset_pio = 1;
		usleep(5);
		*reset_pio = 0;

		flat_log0 = fopen("flat_log0.txt", "w");
		flat_log1 = fopen("flat_log1.txt", "w");
		flat_log2 = fopen("flat_log2.txt", "w");
		flat_log3 = fopen("flat_log3.txt", "w");
		ablat_log0 = fopen("ablat_log0.txt", "w");
		ablat_log1 = fopen("ablat_log1.txt", "w");
		ablat_log2 = fopen("ablat_log2.txt", "w");
		ablat_log3 = fopen("ablat_log3.txt", "w");
		// check if file open is succeeded or not
		if(!flat_log0 || !flat_log1 || !flat_log2 || !flat_log3 || !ablat_log0 || !ablat_log1 || !ablat_log2 || !ablat_log3) {
			perror("fopen");
			return NULL;
		}

		int i = 0;

		// log the data at every reset/condition change, up to 4096 counts (intel fifo ip depth)
		while(i < 2048) {

			m0_flat = *m0_fLat_data;
			fprintf(flat_log0, "%u, %u\n", m0_flat>>3, m0_flat & 0x7);
			m1_flat = *m1_fLat_data;
			fprintf(flat_log1, "%u, %u\n", m1_flat>>3, m1_flat & 0x7);
			m2_flat = *m2_fLat_data;
			fprintf(flat_log2, "%u, %u\n", m2_flat>>3, m2_flat & 0x7);
			m3_flat = *m3_fLat_data;
			fprintf(flat_log3, "%u, %u\n", m3_flat>>3, m3_flat & 0x7);
			
			m0_ablat = *m0_abLat_data;
			fprintf(ablat_log0, "%u\n", m0_ablat);
			m1_ablat = *m1_abLat_data;
			fprintf(ablat_log1, "%u\n", m1_ablat);
			m2_ablat = *m2_abLat_data;
			fprintf(ablat_log2, "%u\n", m2_ablat);
			m3_ablat = *m3_abLat_data;
			fprintf(ablat_log3, "%u\n", m3_ablat);

			i++;
		}

		fclose(flat_log0);
		fclose(flat_log1);
		fclose(flat_log2);
		fclose(flat_log3);
		fclose(ablat_log0);
		fclose(ablat_log1);
		fclose(ablat_log2);
		fclose(ablat_log3);
	}
}

/***************************************************************************************
 * main function 
****************************************************************************************/

int main(void) {

	pthread_t latency_stat_thread, config_draw_thread, reset_thread, user_input_thread;
	
    // Open /dev/mem, get virtual addr that maps to physical
	if((fd = open("/dev/mem",(O_RDWR|O_SYNC))) == -1) {
		perror("open");
		return(1);
	}

    // get lw_axi bus addr
	h2p_lw_virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, HW_REGS_BASE);	
	if(h2p_lw_virtual_base == MAP_FAILED) {
		perror("mmap0");
		close(fd);
		return(1);
	} 

	// get VGA char addr
	vga_char_virtual_base = mmap(NULL, FPGA_CHAR_SPAN, ( PROT_READ | PROT_WRITE), MAP_SHARED, fd, FPGA_CHAR_BASE);	
	if(vga_char_virtual_base == MAP_FAILED) {
		perror("mmap1");
		close(fd);
		return(1);
	}
	vga_char_ptr = (volatile unsigned int *)(vga_char_virtual_base);

	// get VGA pixel addr that maps to pixel buffer in SDRAM
	vga_pixel_virtual_base = mmap(NULL, SDRAM_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, SDRAM_BASE);	
	if(vga_pixel_virtual_base == MAP_FAILED) {
		perror("mmap2");
		close(fd);
		return(1);
	}
	vga_pixel_ptr = (volatile unsigned int *)(vga_pixel_virtual_base);

	// get fifo addr base
	fifo_virtual_base = mmap(NULL, FIFO_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, FIFO_BASE);
	if(fifo_virtual_base == MAP_FAILED) {
		perror("mmap3");
		close(fd);
		return(1);
	}

	m0_fLat_data = (volatile unsigned int *)(fifo_virtual_base + M0_FLAT_DATA);
	m1_fLat_data = (volatile unsigned int *)(fifo_virtual_base + M1_FLAT_DATA);
	m2_fLat_data = (volatile unsigned int *)(fifo_virtual_base + M2_FLAT_DATA);
	m3_fLat_data = (volatile unsigned int *)(fifo_virtual_base + M3_FLAT_DATA);

	m0_abLat_data = (volatile unsigned int *)(fifo_virtual_base + M0_ABLAT_DATA);;
	m1_abLat_data = (volatile unsigned int *)(fifo_virtual_base + M1_ABLAT_DATA);
	m2_abLat_data = (volatile unsigned int *)(fifo_virtual_base + M2_ABLAT_DATA);
	m3_abLat_data = (volatile unsigned int *)(fifo_virtual_base + M3_ABLAT_DATA);

	reset_pio = (volatile unsigned int *)(h2p_lw_virtual_base + RESET_PIO);
	arb_mode_pio = (volatile unsigned int *)(h2p_lw_virtual_base + ARB_MODE_PIO);
	addr_gen_mode_pio = (volatile unsigned int *)(h2p_lw_virtual_base + ADDR_GEN_MODE_PIO);
	mem_delay_cycle_pio = (volatile unsigned int *)(h2p_lw_virtual_base + MEM_DELAY_CYCLE_PIO);
	pipeline_design_pio = (volatile unsigned int *)(h2p_lw_virtual_base + PIPELINE_DESIGN_PIO);
	read_request_pio = (volatile unsigned int *)(h2p_lw_virtual_base + DATA_REQUEST_PIO);

	m0_issue_gap_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ISSUE_GAP_PIO);
	m1_issue_gap_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ISSUE_GAP_PIO);
	m2_issue_gap_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ISSUE_GAP_PIO);
	m3_issue_gap_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ISSUE_GAP_PIO);

	m0_serv_count_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M0_SERV_COUNT_PIO);
	m1_serv_count_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M1_SERV_COUNT_PIO);
	m2_serv_count_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M2_SERV_COUNT_PIO);
	m3_serv_count_pio = (volatile unsigned int *)(h2p_lw_virtual_base + M3_SERV_COUNT_PIO);

	m0_fifo_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_SUM_HIGH);
	m0_fifo_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_SUM_LOW);
	m0_fifo_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_COUNT_HIGH);
	m0_fifo_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_COUNT_LOW);
	m0_fifo_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_MIN);
	m0_fifo_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_MAX);
	m0_fifo_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M0_FIFO_LAT_SUM_OVRFLW);

	m1_fifo_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_SUM_HIGH);
	m1_fifo_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_SUM_LOW);
	m1_fifo_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_COUNT_HIGH);
	m1_fifo_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_COUNT_LOW);
	m1_fifo_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_MIN);
	m1_fifo_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_MAX);
	m1_fifo_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M1_FIFO_LAT_SUM_OVRFLW);

	m2_fifo_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_SUM_HIGH);
	m2_fifo_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_SUM_LOW);
	m2_fifo_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_COUNT_HIGH);
	m2_fifo_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_COUNT_LOW);
	m2_fifo_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_MIN);
	m2_fifo_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_MAX);
	m2_fifo_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M2_FIFO_LAT_SUM_OVRFLW);

	m3_fifo_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_SUM_HIGH);
	m3_fifo_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_SUM_LOW);
	m3_fifo_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_COUNT_HIGH);
	m3_fifo_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_COUNT_LOW);
	m3_fifo_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_MIN);
	m3_fifo_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_MAX);
	m3_fifo_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M3_FIFO_LAT_SUM_OVRFLW);

	m0_arb_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_SUM_HIGH);
	m0_arb_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_SUM_LOW);
	m0_arb_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_COUNT_HIGH);
	m0_arb_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_COUNT_LOW);
	m0_arb_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_MIN);
	m0_arb_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_MAX);
	m0_arb_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M0_ARB_LAT_SUM_OVRFLW);

	m1_arb_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_SUM_HIGH);
	m1_arb_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_SUM_LOW);
	m1_arb_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_COUNT_HIGH);
	m1_arb_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_COUNT_LOW);
	m1_arb_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_MIN);
	m1_arb_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_MAX);
	m1_arb_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M1_ARB_LAT_SUM_OVRFLW);

	m2_arb_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_SUM_HIGH);
	m2_arb_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_SUM_LOW);
	m2_arb_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_COUNT_HIGH);
	m2_arb_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_COUNT_LOW);
	m2_arb_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_MIN);
	m2_arb_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_MAX);
	m2_arb_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M2_ARB_LAT_SUM_OVRFLW);

	m3_arb_lat_sum_high = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_SUM_HIGH);
	m3_arb_lat_sum_low = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_SUM_LOW);
	m3_arb_lat_count_high = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_COUNT_HIGH);
	m3_arb_lat_count_low = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_COUNT_LOW);
	m3_arb_lat_min = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_MIN);
	m3_arb_lat_max = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_MAX);
	m3_arb_lat_sum_ovrflw = (volatile unsigned int *)(h2p_lw_virtual_base + M3_ARB_LAT_SUM_OVRFLW);

	// Initalize VGA functions
	VGA_init(vga_pixel_ptr, vga_char_ptr);
	// draw static dashboard frame
	draw_dashboard_frame();

	// default system settings
	*arb_mode_pio = 2; // 0: fixed priority  1: round robin 2: weighted round robin
	*addr_gen_mode_pio = 1; // 0: linear address generation, 1: pseudo random address generation, 2: hot spot address generation
	*pipeline_design_pio = 0; // for M10K memory wrapped target, 0: non-pipelined, 1: pipelined
	*mem_delay_cycle_pio = 0; // applies to non-pipelined design
	*m0_issue_gap_pio = 0;
	*m1_issue_gap_pio = 0;
	*m2_issue_gap_pio = 0;
	*m3_issue_gap_pio = 0;

	// target memory bank delay cycles under non-piplined mode, (3/5 + delay) cycles per write/read
	// For arbitor, max data output speed to fifo is fixed at 3 cycle/packet (arb_latency + 2) (1 for serv_req to drop, 1 for busy to drop, 1 for new req_grant to raise)
	// mixed read and write requests
	// If the masters are not continuously backlogged, then WRR will not necessarily produce the exact configured 4:3:2:1 issue ratio. 
	// A ratio like ~2:2:1:1 can absolutely happen, set all issue gap to 0 when testing WRR
	// minimum arbitration latency 1 when no waiting (from latching data_out)
	// ab_latency = gen_latency + 1(fixed_p & rr mode) (fixed latency due to arbiter design)
	// minimum fifo latency 3: enqueue(1) + fifo_rd_en goes high(1) + dequeue(1)
		
	// reset the FPGA before start
	*reset_pio = 1;
	usleep(5);
	*reset_pio = 0;

	// initialize reset semaphore
	if(sem_init(&reset_sem, 0, 0) == -1) {
		perror("sem_init");
		return -1;
	}

	pthread_create(&latency_stat_thread, NULL, latency_stat_read, NULL);
	pthread_create(&config_draw_thread, NULL, config_display, NULL);
	pthread_create(&user_input_thread, NULL, user_input, NULL);
	pthread_create(&reset_thread, NULL, reset_and_log, NULL);

	pthread_join(latency_stat_thread, NULL);
	pthread_join(config_draw_thread, NULL);
	pthread_join(user_input_thread, NULL);
	pthread_join(reset_thread, NULL);

	return 0;
}