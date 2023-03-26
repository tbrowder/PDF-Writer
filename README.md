[![Actions Status](https://github.com/tbrowder/PDF-Writer/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/PDF-Writer/actions) [![Actions Status](https://github.com/tbrowder/PDF-Writer/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/PDF-Writer/actions) [![Actions Status](https://github.com/tbrowder/PDF-Writer/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/PDF-Writer/actions)

NAME
====



**PDF::Writer** - Provides `pdfwriter`, a program to convert documents written in Raku POD to beautiful PDF format

**THIS IS A WORK IN PROGRESS BUT IT IS VERY USABLE**

Please try it out and file feature requests and bug reports. PRs welcome. The author often hangs out as 'tbrowder' on IRC channel `#raku`.

SYNOPSIS
========



    $ zef install PDF::Writer;
    ...
    $ pdfwriter
    ...extensive help
    $
    $ pdfwriter some-text-file.txt
    See file 'some-text-file.txt.pdf'

DESCRIPTION
===========



**PDF::Writer** is the "poor man's" word processor. It can turn text files into pdf documents now, with the ability for the user to control many aspects of the document including:

  * font (standard PostScript fonts)

  * font size

  * margins

  * paper (Letter, A4, etc.)

  * page numbering

  * doc title in bottom margin

  * underlining

  * user configuration file using TOML formats

Here is an example of the author's current configuration file:

    # Place these contents as file '$HOME/.pdfwriter/default.toml'
    # in order to be found by 'pdfwriter'.
    #
    # Set the value of "default" to the name of the table
    # to use for the current configuration defaults.
    #
    # Future plans are to allow an array of table names to
    # be used.

    default = "sent-rcvd"

    [sent-rcvd]
    leading-ratio = 1.35
    font = "Courier"
    size = 9.5
    underline = 1

Some planned features
---------------------

  * line numbering for code printouts

  * line wrapping for paragraphs

  * line truncation

  * Raku pod to PDF

  * Raku pod to PDF with custom formatting

CREDITS
=======



This project could not exist without all the many contributors to Raku since its beginning by Larry Wall, including the fine module `PDF::API6` by David Warring.

AUTHOR
======



Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2020-2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

