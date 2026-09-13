/**
 * @file    vigcipher.c
 * @author  RedRoosterKey
 * @version see version.h
 *
 * @section LICENSE
 *
 *                    GNU GENERAL PUBLIC LICENSE
 *                     Version 3, 29 June 2007
 *
 *    vigcipher is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    vigcipher is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @section DESCRIPTION
 *
 * Runs a basic Vigenère cipher on STDOUT and outputs "encrypted" text to
 * STDOUT.  Please note that this mode of encryption has been proven to be
 * completely insecure and should only be used for entertainment or educational
 * purposes.
 */

#include <ctype.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "version.h"

#define MAX_STRING_SIZE 256

const char * HELP =
		"Usage: vigcipher [OPTION]...\n\
Applies an insecure Vigenere cipher on STDIN \n\
  and outputs \"encrypted\" text on STDOUT\n\
\n\
  -a, --alphabet=<alphabet> specifies the unique ordered set of characters \n\
                             which can be encrypted when input\n\
  -e, --encrypt             increment characters according to the key\n\
  -d, --decrypt             decrement characters according to the key\n\
  -h, --help                display this help message and exit\n\
  -k, --key=<key>           specifies the non-unique ordered set of characters\n\
                             that describes the substitution indices\n\
  -l. --lower               convert everything to lower case if possible\n\
                             (may produce an error if this creates duplicate\n\
                             characters in the alphabet)\n\
  -p, --passthru            characters not in the alphabet will simply be\n\
                             output unencrypted\n\
                             (default behavior is to produce an error)\n\
  -q, --predefined-alpha    (UC|LC|AC|PRINT)\n\
                             UC = [A-Z]\n\
                             LC = [a-z]\n\
                             AC = [A-Za-z]\n\
                             PRINT = all printable characters\n\
  -u, --upper               convert everything to upper case if possible\n\
                             (may produce an error if this creates duplicate\n\
                             characters in the alphabet)\n\
  -v, --version             output version information and exit\n";

/**
 * Applies toupper to every character in the provided string.
 *
 * @param string the string to modify
 * @return void
 */
void stoupper(char * string) {
	for (short index = 0; '\0' != string[index] && index < MAX_STRING_SIZE;
			index++) {
		string[index] = toupper(string[index]);
	}
}

/**
 * Applies tolower to every character in the provided string.
 *
 * @param string the string to modify
 * @return void
 */
void stolower(char * string) {
	for (short index = 0; '\0' != string[index] && index < MAX_STRING_SIZE;
			index++) {
		string[index] = tolower(string[index]);
	}
}

// Predefined alphabets
const char * UC_ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";     // Upper-Case Alphabet
const char * LC_ALPHA = "abcdefghijklmnopqrstuvwxyz";     // Lower-Case Alphabet
const char * AC_ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"; // All-Case Alphabet
const char * PRINTABLE =                            // All Printable Characters
		" !\"#$%&'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRS\
TUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

/**
 * Checks if the provided string has any duplicate characters
 *
 * @param alphabet
 * @return true if duplicate characters are detected and false otherwise
 */
bool doesAlphabetHaveDuplicates(char * alphabet) {
	if (NULL == alphabet) {
		return (false);
	}
	unsigned short count[256];
	for (short i = 0; i < 256; i++) {
		count[i] = 0;
	}

	for (short i = 0; 0 != alphabet[i] && i < MAX_STRING_SIZE; i++) {
		if (0 < count[(unsigned char) alphabet[i]]) {
			return (true);
		}
		count[(unsigned char) alphabet[i]] = 1;
	}
	return (false);
}

/**
 * Searches for the character ch in the string alphabet
 *
 * @param alphabet the string search space
 * @param ch the character being searched for
 * @return the index of the first instance of ch, or -1 if it was not found
 */
short findChar(char * alphabet, char ch) {
	for (short i = 0; 0 != alphabet[i]; i++) {
		if (alphabet[i] == ch) {
			return (i);
		}
	}
	return (-1);
}

/**
 * Attempts to apply the cipher on STDIN and output results to STDOUT
 *
 * Will call exit(EXIT_FAILURE) if passThroughInvalidInput is false and a
 * character is received from STDIN that is not in the alphabet
 *
 * @param alphabet the unique ordered set of characters to encrypt
 * @param key the ordered set of characters contained within the alphabet
 *        that indicates the amount to shift input by
 * @param trueToEncrypt specifies if data should be shifted up to encrypt or
 *        down to decrypt
 * @param passThroughInvalidInput specifies if characters from STDIN that are
 *        not in the alphabet should cause errors or simply be output
 *        unencrypted
 * @param toUpper specifies if input should be capitalized
 * @param toLower specifies if input should be converted to lower case
 */
void applyCipher(char * alphabet, char * key, bool trueToEncrypt,
bool passThroughInvalidInput, bool toUpper, bool toLower) {
	short alphabetSize = strnlen(alphabet, MAX_STRING_SIZE);
	short keySize = strnlen(key, MAX_STRING_SIZE);

	short indexKey[keySize];
	for (short i = 0; 0 != key[i]; i++) {
		indexKey[i] = findChar(alphabet, key[i]);
	}

	int keyIndex = 0;
	int input;
	while (EOF != (input = getchar())) {
		if (toUpper)
			input = toupper(input);
		else if (toLower)
			input = tolower(input);
		short inputIndex = findChar(alphabet, input);
		if (0 > inputIndex) {
			if (passThroughInvalidInput) {
				putchar(input);
				continue;
			} else {
				fprintf(stderr,
						"Input has character '%c' that is not in the alphabet.\n",
						input);
				exit(EXIT_FAILURE);
			}
		}
		short outputIndex = inputIndex;
		if (trueToEncrypt) {
			outputIndex += (indexKey[keyIndex] + 1);
		} else {
			outputIndex -= (indexKey[keyIndex] + 1);
		}
		outputIndex = (outputIndex + alphabetSize) % alphabetSize;
		keyIndex = (keyIndex + 1) % keySize;
		putchar(alphabet[outputIndex]);
	}
}

/**
 * Main!  Handles program arguments and general execution
 *
 * @param argc the number of program arguments
 * @param argv the program arguments
 * @return 0 for success, any other value indicates failure
 */
int main(int argc, char **argv) {
	bool errors = false;

	bool encrypt = false;
	bool decrypt = false;
	bool passThroughInvalidInput = false;
	bool toUpper = false;
	bool toLower = false;
	char alphabet[MAX_STRING_SIZE + 1] = "";
	char key[MAX_STRING_SIZE] = "";
	static struct option long_options[] = { { "alphabet", required_argument, 0,
			'a' }, { "encrypt", no_argument, 0, 'e' }, { "decrypt", no_argument,
			0, 'd' }, { "help", no_argument, 0, 'h' }, { "key",
	required_argument, 0, 'k' }, { "lower", no_argument, 0, 'l' }, { "passthru",
			no_argument, 0, 'p' }, { "predefined-alpha",
	required_argument, 0, 'q' }, { "upper", no_argument, 0, 'u' }, { "version",
			no_argument, 0, 'v' }, { 0, 0, 0, 0 } };
	// Handle command line options
	while (true) {
		int option_index = 0;

		int option = getopt_long(argc, argv, "a:edhk:lpq:uv", long_options,
				&option_index);
		if (option == -1)
			break;
		switch (option) {
		case 'a':
			if (strnlen(optarg, MAX_STRING_SIZE + 1) > MAX_STRING_SIZE) {
				fprintf(stderr,
						"Alphabet is longer than max supported size of %d.\n",
						MAX_STRING_SIZE);
				errors = true;
			}
			strncpy(alphabet, optarg, MAX_STRING_SIZE);
			break;
		case 'e':
			encrypt = true;
			break;
		case 'd':
			decrypt = true;
			break;
		case 'h':
			// Print help
			puts(HELP);
			return (EXIT_SUCCESS);
			break;
		case 'k':
			strncpy(key, optarg, MAX_STRING_SIZE);
			break;
		case 'l':
			toLower = true;
			break;
		case 'p':
			passThroughInvalidInput = true;
			break;
		case 'q':
			if (0 == strncmp("UC", optarg, MAX_STRING_SIZE)) {
				strncpy(alphabet, UC_ALPHA, MAX_STRING_SIZE);
			} else if (0 == strncmp("LC", optarg, MAX_STRING_SIZE)) {
				strncpy(alphabet, LC_ALPHA, MAX_STRING_SIZE);
			} else if (0 == strncmp("AC", optarg, MAX_STRING_SIZE)) {
				strncpy(alphabet, AC_ALPHA, MAX_STRING_SIZE);
			} else if (0 == strncmp("PRINT", optarg, MAX_STRING_SIZE)) {
				strncpy(alphabet, PRINTABLE, MAX_STRING_SIZE);
			} else {
				fprintf(stderr, "There is no predefined alphabet \"%s\"\n",
						optarg);
				fputs("Please run with --help for usage options.\n", stderr);
				errors = true;
			}
			break;
		case 'u':
			toUpper = true;
			break;
		case 'v':
			printf("%s\n", VERSION);
			return (EXIT_SUCCESS);
		case '?':
			fputs("Please run with --help for usage options.\n", stderr);
			errors = true;
			break;
		default:
			abort();
			break;
		}
	}

	// Check for input errors before trying to apply cipher
	if (optind < argc) {
		fputs("Non-option arguments are not supported.\n", stderr);
		fputs("Please run with --help for usage options.\n", stderr);
		errors = true;
	}
	if (false == encrypt && false == decrypt) {
		fputs("Specify if you would like to encrypt or decrypt.\n", stderr);
		return (EXIT_FAILURE);
	} else if (true == encrypt && true == decrypt) {
		fputs("You cannot both encrypt and decrypt.\n", stderr);
		return (EXIT_FAILURE);
	}
	if (NULL == alphabet || 0 == strnlen(alphabet, MAX_STRING_SIZE)) {
		fputs("No alphabet provided.\n", stderr);
		errors = true;
	} else {
		for (short i = 0; 0 != key[i]; i++) {
			if (0 > findChar(alphabet, key[i])) {
				fprintf(stderr,
						"Key has character '%c' that is not in the alphabet.\n",
						key[i]);
				errors = true;
			}
		}
	}
	if (NULL == key || 0 == strnlen(key, MAX_STRING_SIZE)) {
		fputs("No key provided.\n", stderr);
		errors = true;
	}
	if (true == toUpper && true == toLower) {
		fputs("You cannot convert output to both upper case and lower case.\n",
		stderr);
		errors = true;
	} else if (true == toUpper) {
		stoupper(alphabet);
		stoupper(key);
	} else if (true == toLower) {
		stolower(alphabet);
		stolower(key);
	}
	if (doesAlphabetHaveDuplicates(alphabet)) {
		fputs("Alphabet cannot have duplicate characters.\n", stderr);
		errors = true;
	}

	// If there are no detected errors, attempt to apply the cipher on STDIN
	if (false == errors) {
		applyCipher(alphabet, key, encrypt && !decrypt, passThroughInvalidInput,
				toUpper, toLower);
	} else {
		return (EXIT_FAILURE);
	}
	return (EXIT_SUCCESS);
}
