repeat
====================================================================
(c) 2005-2012 Evan Moran
http://github.com/evanmoran/repeat

Repeat is freely distributable under the MIT license.
http://opensource.org/licenses/mit

How does it work?
--------------------------------------------------------------------
Repeat allows commands to be automated with automagic substitution.

Quick example:

    echo 'a, 10\nb, 20' |  repeat "touch '$1$2.txt'" --separator ','

Output:

    touch 'a10.txt'
    touch 'b20.txt'

Note that by default repeat simply prints the commands, and does
not run them. You can run the commands by using the execute option
which is done with either `-x` or `--execute`. In the above
example this would have created two files: `a10.txt` and `b20.txt`.

Usage
--------------------------------------------------------------------

### repeat format [options] [files...]

    format                  The format string of the command to execute
                            Arguments are passed with the dollar sign:

                              $1   First argument
                              $2   Second argument
                                   (and so on...)

    options

      -h, --help            Help on usage with examples
      -x, --execute         Execute the command instead of printing it
      -c, --comment <c>     Regexp to detect comment line (default: '(//|#)')

      -s, --separator <c>   Regexp to split content on (default: '\t')
      --comma               Alias for --separator ','
      --tab                 Alias for --separator '\t'
      --tabs                Alias for --separator '\t+'
      --spaces              Alias for --separator ' +'
      --whitespace          Alias for --separator '\s+'

      --strict              Prevent commands from running if any $args are missing
                            This is useful if your data is irregular and missing
                            arguments could lead to bad commands (default: off)

    files                   List of files to use as arguments to the format string

                            Each line corresponds to a single format execution.
                            The --separator defines what the file is split on,
                            where the first part becomes $1, the second $2, etc.

Format Strings
--------------------------------------------------------------------
Format strings act much like regular expression and printf formats. They
can reorder items and place them around other characters.

    $1          First argument
    $2          Second argument
    ...         ...

Format strings can also come with printf-like formatting

    ${1,i}      The first number is the argument index as above
                The second part (after the comma) is the extra formatting

Advanced formatting: (all on first argument)

    ${1,i}      Convert to an integer (truncated precision)
    ${1,b}      Convert to a binary number
    ${1,o}      Convert to an octal number
    ${1,c}      Convert to an ascii character
    ${1,d}      Convert to a signed integer
    ${1,u}      Convert to an unsigned integer
    ${1,e}      Convert to floating point in scientific notation
    ${1,x}      Convert to hex
    ${1,X}      Convert to hex with CAPITAL LETTERS

    ${1,6s}     Convert to a string with six spaces or more
                ('hi' => '    hi')

    ${1,-6s}    Convert to a string with six spaces left justified
                ('hi' => 'hi    ')

    ${1,6i}     Convert to an integer with six spaces
                ('3.14159' => '     3')

    ${1,0.4f}   Convert to a float rounded to 4 decimal places
                ('3.14159' => '3.1416')

    ${1,6.4i}   Float with minimum of six spaces and 4 decimal places
                ('3.14159' => ' 3.1416')
