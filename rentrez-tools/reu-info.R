#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("argparse"))

parser <- ArgumentParser(
  description='Get info on entrez databases',
  usage='reu-info.R [options]')

parser$add_argument(
  '-v', '--version',
  action='store_true',
  default=FALSE)

suppressPackageStartupMessages(library("rentrez"))

parser$add_argument(
  '-d', '--list-databases',
  help='Print list of all supported databases',
  action='store_true',
  default=FALSE
)

parser$add_argument(
  '-s', '--summary',
  help='Print summary for given database'
)

parser$add_argument(
  '-x', '--searchable',
  help='Print the set of search terms that can be used for the given database'
)

parser$add_argument(
  '-l', '--links',
  help='Print databases that may contain links to this database'
)

args <- parser$parse_args()

if(args$version){
  cat(sprintf('rstab v%s\n', version))
  q()
}

alldb <- entrez_dbs()

if(length(args$summary) != 0){
  entrez_db_summary(args$summary)
} else if(args$list_databases){
  entrez_dbs()
} else if(length(args$searchable) != 0){
  entrez_db_searchable(args$searchable)
} else if(length(args$links) != 0){
  entrez_db_links(args$links)
} else {
  write.table(alldb, row.names=FALSE, quote=FALSE)
}
