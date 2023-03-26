#define DEBUG

/* this is Tom Browder's version of "enscript." It was developed without
 * any reference to the internals of the original program.
 */

#include <cstdio>
#include <string>
#include <cstdlib>
#include <tbrowde2.h>

using namespace std;

/*
#define I2P (72.)
#define IN2PT    (72.)
#define CHARWIDTH (.6)
#define FF "<FF>"
#define FF2 "<ff>"
#define TABS 8
#define MAXCHAR 80
*/
const double I2P(72.);
const double IN2PT(72.);
const double CHARWIDTH(.6);
const string FF("<FF>");
const string FF2("<ff>");
const int TABS(8);

//char fontname[MAXCHAR + 1];
//char tmp_buf[MAXCHAR + 1];
//char buf[MAXCHAR + 1];
string fontname;
string tmp_buf;
string buf;

int tmp_buf_start = 0;
double max_line_length;
bool header_flag = true;
bool rotate_flag = false;
bool font_flag = false;
bool file_flag = false;
bool page_flag = false;
bool mono_flag = true;
bool form_feed = false;
bool line_number_flag = false;
bool wrap_flag;
bool line_wrap = true;

const char default_font[] = "Courier";
double font_size = 7.;
double font_width = 4.2;
double char_width = 4.2;

char *cptr;
int linenum = 0;

typedef
struct line_t {
  struct line_t *prev;
  struct line_t *next;
  char *line;
} LINE_t;

struct portrait_t
  {
    double xll;
    double yll;
    double xur;
    double yur;
  }
portrait;

struct landscape_t
  {
    double xll;
    double yll;
    double xur;
    double yur;
  }
landscape;

double xll, yll, xur, yur;
double vpos;
int page_num = 1;
int max_lines;
int num_lines_wrapped = 0;
int tabspaces = TABS;
int line_number = 0;

double left_margin   = 1.;
double right_margin  = 1.;
double top_margin    = 1.;
double bottom_margin = 1.;
double page_top;
double page_left;
bool word_process = false;

//char infile[200], outfile[200], outfile_full[200], date_string[100];
string infile, outfile, outfile_full, date_string;

/*
void do_word_process();
int get_word_process_command(FILE *fp);
*/

int
main (int argc, char **argv)
{
  int len, spaces;
  FILE *fp_in, *fp_out, *fp_tmp;

  //char infile[200], outfile[200], outfile_full[200], date_string[100];
  //char hostname[100];
  string infile, outfile, outfile_full, date_string;
  string hostname;

  double vsize, hsize;
  int chars_per_line;
  int font_id;
  double current_line_length;

  int version = 300;

  if (argc == 1) {
    printf("tscript, version %4.2f; converts ASCII text file to PostScript\n", (double)(version /100.));
    printf("  Usage: tscript [options] file (use -h option for extended help)\n");
    printf("  Defaults are: 7 point Courier font; portrait; 1\" margins;\n");
    printf("    a header line with file information, date, and page number; and\n");
    printf("    the output file name is the input file name with \".ps\" appended.\n");
    printf("  Lines are wrapped if they exceed the allowable line length and\n");
    printf("    the continuation lines are marked with a leading '>'.\n");
    printf("  Note: 10 point Courier will allow 80 characters on a line with\n");
    printf("    the default margins.\n");
    exit (0);
  }

  for (int i = 1; i < argc; ++i) {
#ifdef DEBUG2
    dPRINT(i);
    sPRINT(argv[i]);
#endif

    string arg(argv[i]);
    string val("");

    int idx = arg.index('=');
    if (idx != string::npos) {
      val = arg.substr(idx+1);
    }

    if (arg == "-h") {
      printf("tscript options:\n");
      printf("  -h extended help\n");
      printf("  -F list font names\n");
      printf("  -B omit header (file name, date, and page number)\n");
      printf("  -r rotate (landscape, default is portrait)\n");
      printf("  -o=<output file name>\n");
      printf("  -n print line numbers (up to 99,999)\n");
      printf("  -t=<number of spaces per tab> (8 is default)\n");
      printf("  -f=<font name> (see the -F option)\n");
      printf("  -L omit line wrap\n");
      printf("  -p=<font point size>\n");
      printf("  -LM=<left margin> (in inches)\n");
      printf("  -RM=<right margin> (in inches)\n");
      printf("  -TM=<top margin> (in inches)\n");
      printf("  -BM=<bottom margin> (in inches)\n");
      printf("  -w  word processor (see Tom Browder)\n");

      exit (1);
    }
    else if (arg == "-w") {
	word_process = true;
    }
    else if (arg == "-F") {
      printf("tscript font names:\n");
      /* 	  printf("  Times-Roman\n"); */
      /* 	  printf("  Times-Bold\n"); */
      /* 	  printf("  Times-Italic\n"); */
      /* 	  printf("  Times-BoldItalic\n"); */

      /* 	  printf("  Helvetica\n"); */
      /* 	  printf("  Helvetica-Bold\n"); */
      /* 	  printf("  Helvetica-Oblique\n"); */
      /* 	  printf("  Helvetica-BoldOblique\n"); */

      printf("  Courier (fixed-space, default)\n");
      /* 	  printf("  Courier-Bold\n"); */
      /* 	  printf("  Courier-Oblique\n"); */
      /* 	  printf("  Courier-BoldOblique\n"); */

      exit(1);
    }
    else if (arg == "-LM") {
      left_margin = atoi(val.c_str);
    }
    else if (argv == "-RM") {
      right_margin = atoi(val.c_str);
    }
    else if (arg == "-TM") {
      top_margin = atoi(val.c_str);
    }
    else if (arg == "-BM") {
      bottom_margin = atoi(val.c_str);
    }
    else if (arg == "-f") {
      font_flag = true;
      fontname = val;
      font_width = 0.6 * font_size; /* temporary fix -- Courier only */
      char_width = 0.6 * font_size; /* temporary fix -- Courier only */
    }
    else if (arg == "-p") {
      font_size = atoi(val.c_str);
    }
    else if (arg == "-o") {
      file_flag = true;
      outfile = val;
    }
    else if (arg == "-t") {
      tabspaces = atoi(val.c_str);
    }
    else if (arg == "-B") {
      header_flag = false;
    }
    else if (arg == "-r") {
      rotate_flag = true;
    }
    else if (arg == "-L") {
      line_wrap = false;
    }
    else if (arg == "-n") {
      line_number_flag = true;
      tmp_buf_start = 6;	/* allows 5 spaces for line number plus trailing space*/
    }
    else if (i == argc - 1) {
      if (argv[i][0] == '-')
	tmb::exit_msg("Last argument must be a file name, it cannot begin with a hyphen.");
      strcpy (infile, argv[i]);	/* last arg - default for now */
      if (file_flag == false) {
	strcpy (outfile, argv[i]);
	strcat (outfile, ".ps");
	file_flag = true;
      }
    }
    else {
      tmb::exit_msg ("Unknown option.");
    }
  }

  /* defaults */
  /* original:
     portrait.xll =   1.  * IN2PT;
     portrait.yll =   1.  * IN2PT;
     portrait.xur =   7.5 * IN2PT;
     portrait.yur =  10.  * IN2PT;

     landscape.xll =  0.4 * IN2PT;
     landscape.yll =  0.4 * IN2PT;
     landscape.xur = 10.6 * IN2PT;
     landscape.yur =  7.5 * IN2PT;
  */

  portrait.xll =   left_margin  * IN2PT;
  portrait.yll =   bottom_margin  * IN2PT;
  portrait.xur =   8.5 * IN2PT - right_margin * IN2PT;
  portrait.yur =  11.  * IN2PT - top_margin * IN2PT;

  landscape.xll =  left_margin  * IN2PT;
  landscape.yll =  bottom_margin  * IN2PT;
  landscape.xur = 11. * IN2PT - right_margin * IN2PT;
  landscape.yur =  8.5  * IN2PT - top_margin * IN2PT;


  /* original
     if (line_number_flag == true && rotate_flag == false)
     {
     portrait.xll = .4 * IN2PT;
     portrait.yll = .4 * IN2PT;
     portrait.xur = 8.1 * IN2PT;
     portrait.yur = 10. * IN2PT;
     }
  */

  if (rotate_flag == false) {
    page_top = 11.0 * IN2PT;
    page_left = portrait.xll;
  }
  else {
    page_top = 8.5 * IN2PT;
    page_left = landscape.xll;
  }

  /* get hostname */
  system("hostname > tscript.tmp\n");
  fp_tmp = fopen("tscript.tmp", "r");
  fgets(hostname, MAXCHAR, fp_tmp);
  fclose(fp_tmp);
  tmb::trim(hostname, false);
  system("rm tscript.tmp\n");


  /* get directory name for complete infile name, but only if we KNOW a
     local file name was used */
  if ((strchr (outfile, '/')) == NULL) {
    system ("pwd > tscript.tmp\n");
    fp_tmp = fopen ("tscript.tmp", "r");
    fgets (outfile_full, MAXCHAR, fp_tmp);
    if ((cptr = strchr (outfile_full, '\n')) != NULL) {
      cptr[0] = '\0';
    }
    strcat (outfile_full, "/");
    strcat (outfile_full, outfile);
    fclose (fp_tmp);
    system ("rm tscript.tmp\n");
  }
  else {
    strcpy (outfile_full, outfile);
  }

  trim_string(outfile_full, false);

  /* get system date */
  system ("date > tscript.tmp\n");
  fp_tmp = fopen ("tscript.tmp", "r");
  fgets (date_string, MAXCHAR, fp_tmp);
  trim_string(date_string, false);
  fclose (fp_tmp);
  system ("rm tscript.tmp\n");

  /*
    if (word_process == true)
    do_word_process();
  */

  // no more below this point if word processing

  if (font_flag == false)
    strcpy (fontname, default_font);
  char_width = font_size * CHARWIDTH;

  /* allow space for line numbers */
  /*   if (line_number_flag == true) */
  /*     { */
  /*       portrait.xll  -= 6 * char_width;  */
  /*       landscape.xll -= 6 * char_width; */
  /*     } */

  /* adjust for 1 more character to allow for continuation character */
  if (line_number_flag == false) {
    portrait.xll  -= 1 * char_width;
    landscape.xll -= 1 * char_width;
  }

  tmb::font_id = get_font_id (fontname);

  if ((fp_in = FopenRead (infile)) == NULL)
    exit_msg ("Unable to open input file.");
  fp_out = fopen (outfile, "w");

  fprintf(fp_out, "%%!\n");

  /* prologue, if any, and outer save */
  fprintf(fp_out, "%%STARTDOCUMENT\n");
  fprintf(fp_out, "save\n");

  /* setup page format */

  if (rotate_flag == true){
    fprintf(fp_out, "%.4f %.4f translate\n", 8.5 * IN2PT, 0.);
    fprintf(fp_out, "90 rotate\n");
    xll = landscape.xll;
    yll = landscape.yll;
    xur = landscape.xur;
    yur = landscape.yur;
    vsize = yur - yll;
    hsize = xur - xll;
  }
  else {
    xll = portrait.xll;
    yll = portrait.yll;
    xur = portrait.xur;
    yur = portrait.yur;
    vsize = yur - yll;
    hsize = xur - xll;
  }
  chars_per_line = (int) (hsize / char_width) + 1; /* adjust to get 80 chars per line for 10 pt Courier */
  max_line_length = hsize + 1 * char_width;
  if (line_number_flag == true) max_line_length += 6 * char_width;
  else max_line_length += 1 * char_width;

  /* set up font */
  fprintf(fp_out, "/%s findfont\n", fontname);
  fprintf(fp_out, "%.4f scalefont\n", font_size);
  fprintf(fp_out, "setfont\n");

  vpos = yur;

  /* start pages */
  fprintf(fp_out, "%%STARTPAGE\n");
  fprintf(fp_out, "save\n");

  if (header_flag == true) {
    fprintf(fp_out, "gsave\n");
    fprintf(fp_out, "/%s findfont\n", "Courier-Bold");
    fprintf(fp_out, "%d scalefont\n", 7);
    fprintf(fp_out, "setfont\n");

    fprintf(fp_out, "%.4f %.4f moveto\n", page_left, page_top - .4 * IN2PT);
    fprintf(fp_out, "(File: %s:%s      Page: %d) show\n",
	    hostname.c_str, outfile_full.c_str, page_num++);
    fprintf(fp_out, "%.4f %.4f moveto\n", page_left, page_top - .4 * IN2PT - 7.);
    fprintf(fp_out, "(Date: %s) show\n",
	    date_string.c_str);

    fprintf(fp_out, "grestore\n");
  }

  // need a readline idiom here
  while ((fgets(buf, MAXCHAR, fp_in)) != NULL) {
    wrap_flag = false;
    cptr = &buf[0];
    if (line_number_flag == true && strstr (cptr, "/* END_PRINT */") != NULL)
      break;
    ++line_number;		/* for line numbering option (-n) */
    trim_string_end (cptr, false);
    vpos -= font_size;
    if (strstr (cptr, FF) || strstr(cptr, FF2) != NULL)
      form_feed = true;
    tmp_buf[0] = ' ';
  WRAP_LINE:
    if (vpos < yll || form_feed == true) {
      fprintf(fp_out, "showpage\n");
      fprintf(fp_out, "restore\n");
      fprintf(fp_out, "%%ENDPAGE\n");

      fprintf(fp_out, "%%STARTPAGE\n");
      fprintf(fp_out, "save\n");
      /*
	if ( rotate_flag == true )
	{
	fprintf( fp_out, "%.4f %.4f translate\n", 8.5 * IN2PT, 0. );
	fprintf( fp_out, "90 rotate\n" );
	}
      */
      if (header_flag == true) {
	fprintf(fp_out, "gsave\n");
	fprintf(fp_out, "/%s findfont\n", "Courier-Bold");
	fprintf(fp_out, "%d scalefont\n", 7);
	fprintf(fp_out, "setfont\n");

	fprintf(fp_out, "%.4f %.4f moveto\n", page_left, page_top - .4 * IN2PT);
	fprintf(fp_out, "(File: %s:%s      Page: %d) show\n",
		 hostname.c_str, outfile_full.c_str, page_num++);
	fprintf(fp_out, "%.4f %.4f moveto\n", page_left, page_top - .4 * IN2PT - 7.);
	fprintf(fp_out, "(Date: %s) show\n",
		 date_string.c_str);

	fprintf(fp_out, "grestore\n");
      }
      vpos = yur - font_size;
      linenum = 0;
      form_feed = false;
      if ((strstr (cptr, FF)) != NULL)
	continue;		/* don't print FF symbol */
    }
    ++linenum;
    fprintf(fp_out, "%.4f %.4f moveto\n", xll, vpos);

    /* set up output line -- protect parentheses, replace tabs, etc. */
    len = strlen (cptr);
    if (line_number_flag == false)
      current_line_length = 1 * char_width;
    else if (line_number_flag == true) {
      if (wrap_flag == false)
	sprintf(&tmp_buf[1], "%5d ", line_number);
      /*                  current_line_length += 6 * get_char_width( font_id, ' ' ); */
      else
	sprintf(&tmp_buf[1], "     >");
      current_line_length = 6 * char_width; /* temp fix -- Courier only */
    }

    // reading char by char
    for (int i = 0, j = tmp_buf_start + 1; i < len; ++i) { /* save 0 char for continuation line flag */
      if (cptr[i] == '\t') {
	spaces = tabspaces - (i % tabspaces);
	for (int k = 0; k < spaces; ++k) {
	  tmp_buf[j] = ' ';
	  ++j;
	  /* current_line_length += get_char_width( font_id, ' ' ); */
	  current_line_length += char_width; /* temp fix -- Courier only */
	  if (line_wrap == true && current_line_length >= max_line_length) {
	    tmp_buf[j] = '\0';
	    fprintf(fp_out, "(%s) show\n", tmp_buf);
	    cptr += i + 1; /* i hasn't been incremented yet */
	    if (line_number_flag == false) tmp_buf[0] = '>';
	    vpos -= font_size;
	    wrap_flag = true;
	    goto WRAP_LINE;
	  }
	}
	continue;
      }
      if (cptr[i] == '(' || cptr[i] == ')' || cptr[i] == '\\') {
	tmp_buf[j] = '\\';
	++j;
      }
      tmp_buf[j] = cptr[i];
      ++j;

      /* current_line_length += get_char_width( font_id, ' ' ); */
      current_line_length += char_width; /* temp fix -- Courier only */
      if (line_wrap == true && current_line_length >= max_line_length) {
	tmp_buf[j] = '\0';
	fprintf(fp_out, "(%s) show\n", tmp_buf);
	cptr += i + 1; /* i hasn't been incremented yet */
	if (line_number_flag == false) tmp_buf[0] = '>';
	vpos -= font_size;
	wrap_flag = true;
	goto WRAP_LINE;
      }
    }
    tmp_buf[j] = '\0';
    fprintf(fp_out, "(%s) show\n", tmp_buf);
  }

  fprintf(fp_out, "showpage\n");
  fprintf(fp_out, "restore\n");
  fprintf(fp_out, "%%ENDPAGE\n");

  fprintf(fp_out, "restore\n");
  fprintf(fp_out, "%%ENDDOCUMENT\n");

  fprintf(fp_out, "%%EOF\n");

} // end of main function

// all below here is turned off at the moment
// END CURRENT CODE

/* static global wp variables */
/*
  enum {PORTRAIT, LANDSCAPE};
  static double tab[20];
  double page_height;
  double page_width;
  double page_orientation = PORTRAIT;
  double LM;
  double TM;
  double RM;
  double BM;

  void
  do_word_process() {
  FILE *fp = FopenRead(infile);
  int c, numc;
  char *linebuf = new char[MAXBUF+1];
  bool in_para, in_space, in_word;

  // set defaults
  enum orient { PORTRAIT, LANDSCAPE };

  int page_orient = PORTRAIT;
  char *font = "/Times-Roman";
  double scale = 12.;
  LINE_t *para, *para_head;

  if ((c = fgetc(fp)) == EOF)
    exit_msg("Premature EOF in input file.");
  numc = 1;
  int i = 0;

  bool new_line = false;
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
	      c = get_word_process_command(fp);
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

int get_word_process_command(FILE *fp)
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
    trim_string(buf, CHOP);

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
	new_line = true;
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
	RM = page_width - RM * I2P;
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
	TM = page_height - TM * I2P;
      }




    // return next c
    return fgetc(fp);
  }

void set_page(int page_orientation)
  {
    if (page_orientation == PORTRAIT)
      {
	page_height = 11. * I2P;
	page_width = 8.5. * I2P;
      }
    else
      {
	page_height = 8.5 * I2P;
	page_width = 11. * I2P;
      }

    // set default margins

    LM = 1. * I2P;
    TM = 1. * I2P;
    RM = 1. * I2P;
    BM = 1. * I2P;

    TM = page_height - TM;
    RM = page_width - RM;
  }
*/
