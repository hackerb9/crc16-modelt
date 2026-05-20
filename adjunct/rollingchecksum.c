// A quick metric of how similar two binary blobs are.
// Compile with gcc rollingchecksum.c -o rollingchecksum -lmd
// Requires libmd for SHA hashing and uthash.h for hash table.


// Note that this metric is *not* symmetric by default. For example,
// The PC-8300 ROM file is four times as large as the PC-8201, so
// looking for PC-8300's blocks within the PC-8201 ROM finds a 42%
// match, but looking for PC-8201's blocks within PC-8300 yields 87%!
//
// Even if two files are the same size, a rolling checksum is
// calculated for every byte address of file A, but file B is split
// into non-overlapping blocks. 
//
// If a symmetric metric is required, use the `-s` option to treat
// both files as the same size and calculate a rolling checksum for
// file B, as well.


// Based on the algorithm presented by Tridgell and Mackerras.
//     https://jhpce.jhu.edu/files/rsync/
//     TR-CS-96-05
//     The rsync algorithm
//     Andrew Tridgell and Paul Mackerras
//     June 1996

#include <fcntl.h>		/* open() */
#include <unistd.h>		/* write() */
#include <sys/stat.h>		/* fstat() */
#include <stdio.h>		/* fprintf() */
#include <stdint.h>		/* uint8_t */
#include <stdlib.h>		/* exit() */
#include <getopt.h>		/* getopt_long() */
#include <sys/param.h>		/* MIN() */
#include <sys/mman.h>		/* mmap() */
#include <err.h>		/* warnx(), err() */
#include <assert.h>		/* assert() */
#include <sha1.h>		/* The "strong" hashing function. (libmd) */
#include <md5.h>		/* Another "strong" hashing function. (libmd) */
#include "uthash.h"		/* UT Hash table implementation */

auto blksz=320;			/* Block size to compare, in bytes (default) */

auto rollbflag=false;		/* Roll file B instead of splitting it? */
auto symflag=false;		/* Symmetric metric by enabling rollbflag and
				   only comparing up to the smaller filesize */
auto verbose=false;

struct map {
  char *filename;
  uint8_t *X;			/* Memory mapped array containing file */
  size_t length;		/* Length of array X  */
  int fd;			/* File descriptor for file A */
};
static struct map A, B;


struct checksum {		/* A struct for uthash to hold  */
  uint32_t weaksum;		/* Hash key is the weak checksum value */
  char *strongsum;
  int location;			/* byte offset in file */
  struct map *filemap;
  UT_hash_handle hh;		/* makes this structure hashable */
};

struct checksum *theTable = NULL;
void add_checksum(uint32_t weaksum, char *strongsum, struct map *m, int i) {
  struct checksum *s;

  /* UTHash goes into an infinite loop if duplicate keys are entered! */
  HASH_FIND_INT(theTable, &weaksum, s);
  if (s != NULL)
    return;
  s = (struct checksum *)malloc(sizeof *s);
  if (!s) err(7, "Could not malloc struct checksum");
  s->weaksum = weaksum;   s->strongsum = strongsum;
  s->filemap = m;   s->location = i;
  HASH_ADD_INT(theTable, weaksum, s);
}

struct checksum *lookup_checksum(int weaksum) {
  struct checksum *s;
  HASH_FIND_INT(theTable, &weaksum, s);
  return s;
}

void cleanup() {
  if (A.X) munmap(A.X, A.length);
  if (A.fd!=-1) close(A.fd); 
  if (B.X) munmap(B.X, B.length);
  if (B.fd!=-1) close(B.fd); 
}

static inline uint32_t a(uint8_t *X, int k, int l) {
  uint16_t sum=0;
  for (int i=k; i<=l; i++) {
    sum += X[i];
  }
  return sum;
}

static inline uint32_t b(uint8_t *X, int k, int l) {
  uint16_t sum=0;
  for (int i=k; i<=l; i++) {
    sum += (l-i+1)*X[i];
  }
  return sum;
}

static uint32_t preva, prevb, prevk=-999;

static inline uint32_t
weak_checksum(uint8_t *X, int k, int l) {
  preva=a(X,k,l); prevb=b(X,k,l); prevk=k;
  return preva + (prevb<<16);
}

static inline uint32_t
weak_checksum_next(uint8_t *X, int k, int l) {
  /* Initial block? */
  if (k != prevk+1) return weak_checksum(X, k, l); 

  /* Use the recurrence relationship to calculate next checksum */
  uint16_t a = preva - X[k-1] + X[l];
  uint16_t b = prevb - (l-k+1) * X[k-1] + a;
  preva=a; prevb=b; prevk=k;
  return a + (b<<16);
}


static inline char *
strong_checksum(uint8_t *X, int k, int l) {
  return MD5Data(X+k, l-k+1, NULL); /* Note: this mallocs a string. */
}

void
calculate_B_split(struct map *m, int blksz) {
  /* Split file B into blocks of size blksz and calculate the checksums. */
  /* Insert checksums into the hash table. */

  int increment = blksz;	/*    Split the standard rsync way, */
  if (rollbflag) 
    increment = 1;		/* or Start at every byte address.  */

  auto len = m->length;
  for (auto k=0; k < len-blksz; k+=increment) {
    auto l=k+blksz-1;
    assert ( l < len );
    auto weaksum = weak_checksum(B.X, k, l);
    auto strongsum = strong_checksum(B.X, k, l);
    add_checksum(weaksum, strongsum, m, k);
  }
}

int
calculate_A_rolling(struct map *m, int blksz) {
  /* Calculate rolling checksum of file A for every possible starting byte.
   * Compare the result against the table created by calculate_B_split.
   */
  int matches=0;
  auto len = m->length;
  for (auto k=0; k < len-blksz; k++) {
    auto l=k+blksz-1;
    assert (l < len);
    auto cksum = weak_checksum_next(m->X, k, l);
    auto s = lookup_checksum(cksum);
    if (s != NULL) {
      auto strongsum = strong_checksum(m->X, k, l);
      if ( strcmp(strongsum, s->strongsum) != 0 ) {
	free(strongsum);
	continue;
      }
      free(strongsum);
      matches++;
      if (verbose)
	printf("%08X%7d%7d  %08x\n", cksum, k, s->location, s->weaksum);
      /* Skip rest of block */
      k+=blksz-1;
    }
  }
  return matches;
}

void
mapfile(struct map *m) {
  m->fd = open(m->filename, O_RDONLY);
  if (m->fd == -1) { err(1, m->filename); }
  struct stat  sb;
  if (fstat(m->fd, &sb) == -1)           /* To obtain file size */
    err(2, "fstat");
  m->length = sb.st_size;
  if (blksz >= m->length) errx(4, "File too short: %s", m->filename);
  m->X = mmap(NULL, m->length, PROT_READ, MAP_PRIVATE, m->fd, 0);
  if (m->X == MAP_FAILED)
    err(3, "mmap(%s)", m->filename);
}

void usage() {
  printf("Usage: rollingchecksum [options] <fileA> <fileB>\n"
	 "                       [-B|--block-size <blocksize>]"
	 "\t(default %d bytes)\n"
	 "                       [-r|--roll-file-b]\n"
	 "                       [-R|--no-roll-file-b]\n", blksz);
}

int
main(int argc, char *argv[]) {
  for (;;) {
    int option_index = 0;
    static struct option long_options[] = {
      {"block-size",     required_argument, 0,  'B' },
      {"roll-file-b",    no_argument,       0,  'r' },
      {"no-roll-file-b", no_argument,       0,  'R' },
      {"symmetric", 	 no_argument,       0,  's' },
      {"no-symmetric", 	 no_argument,       0,  'S' },
      {0,         	 0,                 0,   0  }
    };

    auto c = getopt_long(argc, argv, "B:RrSs", long_options, &option_index);
    if (c == -1)
      break;
    switch (c) {
    case 'B':
      blksz = atoi(optarg);
      break;

    case 'r':
      rollbflag = true;
      break;
    case 'R':
      rollbflag = false;
      symflag = false;
      break;

    case 's':
      rollbflag = true;
      symflag = true;
      break;
    case 'S':
      rollbflag = false;
      symflag = false;
      break;

    case '?':
      usage();
      exit(EXIT_FAILURE);
      break;

    default:
      printf("?? getopt returned character code 0%o ??\n", c);
    }
  }

  if (argc-optind < 2) {
    usage();
    errx(5, "Error: Must specify two filenames.");
  }
  A.filename = argv[optind];
  B.filename = argv[optind+1];
  mapfile(&A);
  mapfile(&B);
  atexit(cleanup);

  // --symmetric flag given? Pretend both files are the same size.
  if ( symflag ) {
    A.length = MIN( A.length, B.length );
    B.length = MIN( A.length, B.length );
  }

  /* Initialization */
  calculate_B_split(&B, blksz);

  /* Search */
  auto c = calculate_A_rolling(&A, blksz);

  /* Result is percentage of bytes which matched */
  printf("%5.2f\n", 100.0*c*blksz/A.length);

  exit(EXIT_SUCCESS);
}



// A quote from TR-CS-96-05
/**************************************************************************** 
 * The weak checksum algorithm we used in our implementation was inspired   * 
 * by Mark Adler's adler-32 checksum. Our checksum is defined by	    * 
 * 									    * 
 *     $$								    * 
 *     a(k,l) = ( \sum_{i=k}^{l} X_i ) \mod M				    * 
 *     b(k,l) = ( \sum_{i=k}^{l} (l-i+1)X_i ) \mod M			    * 
 *     s(k,l) = a(k,l) + 2^{16} b(k,l)					    * 
 *     $$								    * 
 * 									    * 
 * where s(k, l) is the rolling checksum of the bytes X_k ... X_l. For	    * 
 * simplicity and speed, we use M = 2^{16}.				    * 
 * 									    * 
 * The important property of this checksum is that successive values can be * 
 * computed very efficiently using the recurrence relations		    * 
 * 									    * 
 *     $$								    * 
 *     a(k+1, l+1) = ( a(k,l) - X_k + X_{l+1} ) \mod M			    * 
 *     b(k+1, l+1) = ( b(k,l) - (l-k+1)X_k + a(k+1, l+1) ) \mod M	    * 
 *     $$								    * 
 * 									    * 
 * Thus the checksum can be calculated for blocks of length S at all	    * 
 * possible offsets within a file in a "rolling" fashion, with very	    * 
 * little computation at each point. Despite its simplicity, this	    * 
 * checksum was found to be quite adequate as a first level check for a	    * 
 * match of two file blocks. We have found in practice that the		    * 
 * probability of this checksum matching when the blocks are not equal is   * 
 * quite low. This is important because the much more expensive strong	    * 
 * checksum must be calculated for each block where the weak checksum	    * 
 * matches.								    * 
 ****************************************************************************/

/* Initialization: β calculates weak and strong checksums of
 * non-overlapping blocks of size S in file B. (S between 500 to 1000
 * bytes is "quite good for most purposes"). Last block can be short.
 * "Weak checksum" is the algorithm shown above. "Strong" can be MD5,
 * SHA-1 or what-have-you. β sends list of checksums to α.
 */ 

/* Once α has received the list of checksums of the blocks of B, it must
 * search A for any blocks at any offset that match the checksum of some
 * block of B. The basic strategy is to compute the 32-bit rolling
 * checksum for a block of length S starting at each byte of A in turn,
 * and for each checksum, search the list for a match. 
 */

/* [First use] a 16-bit hash of the 32-bit rolling checksum and a
 * 2^{16} entry hash table. The list of checksum values (i.e., the
 * checksums from the blocks of B) is sorted according to the 16-bit
 * hash of the 32-bit rolling checksum. 
 *
 * [Second, at each offset in the file the 32-bit rolling checksum is
 * looked up in a 16-bit hash table.]
 *
 * The third level check involves calculating the strong checksum
 * (MD5) for the current offset in the file and comparing it with the
 * strong checksum value in the current list entry. If the two strong
 * checksums match, we assume that we have found a block of A which
 * matches a block of B. In fact the blocks could be different, but
 * the probability of this is microscopic, and in practice this is a
 * reasonable assumption.
 * 
 * If no match is found at a given offset in the file, the rolling
 * checksum is updated to the next offset and the search proceeds. If a
 * match is found, the search is restarted at the end of the matched
 * block.  
 */ 
