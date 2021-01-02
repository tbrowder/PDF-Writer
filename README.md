[![Actions Status](https://github.com/tbrowder/PDF-Writer/workflows/test/badge.svg)](https://github.com/tbrowder/PDF-Writer/actions)

NAME
====



PDF::Writer - Provides 'pdfwriter', a program to convert documents written in Raku POD to beautiful PDF format

THIS IS A WORK IN PROGRESS BUT IT IS VERY USABLE

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



PDF::Writer is the "poor man's" word processor.

CREDITS
=======



This project could not exist without all the many contributors to Raku since its begginning by Larry Wall, including the fine module `PDF::API6` by David Warring.

AUTHOR
======



Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2020-2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

