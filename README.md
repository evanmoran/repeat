repeat
====================================================================
(c) 2005-2012 Evan Moran
http://github.com/evanmoran/repeat

Repeat is freely distributable under the MIT license.
http://opensource.org/licenses/mit

How does it work?
--------------------------------------------------------------------
Repeat allows commands to be automated with automagic substitution.

Imagine you have a comma separated file called _data.csv_:

    Evan,     3.14,    Batman
    Laura,    19,      James Bond
    Sarah,    42,      Wolverine

Here is a simple example:

    repeat '#1 loves #3' data.csv --comma

output:

    Evan loves Batman
    Laura loves James Bond
    Sarah loves Wolverine

Repeat can handle any type of separator: `--tab`, `--whitespace`, `--comma`
or you can provide your own type of separator with a regular expression.

Now let's craft a more complex command:

    repeat 'echo "#1 loves #3" > #1.txt ' data.csv --comma

output:

    echo "Evan loves Batman" > Evan.txt
    echo "Laura loves James Bond" > Laura.txt
    echo "Sarah loves Wolverine" > Sarah.txt

By default repeat simply prints the commands and _does not_ run them.
To execute the commands use the execute option with `-x` or `--execute`:

    repeat 'echo "#1 loves #3" > #1.txt ' data.csv --execute --comma

This outputs nothing but creates three files:

    Evan.txt
    Laura.txt
    Sarah.txt

Use verbose mode (`-v` or `--verbose`) to print commands as they are being run:

    repeat 'cat #1.txt' data.csv --execute --verbose --comma

output:

    [cat Evan.txt]
    Evan loves Batman
    [cat Laura.txt]
    Laura loves James Bond
    [cat Sarah.txt]
    Sarah loves Wolverine

Finally clean everything up:

    repeat 'rm #1.txt' data.csv --execute --verbose --comma

output:

    [rm Evan.txt]
    [rm Laura.txt]
    [rm Sarah.txt]

Usage
--------------------------------------------------------------------

#### repeat [options] format [files...]

    format                  The format string of the command to execute
                            Arguments are passed with the dollar sign:

                              #1   First argument
                              #2   Second argument
                                   (and so on...)

    options

      -h, --help            Help on usage with examples
      -x, --execute         Execute the command instead of printing it
      -c, --comment <c>     Regexp to detect comment line (default: '(//|\#)')
      -s, --separator <c>   Regexp to split content on (default: '\t')
      -m, --marker <c>      Regexp to find argument in the format (default: '\#')

                            Note: Initially `$` seemed a better choice for the marker
                            but in practice it required too much character escaping.

      --comma               Alias for --separator ','
      --tab                 Alias for --separator '\t'
      --tabs                Alias for --separator '\t+'
      --spaces              Alias for --separator ' +'
      --whitespace          Alias for --separator '\s+'

      --strict              Prevent commands from running if any #args are missing
                            This is useful if your data is irregular and missing
                            arguments could lead to bad commands (default: off)

    files                   List of files to use as arguments to the format string

                            Each line corresponds to a single format execution.
                            The --separator defines what the file is split on,
                            where the first part becomes #1, the second #2, etc.

Format Strings
--------------------------------------------------------------------
Format strings act much like regular expression and printf formats. They
can reorder items and place them around other characters.

    #1          First argument
    #2          Second argument
    ...         ...

Advanced formatting: (all on first argument)
--------------------------------------------------------------------
Format strings can also come with printf-like formatting.
The first argument is the argument number as shown above.
The second part after the command is the printf format:

    #{1,i}      Convert to an integer (truncated precision)
    #{1,b}      Convert to a binary number
    #{1,o}      Convert to an octal number
    #{1,c}      Convert to an ascii character
    #{1,d}      Convert to a signed integer
    #{1,u}      Convert to an unsigned integer
    #{1,e}      Convert to floating point in scientific notation
    #{1,x}      Convert to hex
    #{1,X}      Convert to hex with CAPITAL LETTERS

    #{1,6s}     Convert to a string with six spaces or more
                ('hi' => '    hi')

    #{1,-6s}    Convert to a string with six spaces left justified
                ('hi' => 'hi    ')

    #{1,6i}     Convert to an integer with six spaces
                ('3.14159' => '     3')

    #{1,0.4f}   Convert to a float rounded to 4 decimal places
                ('3.14159' => '3.1416')

    #{1,6.4i}   Float with minimum of six spaces and 4 decimal places
                ('3.14159' => ' 3.1416')

