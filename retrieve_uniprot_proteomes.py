#!/usr/bin/env python3

import argparse
import httplib2
import sys

__version__ = '0.0.0'
__prog__ = 'retrieve_uniprot_proteomes'

LIST_TEMPLATE = "http://www.uniprot.org/taxonomy/?query=ancestor:{}+{}&format=list"
RET_TEMPLATE  = "http://www.uniprot.org/uniprot/?query=organism:{}+{}&format=fasta&include=yes"

def positive_int(i):
    i = int(i)
    if i < 0:
         raise argparse.ArgumentTypeError("%s is an invalid positive number" % i)
    return i

def parser(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--version',
        help='Display version',
        action='version',
        version='%(prog)s {}'.format(__version__)
    )
    parser.add_argument(
        'top_taxid',
        type=positive_int,
        help='The taxon id of the ancestral node'
    )
    parser.add_argument(
        '-r', "--reference",
        help="retrieve only reference proteomes",
        action="store_true",
        default=False
    )
    parser.add_argument(
        '-d', '--download_ids',
        help="download the list of ids",
        action="store_true",
        default=False
    )
    parser.add_argument(
        '--print_http',
        help="Print all HTTP request",
        action="store_true",
        default=False
    )
    parser.add_argument(
        '-c', '--cache',
        help="Cache directory name",
        default="uniprot-cache"
    )
    args = parser.parse_args(argv)
    return(args)

def prettyprint_http(response):
    d = dict(response.items())
    for k,v in d.items():
        print("\t%s: %s" % (k,v), file=sys.stderr)


if __name__ == '__main__':

    args = parser()

    if args.print_http:
        httplib2.debuglevel = 1

    proteome = 'reference:yes' if args.reference else 'complete:yes'
    keyword = 'keyword:1185' if args.reference else 'keyword:181'

    h = httplib2.Http(args.cache)

    list_url = LIST_TEMPLATE.format(args.top_taxid, proteome)
    response, content = h.request(list_url)
    if args.print_http:
        prettyprint_http(response)
    taxids = content.decode().strip().split("\n")

    for taxid in taxids:
        if args.download_ids:
            filename = '%s.faa' % taxid
            print("Retrieving %s" % filename, file=sys.stderr)
            url = RET_TEMPLATE.format(taxid, keyword)
            response, content = h.request(url)
            with open(filename, 'w') as f:
                print(content.decode(), file=f)
        else:
            print(taxid)
