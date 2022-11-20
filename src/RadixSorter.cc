/*
 * Copyright (C) 2018-2022 David C. Harrison. All rights reserved.
 *
 * You may not use, distribute, publish, or modify this code without 
 * the express written permission of the copyright holder.
 */

#include "radix.h"

// Function to calculate the MSD of the
// maximum  value in the array
int get_max_exp(std::vector<unsigned int> arr)
{
    // Stores the maximum element
    int mx = arr[0];

    // Traverse the given array
    for (int i = 1; i < arr.size(); i++) {

        // Update the value of maximum
        if (arr[i] > mx) {
            mx = arr[i];
        }
    }

    int exp = 1;

    while (mx > 10) {
        mx /= 10;
        exp *= 10;
    }

    // Return the resultant value
    return exp;
}

void msd_sort(struct node* root, int exp,
    std::vector<unsigned int>& sorted_arr, int line)
{
    if (exp <= 0) {
        return;
    }
    int j;
    // Stores the numbers in different
    // buckets according their MSD
    for (int i = 0;
        i < root->arr.size();
        i++) {

        // Get the MSD in j
        j = root->arr[i];

        while (j < line) {
            j *= 10;
        }
        j = (j / exp) % 10;

        // If j-th index in the node
        // array is empty create and
        // link a new node in index
        if (root->nxt[j] == NULL) {
            root->nxt[j] = new_node();
        }

        // Store the number in j-th node
        root->nxt[j]->arr.push_back(
            root->arr[i]); 
    }

    // Sort again every child node that
    // has more than one number
    for (int i = 0; i < 10; i++) {

        // If root->next is NULL
        if (root->nxt[i] != NULL) {

            if (root->nxt[i]->arr.size() > 1) {

                // Sort recursively
                msd_sort(root->nxt[i],
                    exp / 10,
                    sorted_arr, line);
            }

            // If any node have only
            // one number then it means
            // the number is sorted
            else {
                sorted_arr.push_back(
                    root->nxt[i]->arr[0]);
            }
        }
    }
}

void RadixSorter::sequentialMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists)
{ 
  int size = lists.size();
  for(auto i : lists){
    struct node* root = new_node();
    root->arr = i.get();
    int exp = get_max_exp(root->arr);
    std::vector<unsigned int> sorted_arr;
    msd_sort(root, exp, sorted_arr, exp);
    i.get() = sorted_arr;
  }

}
    
void RadixSorter::embarrassinglyParallelMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
  const unsigned int cores)
{

}

void RadixSorter::trulyParallelMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
  unsigned int cores) 
{ 
}
