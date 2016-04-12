#!/usr/bin/env Rscript

version <- '0.1'

suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser(
  formatter_class='argparse.RawTextHelpFormatter',
  description='Plot data from STDIN',
  usage='rplot [options]')

parser$add_argument(
  '-v', '--version',
  action='store_true',
  default=FALSE)

parser$add_argument(
  'type',
  choices=c('hist', 'point', 'box', 'plot'),
  nargs="*",
  default='hist'
)

parser$add_argument(
  '-d' , '--header',
  help='The input data has a header',
  action='store_true',
  default=FALSE
)

parser$add_argument(
  '-s' , '--sep',
  help='Table delimiter',
  default="" 
)

parser$add_argument(
  '-c' , '--comment-char',
  help='Comment character (default:none)',
  default="" 
)

args <- parser$parse_args()

if(args$version){
  cat(sprintf('rstab v%s\n', version))
  q()
}

# print help and exit if no input is given from STDIN
if(isatty(stdin())){
  parser$print_help()
  q()
}

f <- file("stdin")
open(f)

d <- read.table(f, header=args$header, sep=args$sep, comment.char=args$comment_char)

pdf('rplot-output.pdf')
if(args$type == 'point' || args$type == 'plot'){
  plot(d)  
} else {
  suppressPackageStartupMessages(require(ggplot2))
  suppressPackageStartupMessages(require(reshape2))
  g <- ggplot(melt(d))
  if(args$type == 'box'){
    g +
      geom_violin(aes(x=variable, y=value)) +
      geom_boxplot(aes(x=variable, y=value), width=0.2)
  } else if(args$type == 'hist'){
    g +
      geom_histogram(aes(x=value)) +
      facet_wrap(~variable)
  }
}
invisible(dev.off())
