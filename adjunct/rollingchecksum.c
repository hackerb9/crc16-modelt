// A quick metric of how similar two binary blobs are.

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
#include <sys/mman.h>		/* mmap() */
#include <err.h>		/* warnx(), err() */
#include <stdlib.h>		/* exit() */
#include <sys/param.h>		/* MIN() */
#include <assert.h>		/* assert() */

auto sz=666;			/* Block size for checksumming */

struct map {
  char *filename;
  uint8_t *X;			/* Memory mapped array containing file   */
  size_t length;		/* Length of array X  */
  int fd;			/* File descriptor for file A */
};
static struct map A, B;

void cleanup() {
  if (A.X) munmap(A.X, A.length);
  if (A.fd!=-1) close(A.fd); 
}

uint32_t a(uint8_t *X, int k, int l) {
  uint16_t sum=0;
  for (int i=k; i<=l; i++) {
    sum += X[i];
  }
  return sum;
}

uint32_t b(uint8_t *X, int k, int l) {
  uint16_t sum=0;
  for (int i=k; i<=l; i++) {
    sum += (l-i+1)*X[i];
  }
  return sum;
}

static uint32_t preva, prevb;
uint32_t weak_checksum(uint8_t *X, int k, int l) {
  preva=a(X,k,l); 
  prevb=b(X,k,l); 
  return preva + (prevb<<16);
}

uint32_t weak_checksum_next(uint8_t *X, int k, int l) {
  /* Use the recurrence relationship to calculate next checksum */
  uint16_t a = preva - X[k-1] + X[l];
  uint16_t b = prevb - (l-k+1) * X[k-1] + a;
  preva=a; prevb=b;
  return a + (b<<16);
}

void
calculate_B_split(struct map *m, int sz) {
  /* Split file B into blocks of size sz and calculate the weak checksum */
  auto len = m->length;
  for (auto k=0; k < len-sz; k+=sz) {
    auto l=k+sz-1;
    assert ( l < len );
    auto cksum = weak_checksum(B.X, k, l);
    printf("%08X\t%d\n", cksum, k);
  }
}

void
calculate_A_rolling(struct map *m, int sz) {
  /* Calculate a rolling checksum of file A for every possible starting byte.
   * Compare the result against the table created by calculate_B_split.
   */
  auto len = m->length;
  int k=0;
  int l=k+sz-1;
  auto cksum = weak_checksum(m->X, k, l);  /* Prime the pump */
  printf("%08X\t%d\n", cksum, k);

  for (k=1; k < len-sz; k++) {
    l=k+sz-1;
    assert (l < len);
    cksum = weak_checksum_next(m->X, k, l);
    printf("%08X\t%d\n", cksum, k);
  }
}

void mapfile(struct map *m) {
  m->fd = open(m->filename, O_RDONLY);
  if (m->fd == -1) { err(1, m->filename); }
  struct stat  sb;
  if (fstat(m->fd, &sb) == -1)           /* To obtain file size */
    err(2, "fstat");
  m->length = sb.st_size;
  if (sz >= m->length) errx(4, "File too short: %s", m->filename);
  m->X = mmap(NULL, m->length, PROT_READ, MAP_PRIVATE, m->fd, 0);
  if (m->X == MAP_FAILED)
    err(3, "mmap(%s)", m->filename);
}

int
main(int argc, char *argv[]) {
  auto filename="foo";
  B.filename = filename;
  mapfile(&B);
  /* Initialization */
  calculate_B_split(&B, sz);

  /* Search */
  filename="bar";
  A.filename = filename;
  mapfile(&A);
  atexit(cleanup);

  calculate_A_rolling(&A, sz);

  exit(0);
}



// A quote from TR-CS-96-05
/****************************************************************************/
/* The weak checksum algorithm we used in our implementation was inspired   */
/* by Mark Adler's adler-32 checksum. Our checksum is defined by	    */
/* 									    */
/*     $$								    */
/*     a(k,l) = ( \sum_{i=k}^{l} X_i ) \mod M				    */
/*     b(k,l) = ( \sum_{i=k}^{l} (l-i+1)X_i ) \mod M			    */
/*     s(k,l) = a(k,l) + 2^{16} b(k,l)					    */
/*     $$								    */
/* 									    */
/* where s(k, l) is the rolling checksum of the bytes X_k ... X_l. For	    */
/* simplicity and speed, we use M = 2^{16}.				    */
/* 									    */
/* The important property of this checksum is that successive values can be */
/* computed very efficiently using the recurrence relations		    */
/* 									    */
/*     $$								    */
/*     a(k+1, l+1) = ( a(k,l) - X_k + X_{l+1} ) \mod M			    */
/*     b(k+1, l+1) = ( b(k,l) - (l-k+1)X_k + a(k+1, l+1) ) \mod M	    */
/*     $$								    */
/* 									    */
/* Thus the checksum can be calculated for blocks of length S at all	    */
/* possible offsets within a file in a "rolling" fashion, with very	    */
/* little computation at each point. Despite its simplicity, this	    */
/* checksum was found to be quite adequate as a first level check for a	    */
/* match of two file blocks. We have found in practice that the		    */
/* probability of this checksum matching when the blocks are not equal is   */
/* quite low. This is important because the much more expensive strong	    */
/* checksum must be calculated for each block where the weak checksum	    */
/* matches.								    */
/****************************************************************************/

/* Initialization: β calculates weak and strong checksums of
 * non-overlapping blocks of size S in file B. (S between 500 to 1000
 * bytes is "quite good for most purposes"). Last block can be short.
 * "Weak checksum" is the algorithm shown above. "Strong" can be MD5
 * or anything. β sends list of checksums to α.
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
 * [Second, at each offset in the file the 32-bit rolling checksum is looked up
 * in a 16-bit hash table.]
 */

/* The third level check involves calculating the strong checksum
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
