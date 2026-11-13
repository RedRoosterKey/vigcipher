#! /bin/bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SRC="${DIR}/../src/vigcipher.c"
BIN="${DIR}/../vigcipher_asan"
RED=$(tput setaf 1 2>/dev/null || true)
GREEN=$(tput setaf 2 2>/dev/null || true)
NC=$(tput sgr0 2>/dev/null || true)

# Build a dedicated AddressSanitizer binary. Regular black-box tests
# (scripts/test.sh) can't reliably prove out-of-bounds memory access
# is happening -- the corrupted memory may not affect the output of
# any given run. ASan instruments every memory access and aborts with
# a diagnostic the moment one goes out of bounds.
"${CC:-cc}" -fsanitize=address -g -O0 -std=c99 -D_GNU_SOURCE -o "${BIN}" "${SRC}"

function testNoSanitizerError() {
	in=${1}
	options=${2}
	set +e
	output=$( (echo -n "${in}" | ${BIN} ${options}) 2>&1 )
	rc=$?
	set -e
	if echo "${output}" | grep -q "AddressSanitizer"
	then
		echo "${RED}AddressSanitizer caught a memory error:${NC}"
		echo "${output}"
		return 255
	elif [ 134 -eq "${rc}" ] || [ 139 -eq "${rc}" ]
	then
		echo "${RED}Process crashed (exit ${rc}) with no sanitizer report${NC}"
		return 255
	else
		echo "${GREEN}[OK]${NC}"
	fi
	return 0
}

# doesAlphabetHaveDuplicates() casts each alphabet byte to (short) to
# index a 256-entry count[] array. char is signed on this platform, so
# a byte >= 0x80 sign-extends to a negative short, reading/writing
# count[] out of bounds. Two distinct high-bit bytes (0xff, 0xfe) are
# enough to reach that code path with a non-duplicate alphabet.
highBitAlphabet=$'\xff\xfe'
testNoSanitizerError '' "-e -a ${highBitAlphabet} -k ${highBitAlphabet}"

rm -rf "${BIN}" "${BIN}.dSYM"

echo "${GREEN}ALL GOOD!${NC}"
