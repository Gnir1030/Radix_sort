/*
 * Copyright (C) 2018-2022 David C. Harrison. All rights reserved.
 *
 * You may not use, distribute, publish, or modify this code without 
 * the express written permission of the copyright holder.
 */

/******************  DO NOT MODIFY THIS FILE ****************************
 *
 * It is not included in the subission archive ceated by 'make submit' .
 *
 * If you modify it and your code relies on those modifications, your code
 * will not compile in the automated test harness and will be unable to
 * execute any tests.
 *
 * To put it another way, if you modify this file, you will get a big fat
 * ZERO on this assignment.
 *
 ************************************************************************/

#include <vector>
#include <functional>

/*
 * Radix Sorter with support for Most Significant Digit sorting only.
 *
 * Whilst the choice of sorting algorithnm is a matter or personal choice,
 * a bucket sort where each bucket is sorted in a different thread will almost 
 * certainly deliver the best results.
 */
struct node {
    std::vector<unsigned int> arr;
    struct node* nxt[10];
};

struct node* new_node(void)
{
    struct node* tempNode = new node;

    for (int i = 0; i < 10; i++) {
        tempNode->nxt[i] = NULL;
    }

    // Return the created node
    return tempNode;
}

class RadixSorter {
public:
  /*
   * Perform an in-place Most Significant Digit Radix Sort of each list of
   * unsigned integers in LISTS.
   */
  void sequentialMSD(
    std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists);
    
  /*
   * Perform an in-place Embarrassingly Parallel Most Significant Digit Radix 
   * Sort of each list of unsigned integer in LISTS using no more that CORES 
   * cpu cores.
   *
   * If asked to sort multiple lists, should sort them in aproximately the same
   * time as sorting one list. This suggests each list should be sorted in it's
   * own thread.
   */
  void embarrassinglyParallelMSD(
    std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
    const unsigned int cores);

  /*
   * Perform an in-place Truly Parallel Most Significant Digit Radix Sort on
   * each list of unsigned integer in LISTS using no more that CORES cpu cores.
   *
   * If allowed to use multiple cores, should sort a single large set of randomly
   * selected unsigned integers faster than a single threaded (sequential) sort 
   * of the same random set.
   * 
   * Whilst the choice of sorting algorithnm is a matter or personal choice, a 
   * bucket sort where each bucket is sorted in a different thread will almost 
   * certainly deliver the best results.
   */
  void trulyParallelMSD(
    std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
    const unsigned int cores);
private:

};
