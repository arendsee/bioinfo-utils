#!/usr/bin/env Rscript

require(data.table, quiet=TRUE)
require(plyr, quiet=TRUE)

version <- '0.1'

suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser(
  formatter_class='argparse.RawTextHelpFormatter',
  description='Summarize the columns in a tab delimited file',
  usage='sumtab [options]'
)

parser$add_argument(
  '-v', '--version',
  action='store_true',
  default=FALSE
)

parser$add_argument(
  '-d' , '--header',
  help='Does the file have a header?',
  action='store_true',
  default=FALSE
)

parser$add_argument(
  '-c' , '--comment-char',
  help='Comment character (none by default)',
  default=''
)

parser$add_argument(
  'file',
  help='tabular file to be parsed'
)

args <- parser$parse_args()

if(args$version){
  cat(sprintf('rstab v%s\n', version))
  q()
}

# emulate C printf
printf <- function(format, ...){
  cat(sprintf(format, ...))
}

print_column <- function(x, name){
  printf("%s %s\n", name, class(x))
  if(class(x) == 'factor'){
    printf("\tnlevels=%s missing=%s\n", length(unique(x)), sum(is.na(x)))
  } else if(class(x) == 'integer') {
    printf("\tfivenum=(%s) median=%s missing=%s\n",
      paste0(fivenum(x), collapse=', '),
      median(x, na.rm=TRUE),
      sum(is.na(x))
    )
  } else {
    printf("\tfivenum=(%s) mean=%s(%s) missing=%s\n",
      paste0(signif(fivenum(x), 3), collapse=', '),
      signif(mean(x, na.rm=TRUE), 3),
      signif(sd(x, na.rm=TRUE), 3),
      sum(is.na(x))
    )
  }
}

d <- read.delim(args$file, header=args$header, comment.char=args$comment_char)

printf("nrows=%d ncol=%d\n", nrow(d), ncol(d))
a <- lapply(1:ncol(d), function(i) print_column(d[[i]], names(d)[i]))
