#!/bin/bash

geoprofiles-orgn-name() {
    esearch -db geoprofiles -query "$1 [ORGN] $2 [NAME]" |
        efetch -format docsum |
        xtract -pattern DocumentSummary -element VMIN VMAX VSTD title |
        sort -nk2
}
