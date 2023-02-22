#include <time.h>
#include <stdio.h>
#include <x86intrin.h>
#include "simd.h"

long long int sum(int vals[NUM_ELEMS]) {
   clock_t start = clock();

   long long int sum = 0;
   for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
      for(unsigned int i = 0; i < NUM_ELEMS; i++) {
         if(vals[i] >= 128) {
            sum += vals[i];
         }
      }
   }
   clock_t end = clock();
   printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
   return sum;
}

long long int sum_unrolled(int vals[NUM_ELEMS]) {
   clock_t start = clock();
   long long int sum = 0;

   for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
      for(unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4) {
         if(vals[i] >= 128) sum += vals[i];
         if(vals[i + 1] >= 128) sum += vals[i + 1];
         if(vals[i + 2] >= 128) sum += vals[i + 2];
         if(vals[i + 3] >= 128) sum += vals[i + 3];
      }

      // TAIL CASE, for when NUM_ELEMS isn't a multiple of 4
      // NUM_ELEMS / 4 * 4 is the largest multiple of 4 less than NUM_ELEMS
      // Order is important, since (NUM_ELEMS / 4) effectively rounds down first
      for(unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++) {
         if (vals[i] >= 128) {
            sum += vals[i];
         }
      }
   }
   clock_t end = clock();
   printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
   return sum;
}

long long int sum_simd(int vals[NUM_ELEMS]) {
   clock_t start = clock();
   __m128i _127 = _mm_set1_epi32(127); // This is a vector with 127s in it... Why might you need this?
   long long int result = 0; // This is where you should put your final result!
   /* DO NOT MODIFY ANYTHING ABOVE THIS LINE (in this function) */

   for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
      __m128i sum_vec = _mm_setzero_si128();
      for(unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4) {
         __m128i curr = _mm_loadu_si128((__m128i *)(vals + i));   // &vals[i]
         //__m128i compare = _mm_cmpgt_epi32(curr, _127);    // vals[i] > 127
         //__m128i anded = _mm_and_si128(curr, compare);     // vals[i] & (vals[i] > 127)
         //sum_vec = _m_add_epi32(sum_vec, anded);

         sum_vec = _mm_add_epi32(sum_vec, _mm_and_si128(curr, _mm_cmpgt_epi32(curr, _127)));
      }
      int intermediate[4];
      _mm_storeu_si128((__m128i *)intermediate, sum_vec);
      result = result + intermediate[0] +intermediate[1] + intermediate[2] + intermediate[3];
      for (unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++) {
         if (vals[i] >= 128) {
            result += vals[i];
         }
      }
   }

   /* DO NOT MODIFY ANYTHING BELOW THIS LINE (in this function) */
   clock_t end = clock();
   printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
   return result;
}

long long int sum_simd_unrolled(int vals[NUM_ELEMS]) {
   clock_t start = clock();
   __m128i _127 = _mm_set1_epi32(127);
   long long int result = 0;
   /* DO NOT MODIFY ANYTHING ABOVE THIS LINE (in this function) */

   for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
      /* YOUR CODE GOES HERE */
      /* Copy your sum_simd() implementation here, and unroll it */
      __m128i sum_vec = _mm_setzero_si128();

      for(unsigned int i = 0; i < NUM_ELEMS / 16 * 16; i += 16) {
         __m128i curr = _mm_loadu_si128((__m128i *)(vals + i));
         sum_vec = _mm_add_epi32(sum_vec, _mm_and_si128(curr, _mm_cmpgt_epi32(curr, _127)));

         curr = _mm_loadu_si128((__m128i *)(vals + i + 4));
         sum_vec = _mm_add_epi32(sum_vec, _mm_and_si128(curr, _mm_cmpgt_epi32(curr, _127)));

         curr = _mm_loadu_si128((__m128i *)(vals + i + 8));
         sum_vec = _mm_add_epi32(sum_vec, _mm_and_si128(curr, _mm_cmpgt_epi32(curr, _127)));

         curr = _mm_loadu_si128((__m128i *)(vals + i +12));
         sum_vec = _mm_add_epi32(sum_vec, _mm_and_si128(curr, _mm_cmpgt_epi32(curr, _127)));
         /* Hint: you'll need 1 or maybe 2 tail cases here. */
      }
      int intermediate[4];
      _mm_storeu_si128((__m128i *)intermediate, sum_vec);
      result = result + intermediate[0] +intermediate[1] + intermediate[2] + intermediate[3];
      for (unsigned int i = NUM_ELEMS / 16 * 16; i < NUM_ELEMS; i++) {
         if (vals[i] >= 128) {
            result += vals[i];
         }
      }
   }

   /* DO NOT MODIFY ANYTHING BELOW THIS LINE (in this function) */
   clock_t end = clock();
   printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
   return result;
}
