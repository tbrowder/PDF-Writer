unit module WordProcessing;

# this is the word processin chunk from the original tscript:


=begin comment
/* static global wp variables */
/*
  enum {PORTRAIT, LANDSCAPE};
  static double tab[20];
  double page-height;
  double page-width;
  double page-orientation = PORTRAIT;
  double LM;
  double TM;
  double RM;
  double BM;

  void
  do_word-process() {
  FILE *fp = FopenRead(infile);
  int c, numc;
  char *linebuf = new char[MAXBUF+1];
  bool in_para, in_space, in_word;

  // set defaults
  enum orient { PORTRAIT, LANDSCAPE };

  int page-orient = PORTRAIT;
  char *font = "/Times-Roman";
  double scale = 12.;
  LINE_t *para, *para_head;

  if ((c = fgetc(fp)) == EOF)
    exit_msg("Premature EOF in input file.");
  numc = 1;
  int i = 0;

  bool new-line = false;
  in_word = false;
  in_para = true;
  in_space = false;

NEW_PARA:

  while (c != EOF && in_para == true)
    {
      // begin a line
      if (c == '.')
	{
	  if (c == '{')
	    {
	      c = get_word-process_command(fp);
	    }
	  else
	    fputc(c, fp);
	}
      else if (c == EOF)
	continue;
      else if (c == '\n')
	{
	  if (c == '\n')
	    {
	      in_para = false;
	    }
	  else
	    fputc(c, fp);
	}

      if (isspace(c))
	{
	  if (in_word)
	    buf[i++] = c;
	  in_space = true;
	  in_word = false;
	}
      else
	{
	  in_word = true;
	  buf[i++] = c;
	}
    }
  buf[i] = '\0';


  cptr = strtok(linebuf, " ");
  while (cptr != NULL)
    {
      if (strstr(cptr, ".{") != NULL)
	{
	      // isolate the wp token
	  //	      if (cptr[
	}

    }

}

int get_word-process_command(FILE *fp)
//
//   The fp stream as presented has already had the '.{' removed
//   and assumes the stream up until the next '}' contains word processing
//   commands. The function MUST return the next int in the stream following
//   the closing '}'.
//
  {
    int i, c, tnum;
    char buf[100];
    bool new_para;
    double xref, ttab;

    while (c != '}' && c != EOF)
      {
	buf[i++] = c;
	c = fgetc(fp);
      }
    if (c == EOF)
      return c;


    buf[i] = '\0';
    trim-string(buf, CHOP);

    c = buf[0];

    // now interpret
    if (c == 'p')
      // new para
      {
	new_para = true;
      }
    else if (c == 'd')
      // define tab
      {
	sscanf(&buf[1], "%d %lf", &tnum, &ttab);
	tab[tnum] = ttab * I2P;
      }
    else if (c == 't')
      // use tab
      {
	sscanf(&buf[1], "%d", &tnum);
	xref = LM + tab[tnum];
      }
    else if (c == 's')
      // set tab
      {
	sscanf(&buf[1], "%lf", &ttab);
	xref = LM + ttab * I2P;
      }
    else if (c == 'f')
      // define font
      {
	sscanf(&buf[1], "%s", font);
      }
    else if (c == 'n')
      // newline
      {
	new-line = true;
      }
    else if (c == 'j')
      // justify
      {
	sscanf(&buf[1], "%c", justify);
	if (justify = 'R')
	  orient = RJ;
	else if (justify = 'L')
	  orient = LJ;
	else if (justify = 'C')
	  orient = CJ;
	else if (justify = '2')
	  orient = RJ2;
      }
    else if (c == 'S')
      // scale
      {
	sscanf(&buf[1], "%lf", &scale);
      }
    else if (c == 'L')
      // scale
      {
	sscanf(&buf[1], "%lf", &LM);
	LM *= I2P;
      }
    else if (c == 'R')
      // scale
      {
	sscanf(&buf[1], "%lf", &RM);
	RM = page-width - RM * I2P;
      }
    else if (c == 'B')
      // scale
      {
	sscanf(&buf[1], "%lf", &BM);
	BM *= I2P;
      }
    else if (c == 'T')
      // scale
      {
	sscanf(&buf[1], "%lf", &TM);
	TM = page-height - TM * I2P;
      }




    // return next c
    return fgetc(fp);
  }

void set_page(int page-orientation)
  {
    if (page-orientation == PORTRAIT)
      {
	page-height = 11. * I2P;
	page-width = 8.5. * I2P;
      }
    else
      {
	page-height = 8.5 * I2P;
	page-width = 11. * I2P;
      }

    // set default margins

    LM = 1. * I2P;
    TM = 1. * I2P;
    RM = 1. * I2P;
    BM = 1. * I2P;

    TM = page-height - TM;
    RM = page-width - RM;
  }
*/

=end comment
