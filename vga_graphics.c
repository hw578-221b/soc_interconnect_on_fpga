#include "vga_graphics.h"
#include "glcdfont.h"
#include "font_rom_brl4.h"
#include <math.h>

// Draw pixel macro
#define VGA_PIXEL(x,y,color) do{\
	/*Comment test*/ \
	((volatile short *)vga_pixel_ptr)[(y)*640+(x)] = (color);\
	/* Another simplified version
	((volatile short *)vga_pixel_ptr + ((y)*640+(x))) = (color); */\
} while(0)

#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

// volatile here means the data it points to it's volatile, not the pointer (address) itself
static volatile unsigned int *vga_pixel_ptr, *vga_char_ptr;


/****************************************************************************************
 * Call this first to initalize global varibale: *vga_pixel_ptr, *vga_char_ptr
****************************************************************************************/

void VGA_init(volatile unsigned int* pixel_ptr, volatile unsigned int* char_ptr) 
{
    vga_pixel_ptr = pixel_ptr;
    vga_char_ptr = char_ptr;
}

/****************************************************************************************
 * Subroutine to send a string of text to the VGA monitor 
****************************************************************************************/

// Visiable area is 79x59 characters
// Hardware buffer is 128x60 characters (8192 bytes)
// Because character buffer span is 0x00002000 (8192 bytes)
void VGA_text(int x, int y, char * text_ptr)
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset;
	/* assume that the text string fits on one line */
	offset = (y << 7) + x;
	while ( *(text_ptr) )
	{
		// write to the character buffer
		*(character_buffer + offset) = *(text_ptr);	
		++text_ptr;
		++offset;
	}
}

/****************************************************************************************
 * Subroutine to clear text to the VGA monitor 
****************************************************************************************/

void VGA_text_clear()
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset, x, y;
	for (x=0; x<79; x++){
		for (y=0; y<59; y++){
	/* assume that the text string fits on one line */
			offset = (y << 7) + x;
			// write to the character buffer
			*(character_buffer + offset) = ' ';		
		}
	}
}

/****************************************************************************************
 * Draw a single char on the VGA monitor 
****************************************************************************************/

// c has to be unsigned char (0-255) here for correct indexing!
void VGA_drawChar(int x, int y, unsigned char c, short color, short bg, char size) {
	int i, j;
	unsigned char line;
	// clip the text if they are beyond the edge
	if(x >= WIDTH || (x + size*6 -1) < 0 || y >= HEIGHT || (y + size*8 -1) < 0)
		return;

	for(i=0; i<6; i++) {
		if(i == 5) // 6th column left blank for spacing
			line = 0x0;
		else
			line = font[c*5 + i];

		for(j=0; j<8; j++) {
			if(line & 0x1) // if there is content at that pixel
				if(size == 1)
					VGA_PIXEL(x+i, y+j, color);
				else
					VGA_box(x+i*size, y+j*size, x+(i+1)*size-1, y+(j+1)*size-1, color);
			else  // no content, draw background color
				if(size == 1)
					VGA_PIXEL(x+i, y+j, bg);
				else
					VGA_box(x+i*size, y+j*size, x+(i+1)*size-1, y+(j+1)*size-1, bg);
			line >>= 1; // go to next data position
		}
	}
}

/****************************************************************************************
 * Draw a string on the VGA monitor 
****************************************************************************************/

void VGA_drawString(int x, int y, char* str, short color, short bg, char font_size) {
	int cursor_x = x, cursor_y = y;
	
	while(*str) {
		if(*str == '\n') {
			// wrap the text to a new line
			cursor_x = x;
			cursor_y += 8*font_size;
			if(cursor_y >= HEIGHT - font_size*8)
				return;
		}
		else if (*str == '\t') {
			cursor_x += 6*TAP_SPACE*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*6) {
				cursor_x = x;
				cursor_y += 8*font_size;
				if(cursor_y >= HEIGHT - font_size*8)
					return;
			}
		}
		else {
			VGA_drawChar(cursor_x, cursor_y, (unsigned char)*str, color, bg, font_size);
			cursor_x += 6*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*6) {
				cursor_x = x;
				cursor_y += 8*font_size;
				if(cursor_y >= HEIGHT - font_size*8)
					return;
			}
		}

		str++;
	} 
}

/****************************************************************************************
 * Draw a bold string on the VGA monitor 
****************************************************************************************/

void VGA_drawStringBold(int x, int y, char* str, short color, short bg, char font_size) {
	int cursor_x = x, cursor_y = y;
	
	while(*str) {
		if(*str == '\n') {
			// wrap the text to a new line
			cursor_x = x;
			cursor_y += 8*font_size;
			if(cursor_y >= HEIGHT - font_size*8)
				return;
		}
		else if (*str == '\t') {
			cursor_x += 6*TAP_SPACE*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*6) {
				cursor_x = x;
				cursor_y += 8*font_size;
				if(cursor_y >= HEIGHT - font_size*8)
					return;
			}
		}
		else {
			VGA_drawChar(cursor_x, cursor_y, (unsigned char)*str, color, bg, font_size);
			VGA_drawChar(cursor_x + 1, cursor_y, (unsigned char)*str, color, bg, font_size);
			cursor_x += 6*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*6) {
				cursor_x = x;
				cursor_y += 8*font_size;
				if(cursor_y >= HEIGHT - font_size*8)
					return;
			}
		}

		str++;
	} 
}

/****************************************************************************************
 * Draw a single big char (16pixelH, 8pixelW) on the VGA monitor 
****************************************************************************************/

// c has to be unsigned char (0-255) here for correct indexing!
void VGA_drawCharBig(int x, int y, unsigned char c, short color, short bg, char size) {
	int i, j;
	unsigned char line;
	// clip the text if they are beyond the edge
	if(x >= WIDTH || (x + size*8-1) < 0 || y >= HEIGHT || (y + size*16-1) < 0)
		return;

	for(i=0; i<16; i++) {
		if(i == 16) // 16th row left blank for spacing
			line = 0x0;
		else
			line = bigFont[c*16 + i];

		for(j=0; j<8; j++) {
			if(line & 0x80) // if there is content at that pixel
				if(size == 1)
					VGA_PIXEL(x+j, y+i, color);
				else
					VGA_box(x+j*size, y+i*size, x+(j+1)*size-1, y+(i+1)*size-1, color);
			else  // no content, draw background color
				if(size == 1)
					VGA_PIXEL(x+j, y+i, bg);
				else
					VGA_box(x+j*size, y+i*size, x+(j+1)*size-1, y+(i+1)*size-1, bg);
			line <<= 1; // go to next data position
		}
	}
}

/****************************************************************************************
 * Draw a big string (16pixelH, 8pixelW) on the VGA monitor 
****************************************************************************************/

void VGA_drawStringBig(int x, int y, char* str, short color, short bg, char font_size) {
	int cursor_x = x, cursor_y = y;
	
	while(*str) {
		if(*str == '\n') {
			// wrap the text to a new line
			cursor_x = x;
			cursor_y += 16*font_size;
			if(cursor_y >= HEIGHT - font_size*16)
				return;
		}
		else if (*str == '\t') {
			cursor_x += 8*TAP_SPACE*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*8) {
				cursor_x = x;
				cursor_y += 16*font_size;
				if(cursor_y >= HEIGHT - font_size*16)
					return;
			}
		}
		else {
			VGA_drawCharBig(cursor_x, cursor_y, (unsigned char)*str, color, bg, font_size);
			cursor_x += 8*font_size;
			// wrap the text to a new line if this line is full
			if(cursor_x >= WIDTH - font_size*8) {
				cursor_x = x;
				cursor_y += 16*font_size;
				if(cursor_y >= HEIGHT - font_size*16)
					return;
			}
		}

		str++;
	} 
}

/****************************************************************************************
 * Draw a filled rectangle on the VGA monitor 
****************************************************************************************/

void VGA_box(int x1, int y1, int x2, int y2, short pixel_color)
{
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	for (row = y1; row <= y2; row++)
		for (col = x1; col <= x2; ++col)
		{
			//640x480
			//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			//*(char *)pixel_ptr = pixel_color;	
			VGA_PIXEL(col,row,pixel_color);	
		}
}

/****************************************************************************************
 * Draw a outline rectangle on the VGA monitor 
****************************************************************************************/

void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color)
{
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	// left edge
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
		
	// right edge
	col = x2;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
	
	// top edge
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);
	}
	
	// bottom edge
	row = y2;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);
	}
}

/****************************************************************************************
 * Draw a horixontal line on the VGA monitor 
****************************************************************************************/ 

void VGA_Hline(int x1, int y1, int x2, short pixel_color)
{
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (x1>x2) SWAP(x1,x2);
	// line
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
}

/****************************************************************************************
 * Draw a vertical line on the VGA monitor 
****************************************************************************************/

void VGA_Vline(int x1, int y1, int y2, short pixel_color)
{
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (y2<0) y2 = 0;
	if (y1>y2) SWAP(y1,y2);
	// line
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);			
	}
}


/****************************************************************************************
 * Draw a filled circle on the VGA monitor 
****************************************************************************************/

void VGA_disc(int x, int y, int r, short pixel_color)
{
	int row, col, rsqr, xc, yc;
	
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++)
		for (xc = -r; xc <= r; xc++)
		{
			col = xc;
			row = yc;
			// add the r to make the edge smoother
			if(col*col+row*row <= rsqr+r){
				col += x; // add the center point
				row += y; // add the center point
				//check for valid 640x480
				if (col>639) col = 639;
				if (row>479) row = 479;
				if (col<0) col = 0;
				if (row<0) row = 0;
				//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				//*(char *)pixel_ptr = pixel_color;
				VGA_PIXEL(col,row,pixel_color);	
			}
					
		}
}

/****************************************************************************************
 * Draw a  circle on the VGA monitor 
****************************************************************************************/

void VGA_circle(int x, int y, int r, int pixel_color)
{
	int row, col, rsqr, xc, yc;
	int col1, row1;
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++){
		//row = yc;
		col1 = (int)sqrt((float)(rsqr + r - yc*yc));
		// right edge
		col = col1 + x; // add the center point
		row = yc + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		col = -col1 + x; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
	for (xc = -r; xc <= r; xc++){
		//row = yc;
		row1 = (int)sqrt((float)(rsqr + r - xc*xc));
		// right edge
		col = xc + x; // add the center point
		row = row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		row = -row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
}

// =============================================
// === Draw a line
// =============================================
//plot a line 
//at x1,y1 to x2,y2 with color 
//Code is from David Rodgers,
//"Procedural Elements of Computer Graphics",1985
void VGA_line(int x1, int y1, int x2, int y2, short c) {
	int e;
	signed int dx,dy,j, temp;
	signed int s1,s2, xchange;
    signed int x,y;
	
	/* check and fix line coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
        
	x = x1;
	y = y1;
	
	//take absolute value
	if (x2 < x1) {
		dx = x1 - x2;
		s1 = -1;
	}

	else if (x2 == x1) {
		dx = 0;
		s1 = 0;
	}

	else {
		dx = x2 - x1;
		s1 = 1;
	}

	if (y2 < y1) {
		dy = y1 - y2;
		s2 = -1;
	}

	else if (y2 == y1) {
		dy = 0;
		s2 = 0;
	}

	else {
		dy = y2 - y1;
		s2 = 1;
	}

	xchange = 0;   

	if (dy>dx) {
		temp = dx;
		dx = dy;
		dy = temp;
		xchange = 1;
	} 

	e = ((int)dy<<1) - dx;  
	 
	for (j=0; j<=dx; j++) {
		//video_pt(x,y,c); //640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		//*(char *)pixel_ptr = c;
		VGA_PIXEL(x,y,c);			
		 
		if (e>=0) {
			if (xchange==1) x = x + s1;
			else y = y + s2;
			e = e - ((int)dx<<1);
		}

		if (xchange==1) y = y + s2;
		else x = x + s1;

		e = e + ((int)dy<<1);
	}
}