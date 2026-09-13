#! /bin/bash
set -e
# set -v

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROGRAM="${DIR}/../Release/vigcipher"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)

function testOutput() {
    in=${1}
    out=${2}
    options=${3}
    value=$(echo -n "${in}" | ${PROGRAM} ${options})
    if [ "${out}" != "${value}" ]
    then
        echo "${RED}Expected \"${out}\""
        echo " but got \"${value}\"${NC}"
        return 255
    else
        echo "${GREEN}[OK]${NC}"
    fi
    return 0
}

function testErrorOutput() {
    in=${1}
    err=${2}
    options=${3}
    set +e
    value=$( (echo -n "${in}" | ${PROGRAM} ${options}) 2>&1 )
    set -e
    if [ "${err}" != "${value}" ]
    then
        echo "${RED}Expected error \"${err}\""
        echo " but got       \"${value}\"${NC}"
        return 255
    else
        echo "${GREEN}[OK]${NC}"
    fi
    return 0
}

function testReturnValue() {
    in=${1}
    rVal=${2}
    options=${3}
    set +e
    echo -n "${in}" | ${PROGRAM} ${options} > /dev/null 2>&1
    value=$?
    set -e
    if [ "${rVal}" != "${value}" ]
    then
        echo "${RED}Expected \"${rVal}\""
        echo " but got \"${value}\"${NC}"
        return 255
    else
        echo "${GREEN}[OK]${NC}"
    fi
    return 0
}

# really simply baseline test
testOutput '2341' '1234' '-d -a 1234 -k 1'
testOutput '1234' '2341' '-e -a 1234 -k 1'
testOutput '2341' '1234' '--decrypt --alphabet=1234 --key=1'
testOutput '1234' '2341' '--encrypt --alphabet=1234 --key=1'

# specify encryption or decryption
testReturnValue '' 1 '-q UC -k X'
testErrorOutput '' 'Specify if you would like to encrypt or decrypt.' '-q UC -k X'
testReturnValue '' 1 '--predefined-alpha=UC --key=X'
testErrorOutput '' 'Specify if you would like to encrypt or decrypt.' '--predefined-alpha=UC --key=X'

# but not both
testReturnValue '' 1 '-e -d -q UC -k X'
testErrorOutput '' 'You cannot both encrypt and decrypt.' '-e -d -q UC -k X'
testReturnValue '' 1 '--encrypt --decrypt --predefined-alpha=UC --key=X'
testErrorOutput '' 'You cannot both encrypt and decrypt.' '--encrypt --decrypt --predefined-alpha=UC --key=X'

# No alphabet provided
testReturnValue '' 1 '-e -k X'
testErrorOutput '' 'No alphabet provided.' '-e -k X'
testReturnValue '' 1 '--encrypt --key=X'
testErrorOutput '' 'No alphabet provided.' '--encrypt --key=X'

# Unsupported non-option arg
testReturnValue '' 1 'x -e -q UC -k X'
testErrorOutput '' 'Non-option arguments are not supported.
Please run with --help for usage options.' 'x -e -q UC -k X'

# No key provided
testReturnValue '' 1 '-e -a 1'
testErrorOutput '' 'No key provided.' '-e -a 1'
testReturnValue '' 1 '--encrypt --alphabet=1'
testErrorOutput '' 'No key provided.' '--encrypt --alphabet=1'

# Bare minimum required for successful termination
testReturnValue '' 0 '-e -a a -k a'
testErrorOutput '' '' '-e -a a -k a'
testOutput '' '' '-e -a a -k a'
testReturnValue '' 0 '--encrypt --alphabet=a --key=a'
testErrorOutput '' '' '--encrypt --alphabet=a --key=a'
testOutput '' '' '--encrypt --alphabet=a --key=a'

# cannot enable both upper and lower case
testReturnValue '' 1 '-e -a a -k a -u -l'
testErrorOutput '' 'You cannot convert output to both upper case and lower case.' '-e -a a -k a -u -l'
testReturnValue '' 1 '--encrypt --alphabet=a --key=a --upper --lower'
testErrorOutput '' 'You cannot convert output to both upper case and lower case.' '--encrypt --alphabet=a --key=a --upper --lower'

# test error on key letter not in the alphabet
testReturnValue '' 1 '-e -a a -k b'
testErrorOutput '' "Key has character 'b' that is not in the alphabet." '-e -a a -k b'
testReturnValue '' 1 '--encrypt --alphabet=a --key=b'
testErrorOutput '' "Key has character 'b' that is not in the alphabet." '--encrypt --alphabet=a --key=b'

# test error on input letter not in the alphabet
testReturnValue 'x' 1 '-e -a a -k a'
testErrorOutput 'x' "Input has character 'x' that is not in the alphabet." '-e -a a -k a'
testReturnValue 'x' 1 '--encrypt --alphabet=a --key=a'
testErrorOutput 'x' "Input has character 'x' that is not in the alphabet." '--encrypt --alphabet=a --key=a'

# test when invalid input is passed through
testReturnValue 'x' 0 '-e -a a -k a -p'
testErrorOutput 'x' 'x' '-e -a a -k a -p'
testReturnValue 'x' 0 '--encrypt --alphabet=a --key=a --passthru'
testErrorOutput 'x' 'x' '--encrypt --alphabet=a --key=a --passthru'

# test uppercase output
testReturnValue 'x' 0 '-e -a a -k a -p -u'
testErrorOutput 'x' 'X' '-e -a a -k a -p -u'
testReturnValue 'x' 0 '--encrypt --alphabet=a --key=a --passthru --upper'
testErrorOutput 'x' 'X' '--encrypt --alphabet=a --key=a --passthru --upper'

# test lowercase output
testReturnValue 'X' 0 '-e -a a -k a -p -l'
testErrorOutput 'X' 'x' '-e -a a -k a -p -l'
testReturnValue 'X' 0 '--encrypt --alphabet=a --key=a --passthru --lower'
testErrorOutput 'X' 'x'  '--encrypt --alphabet=a --key=a --passthru --lower'

# Big alphabet failure test Size=257
#        1         2         3         4         5         6         7         8          9         100
testReturnValue '' 1 "-k 0 -e -a \
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
123456789012345678901234567890123456789012345678901234567"
testErrorOutput '' 'Alphabet is longer than max supported size of 256.
Alphabet cannot have duplicate characters.' "-k 0 -e -a \
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
123456789012345678901234567890123456789012345678901234567"
# Big alphabet success test Size=256
testReturnValue '' 1 "-e -k 0 -a \
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
12345678901234567890123456789012345678901234567890123456"
# Should not get size error, should get duplicate characters error instead
testErrorOutput '' 'Alphabet cannot have duplicate characters.' "-e -k 0 -a \
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\
12345678901234567890123456789012345678901234567890123456"

# Big key failure test Size=257
#        1         2         3         4         5         6         7         8          9         100
testReturnValue '' 1 "-a a -e -k \
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
testErrorOutput '' 'Key is longer than max supported size of 256.' "-a a -e -k \
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# Big key success test Size=256 (at the length limit, one 'a' shorter than above)
testReturnValue '' 0 "-a a -e -k \
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# Key length is not checked for duplicates, so a valid, non-error-producing key at the
# limit should produce no errors at all
testErrorOutput '' '' "-a a -e -k \
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

testOutput 'the quick brown for jumps over the lazy dog' 'wkh txlfn eurzq iru mxpsv ryhu wkh odcb grj' '-p -e -k c -a abcdefghijklmnopqrstuvwxyz'
testOutput 'wkh txlfn eurzq iru mxpsv ryhu wkh odcb grj' 'the quick brown for jumps over the lazy dog' '-p -d -k c -a abcdefghijklmnopqrstuvwxyz'
testOutput 'the quick brown for jumps over the lazy dog' 'qww urxuo yggak ugv gjetp dnio izi iprc ady' '-p -e -k word -a abcdefghijklmnopqrstuvwxyz'
testOutput 'qww urxuo yggak ugv gjetp dnio izi iprc ady' 'the quick brown for jumps over the lazy dog' '-p -d -k word -a abcdefghijklmnopqrstuvwxyz'

testOutput 'the quick brown for jumps over the lazy dog' 'WKH TXLFN EURZQ IRU MXPSV RYHU WKH ODCB GRJ' '-p -e -k c -a abcdefghijklmnopqrstuvwxyz -u'
testOutput 'WKH TXLFN EURZQ IRU MXPSV RYHU WKH ODCB GRJ' 'the quick brown for jumps over the lazy dog' '-p -d -k c -a abcdefghijklmnopqrstuvwxyz -l'
testOutput 'the quick brown for jumps over the lazy dog' 'QWW URXUO YGGAK UGV GJETP DNIO IZI IPRC ADY' '-p -e -k word -a abcdefghijklmnopqrstuvwxyz -u'
testOutput 'QWW URXUO YGGAK UGV GJETP DNIO IZI IPRC ADY' 'the quick brown for jumps over the lazy dog' '-p -d -k word -a abcdefghijklmnopqrstuvwxyz -l'

# Test help
help='Usage: vigcipher [OPTION]...
Applies an insecure Vigenere cipher on STDIN 
  and outputs "encrypted" text on STDOUT

  -a, --alphabet=<alphabet> specifies the unique ordered set of characters 
                             which can be encrypted when input
  -e, --encrypt             increment characters according to the key
  -d, --decrypt             decrement characters according to the key
  -h, --help                display this help message and exit
  -k, --key=<key>           specifies the non-unique ordered set of characters
                             that describes the substitution indices
  -l. --lower               convert everything to lower case if possible
                             (may produce an error if this creates duplicate
                             characters in the alphabet)
  -p, --passthru            characters not in the alphabet will simply be
                             output unencrypted
                             (default behavior is to produce an error)
  -q, --predefined-alpha    (UC|LC|AC|PRINT)
                             UC = [A-Z]
                             LC = [a-z]
                             AC = [A-Za-z]
                             PRINT = all printable characters
  -u, --upper               convert everything to upper case if possible
                             (may produce an error if this creates duplicate
                             characters in the alphabet)
  -v, --version             output version information and exit'
testReturnValue '' 0 '-h'
testOutput '' "${help}" '-h'
testReturnValue '' 0 '--help'
testOutput '' "${help}" '--help'

# Test version
testReturnValue '' 0 '-v'
testOutput '' '0.0.5' '-v'
testReturnValue '' 0 '--version'
testOutput '' '0.0.5' '--version'

echo "${GREEN}ALL GOOD!${NC}"
