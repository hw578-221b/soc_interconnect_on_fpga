// 16-bit primary colors
// R bits 11-15 mask 0xf800
// G bits 5-10  mask 0x07e0
// B bits 0-4   mask 0x001f
// so color = B+(G<<5)+(R<<11);
#define red  (0+(0<<5)+(31<<11))
#define dark_red (0+(0<<5)+(15<<11))
#define green (0+(63<<5)+(0<<11))
#define dark_green (0+(31<<5)+(0<<11))
#define blue (31+(0<<5)+(0<<11))
#define dark_blue (15+(0<<5)+(0<<11))
#define yellow (0+(63<<5)+(31<<11))
#define cyan (31+(63<<5)+(0<<11))
#define magenta (31+(0<<5)+(31<<11))
#define black (0x0000)
#define gray (15+(31<<5)+(51<<11))
#define white (0xffff)
//int colors[] = {red, dark_red, green, dark_green, blue, dark_blue, yellow, cyan, magenta, gray, black, white};

#define WIDTH 640
#define HEIGHT 480
#define TAP_SPACE 4

// graphics primitives
void VGA_init(volatile unsigned int* pixel_ptr, volatile unsigned int* char_ptr);
void VGA_drawChar(int x, int y, unsigned char c, short color, short bg, char size);
void VGA_drawString(int x, int y, char* str, short color, short bg, char font_size);
void VGA_drawStringBold(int x, int y, char* str, short color, short bg, char font_size);
void VGA_drawCharBig(int x, int y, unsigned char c, short color, short bg, char size);
void VGA_drawStringBig(int x, int y, char* str, short color, short bg, char font_size);
void VGA_text(int x, int y, char* text_ptr);
void VGA_text_clear(void);
void VGA_box(int x1, int y1, int x2, int y2, short pixel_color);
void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color);
void VGA_line(int x1, int y1, int x2, int y2, short pixel_color);
void VGA_Vline(int x1, int y1, int y2, short pixel_color);
void VGA_Hline(int x1, int y1, int x2, short pixel_color);
void VGA_disc(int x, int y, int r, short pixel_color);
void VGA_circle(int x, int y, int r, int pixel_color);