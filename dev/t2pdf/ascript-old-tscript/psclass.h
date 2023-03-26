#ifndef PSCLASS_H
#define PSCLASS_H

#ifdef EXTERN
#undef EXTERN
#endif


#include <tbrowde.h>
#include "genque.hpp"

#define NO_ARROW   0
#define ONE_ARROW  1
#define TWO_ARROWS 2

enum orientation_t // position of desired start print point w.r.t. word bounding box (bb)
{
  C  = 0,  // center
  CL = 1,  // center of left side
  LL = 2,  // lower left corner
  CB = 3,  // center of bottom side
  LR = 4,  // lower right corner
  CR = 5,  // center of right side
  UR = 6,  // upper right corner
  CT = 7,  // center of top side
  UL = 8,  // upper left corner
  BL = 9,  // left side on baseline
  BC = 10, // centered on baseline
  BR = 11  // right side on baseline
};

enum PAGE_t 
{
  PORTRAIT,
  LANDSCAPE
};

// all page parameters are based on a standard portrait-oriented document using
// 8.5" X 11" paper
#define POINTS_PER_INCH (72.)
#define PPI POINTS_PER_INCH
#define EVEN_LEFT_MARGIN_WIDTH  (1.50 * PPI)
#define EVEN_RIGHT_MARGIN_WIDTH (1.25 * PPI)
#define ODD_LEFT_MARGIN_WIDTH EVEN_RIGHT_MARGIN_WIDTH
#define ODD_RIGHT_MARGIN_WIDTH EVEN_LEFT_MARGIN_WIDTH
#define TOP_MARGIN_WIDTH  (1.0 * PPI)
#define BOTTOM_MARGIN_WIDTH  (1.0 * PPI)
#define LANDSCAPE_PAGE_WIDTH (11. * PPI)
#define LANDSCAPE_PAGE_HEIGHT (8.5 * PPI)
#define PORTRAIT_PAGE_HEIGHT LANDSCAPE_PAGE_WIDTH
#define PORTRAIT_PAGE_WIDTH LANDSCAPE_PAGE_HEIGHT
#define HEAD_BASELINE (0.5 * PPI)
#define FOOT_BASELINE (0.5 * PPI)
#define PAGE_NUM_BASELINE (0.5 * PPI)

// global page and text parameters
#ifdef PSCLASS_CPP
char *FONT_NAME = "Times-Roman";
double FONT_SIZE = 12.; // points
double CONNECTOR_WIDTH_RATIO = 0.1;
double UNDERLINE_WIDTH_RATIO = 0.1;
double UNDERLINE_OFFSET_RATIO = 0.1;
double CONNECTOR_LINE_WIDTH = 1.;
double LINE_WIDTH = 1.;
double BORDER_WIDTH = 1.;
double BORDER_LINE_WIDTH = 1.;
#else
extern char *FONT_NAME;
extern double FONT_SIZE; // points
extern double CONNECTOR_WIDTH_RATIO;
extern double UNDERLINE_WIDTH_RATIO;
extern double UNDERLINE_OFFSET_RATIO;
extern double CONNECTOR_LINE_WIDTH;
extern double LINE_WIDTH;
extern double BORDER_WIDTH;
extern double BORDER_LINE_WIDTH;
#endif

  
class ps_word
{
public:
  // constructor
  ps_word();
  ps_word(char *text, 
	  char *font_name = FONT_NAME, 
	  double font_size = FONT_SIZE,
	  double underline_width_ratio = UNDERLINE_WIDTH_RATIO,
	  double underline_offset_ratio = UNDERLINE_OFFSET_RATIO,
	  bool underline = FALSE
	  );
  // destructor
  ~ps_word();

public:
  double xll, yll, xur, yur;
  double width;
  char *string;
  bool underline;
  double underline_offset_y;
  double underline_width;
  int font_id;
  int len;
  double font_size;
};

class ps_line
{
public:
  // constructor
  ps_line();
  
public:
  double xll, yll, xur, yur;
  double width;
  double max_font_size;
  genq *ps_word_q;
};

class ps_paragraph
{
public:
  // constructor
  ps_paragraph(genq *ps_word_q,
	       bool border = FALSE,
	       double line_width = LINE_WIDTH,
	       double border_width = BORDER_WIDTH,
	       double border_line_width = BORDER_LINE_WIDTH
	       );
  ps_paragraph();

  void setup(double max_line_width);
  void show(FILE *fp,
	    double max_line_width,
	    double x, 
	    double y, 
	    orientation_t = CT
	    );
  
public:
  double xll, yll, xur, yur;
  genq *ps_line_q;
};

class ps_connector_line
{
public:
  // constructor
  ps_connector_line(int arrow = NO_ARROW, // ONE_ARROW, TWO_ARROWS 
		    double connector_line_width = CONNECTOR_LINE_WIDTH
		    );
  
  void show(double fromx, 
       double fromy, 
       double to_x,
       double to_y
       );
  
public:
  double xll, yll, xur, yur;
};

class ps_connector_box
{
public:
  // constructor
  ps_connector_box(char *tag,
		   orientation_t orientation = CT
		   );
  
  show(double x, 
       double y, 
       orientation_t = CT
       );
  
public:
  double xll, yll, xur, yur;
};


class ps_page
{
public:
  // constructor
  ps_page(genq *ps_objects_q,
	  int page_num,
	  char *classification
	  );

  void setup(int page_num, PAGE_t pagetype);
  void show(void);
  
public:
  double left_margin;
  double right_margin;
  double top_margin;
  double bottom_margin;
  double page_width;
  double page_height;
  double text_width;
  double text_height;
  double hcenter;
};

void xy_print_start(XY_t ref, CHARMETRICS_t box, orientation_t orient, XY_t *start);

#endif // PSCLASS_H
