/*
 * Copyright (C) 2018-2022 David C. Harrison. All rights reserved.
 *
 * You may not use, distribute, publish, or modify this code without 
 * the express written permission of the copyright holder.
 */

#include "radix.h"
#include <iostream>
#include <thread>
#include <mutex>

// Function to calculate the MSD of the
// maximum  value in the array
int get_max_exp(std::vector<unsigned int> arr)
{
    // Stores the maximum element
    unsigned int mx = arr.front();
    // Traverse the given array
    for (auto i : arr) {
        // Update the value of maximum
        mx = i > mx ? i : mx;
    }

    int exp = 1;
    while (mx > 10) {
        mx /= 10;
        exp *= 10;
    }

    // Return the resultant value
    return exp;
}

void msd_sort(struct node* root, int exp, std::vector<unsigned int>& sorted_arr, int line)
{
    int64_t j;
    // Stores the numbers in different
    // buckets according their MSD
    for (auto i : root->arr) {
        // Get the MSD in j
        j = i;
        //std::cerr << j << std::endl;
        while (j < line) {
            j *= 10;
        }
        j = (j / exp) % 10;
        //std::cerr << j << std::endl;
        // If j-th index in the node
        // array is empty create and
        // link a new node in index
        if (root->nxt[j] == NULL) {
            root->nxt[j] = new_node();
        }

        // Store the number in j-th node
        root->nxt[j]->arr.push_back(i); 
    }

    // Sort again every child node that
    // has more than one number
    for (int i = 0; i < 10; i++) {

        // If root->next is NULL
        if (root->nxt[i] == NULL) {
            continue;
        }

        if (root->nxt[i]->arr.size() > 1) {
            // Sort recursively
            msd_sort(root->nxt[i], exp / 10, sorted_arr, line);
        }

            // If any node have only
            // one number then it means
            // the number is sorted
        else {
            sorted_arr.push_back(root->nxt[i]->arr.front());
        }
    }
}

/*
// Function to print an array
void print(std::vector<unsigned int> arr)
{
    for (auto i : arr)
        std::cerr << i << std::endl;

    //std::cerr << std::endl;
}
*/



void RadixSorter::sequentialMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists)
{ 
  for(auto& i : lists){
    struct node* root = new_node();
    root->arr = i.get();
    unsigned int exp = get_max_exp(root->arr);
    std::vector<unsigned int> sorted_arr;
    msd_sort(root, exp, sorted_arr, exp);
    i.get() = sorted_arr;
    //print(i);
  }
}
    
void RadixSorter::embarrassinglyParallelMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
  const unsigned int cores)
{
    /*
    std::mutex m;
    std::vector<std::thread> parallel;
    for(auto& i : lists){
        parallel.push_back(std::thread([&]{
            struct node* root = new_node();
            root->arr = i.get();
            unsigned int exp = get_max_exp(root->arr);
            std::vector<unsigned int> sorted_arr;
            msd_sort(root, exp, sorted_arr, exp);
            i.get() = sorted_arr;
        }));
    }

    for(auto& j : parallel){
        j.join();
    }
    */

   int size = lists.size();
    std::vector<std::thread> parallel;
    for(unsigned int j = 0; j < cores; j++){
        //std::cerr << i << std::endl;
        parallel.push_back(std::thread([&]{
            for(int i = j; i < size; i = i + cores){
                struct node* root = new_node();
                root->arr = lists[i].get();
                unsigned int exp = get_max_exp(root->arr);
                std::vector<unsigned int> sorted_arr;
                msd_sort(root, exp, sorted_arr, exp);
                lists[i].get() = sorted_arr;
            }
        }));

    }
    //std::cerr << parallel.size() << "!" << std::endl;
    for(auto& k : parallel){
        k.join();
    }


}

void RadixSorter::trulyParallelMSD(
  std::vector<std::reference_wrapper<std::vector<unsigned int>>> &lists, 
  unsigned int cores) 
{ 
    std::mutex m;
    std::vector<std::thread> parallel;
    for(auto& i : lists){

        parallel.push_back(std::thread([&]{
            struct node* root = new_node();
            root->arr = i.get();
            unsigned int exp = get_max_exp(root->arr);
            std::vector<unsigned int> sorted_arr;
            msd_sort(root, exp, sorted_arr, exp);
            i.get() = sorted_arr;
        }));
    }

    for(auto& j : parallel){
        j.join();
    }
}
