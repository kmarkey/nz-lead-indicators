# This script copies output SVGs over to my blog folder.  The file paths are system-specific, and in general
# this script is not of interest to anyone other than me.
# Peter Ellis 10 August 2018.

files <- list.files("output", pattern = ".svg$")

file.copy(paste0("output/", files),
          paste0("~/blog/ellisp.github.io/img/", files),
          overwrite = TRUE)
