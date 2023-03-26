#define PSCLASS_CPP

#include <tbrowde.h>
#include "psclass.h"

ps_word::ps_word()
{
  string = NULL;
}

ps_word::ps_word(char *text, 
                char *font_name, 
                double font_size,
                double underline_width_ratio,
                double underline_offset_ratio,
                bool underline
               )
{
  int i;
  CHARMETRICS_t char_metrics;
  
  width = xll = yll = xur = yur = 0.;
  len = strlen(text);
  string = new char[len + 1];
  memcpy(string, text, len + 1);
  font_id = get_font_id(font_name);
  font_size = font_size;
  underline = underline;
  
  for (i = 0; i < len; i++)
    {
      get_char_metrics(font_id, font_size, string[i], &char_metrics);
      xur = width + char_metrics.xur;
      width += char_metrics.width;
      if (i == 0) 
	{
	  xll = char_metrics.xll;
	} 
      if (char_metrics.yll < yll)
	{
	  yll = char_metrics.yll;
	}
      if (char_metrics.yur > yur)
	{
	  yur = char_metrics.yur;
	}
      
      underline_offset_y = -1. * underline_offset_ratio * font_size;
      underline_width = underline_width_ratio * font_size;
    }
}

ps_word::~ps_word()
{
  if (string)
    delete (string);
}

ps_line::ps_line()
{
  xll = yll = xur = yur = 0.;
  width = 0.;
  ps_word_q = NULL;
}

ps_paragraph::ps_paragraph(
			   genq *word_q,
			   bool border,
			   double line_width,
			   double border_width,
			   double border_line_width
			   )
{
  ps_word_q = word_q;
}

void ps_page::setup(int page_num, PAGE_t pagetype)
{
  // all resulting measurements are in an x-y system of PostScript points
  // with the origin in the lower-left corner of the page
  // (the parameters head_baseline, foot_baseline, and page_num_baseline are always
  // positioned based on portrait orientation)
  if (pagetype == PORTRAIT)
    {
      text_width = PORTRAIT_PAGE_WIDTH - EVEN_RIGHT_MARGIN_WIDTH - EVEN_LEFT_MARGIN_WIDTH;
      text_height = PORTRAIT_PAGE_HEIGHT - TOP_MARGIN_WIDTH - BOTTOM_MARGIN_WIDTH;
      top_margin = PORTRAIT_PAGE_HEIGHT - TOP_MARGIN_WIDTH;
      bottom_margin = BOTTOM_MARGIN_WIDTH;
      if(odd(page_num))
	{
	  left_margin = ODD_LEFT_MARGIN_WIDTH;
	  right_margin = PORTRAIT_PAGE_WIDTH - ODD_RIGHT_MARGIN_WIDTH;
	}
      else
	{
	  left_margin = EVEN_LEFT_MARGIN_WIDTH;
	  right_margin = PORTRAIT_PAGE_WIDTH - EVEN_RIGHT_MARGIN_WIDTH;
	}
    }
  else // landscape
    {
      text_width = LANDSCAPE_PAGE_WIDTH - TOP_MARGIN_WIDTH - BOTTOM_MARGIN_WIDTH;
      text_height = LANDSCAPE_PAGE_HEIGHT - EVEN_RIGHT_MARGIN_WIDTH - EVEN_LEFT_MARGIN_WIDTH;
      left_margin = BOTTOM_MARGIN_WIDTH;
      right_margin = LANDSCAPE_PAGE_WIDTH - TOP_MARGIN_WIDTH;
      if (odd(page_num))
	{
	  top_margin = LANDSCAPE_PAGE_HEIGHT - ODD_LEFT_MARGIN_WIDTH;
	  bottom_margin = ODD_RIGHT_MARGIN_WIDTH;
	}
      else
	{
	  top_margin = LANDSCAPE_PAGE_HEIGHT - EVEN_LEFT_MARGIN_WIDTH;
	  bottom_margin = EVEN_RIGHT_MARGIN_WIDTH;
	}
    }
  hcenter = 0.5 * text_width + left_margin;
}

void ps_paragraph::show(FILE *fp,
		   double x, 
		   double y, 
		   orientation_t orientation
		   )
{
  ps_line *line;
  ps_word *word;
  XY_t ref, start;
  bool first_line = TRUE;

  ref.x = x;
  ref.y = y;
  
  line = new ps_line;
  word = new ps_word;

  while(ps_line_q->popFront(line))
    {
      // determine starting parameters
      box.xll = line->xll;
      box.yll = line->yll;
      box.xur = line->xur;
      box.yur = line->yur;
      if (first_line == FALSE)
	  ref.y -= line->max_font_size;
      xy_print_start(ref, box, orientation, &start);
      fprintf(fp, "moveto %.2f %.2f\n", start.x, start.y);
      while(line->ps_word_q->popFront(word))
	{
	  fprintf(fp, "(%s) show\n", word-string)
	}
      first_line = FALSE;
    }
}

double ps_paragraph::setup(double max_line_width)
{
  ps_word *word, *word2;
  ps_line *line;
  genq *ps_line_q;
  bool first_word = TRUE;
  bool first_line = TRUE;
  

  word = new ps_word;
  ps_line_q = new genq(sizeof(ps_line));
  line = new ps_line;

  while(ps_word_q->popFront(word))
    {
      if (first_word == FALSE)
	{
	  word2 = new ps_word(" ");
	  line->width += word2->xur - word2->xll;
	  if(line->width > max_line_width)
	    {
	      line->width -= word2->xur - word2->xll;
	      ps_line_q->pushTail(line);
	      line = new ps_line;
	      first_word = TRUE;
	    }
	  line->ps_word_q->pushTail(word2);
	  line->xur += word2->xur;
	}
      line->width += word->xur - word->xll;
      if(line->width > max_line_width)
	{
	  if (first_word == FALSE)
	    {
	      line->ps_word_q->popTail(word2);
	      line->width -= word2->xur - word2->xll;
	      line->xur += word2->xur;
	    }
	  line->width += word->xur - word->xll;
	  ps_line_q->pushTail(line);
	  line = new ps_line;
	  first_word = TRUE;
	}
      line->ps_word_q->pushTail(word);
      line->xur += word->xur;
      if (word->yll < line->yll)
	line->yll = word->yll;
      if (word->yur > line->yur)
	line->yur = word->yur;
      if (word->font_size > line->max_font_size)
	line->max_font_size = word->font_size;

      word = new ps_word;
    }
}

void xy_print_start(XY_t ref, CHARMETRICS_t box, orientation_t orient, XY_t *start)
{
  /*
     top of bbox ->    (xul,yur)           (xur,yur)
    
    
     baseline ->         (0,0)                 (0,width) (next char starts here)
    
     bottom of bbox -> (xll,yll)           (xur,yll)  
    
     (0,0) is the start point of 'show' to get the bounding box shown
     (0,width) is where the origin of the next char should be

     orientation codes:
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

     */

     double cx, cy, ox, oy, hw, hh;

     cx = 0.5 * (box.xll + box.xur);
     cy = 0.5 * (box.yll + box.yur);
     ox = -box.xll;
     oy = -box.yll;
     hw = box.xur - box.xll;
     hh = box.yur - box.yll;

     start->x = ref.x;
     start->y = ref.y;

     switch(orient)
       {
       case 0:
	 start->x -= cx;
	 start->y -= cy;
	 break;
       case 1:
	 start->x += ox;
	 start->y -= cy;
	 break;
       case 2:
	 start->x += ox;
	 start->y += oy;
	 break;
       case 3:
	 start->x -= cx;
	 start->y += oy;
	 break;
       case 4:
	 start->x -= hw + cx;
	 start->y += oy;
	 break;
       case 5:
	 start->x -= hw + cx;
	 start->y -= cy;
	 break;
       case 6:
	 start->x -= hw + cx;
	 start->y -= hh + cy;
	 break;
       case 7:
	 start->x -= cx;
	 start->y -= hh + cy;
	 break;
       case 8:
	 start->x += ox;
	 start->y -= hh + cy;
	 break;
       case 9:
	 start->x += ox;
	 break;
       case 10:
	 start->x -= cx;
	 break;
       case 11:
	 start->x -= hw + cx;
	 break;
       default:
	 start->x -= cx;
	 start->y -= cy;
	 break;
       }
}
