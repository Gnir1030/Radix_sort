#!/bin/bash

#######################################################################
#
# Copyright (C) 2018-2022 David C. Harrison. All right reserved.
#
# You may not use, distribute, publish, or modify this code without 
# the express written permission of the copyright holder.
#
#######################################################################

if [ "$#" -ne 1 ]; then
  echo "USAGE: ./perf.sh numbers"
  exit;
fi
num=$1
attempts=3

speedup() {
  num=$1
  lists=$2
  cores=$3
  type=$4
  pct=$5

  req=`echo "1 * $pct" | bc -l`

  ./perf $num $lists $cores $type > radix.single &
  pid=$!

  cmax=0
  single=true
  while true
  do
    cat /proc/$pid/status > radix.threads 2>/dev/null
    status=$?
    if [ $status -ne 0 ]
    then
      break
    fi

    grep "Generate time:" radix.single >/dev/null
    if [ $? -eq 0 ]
    then
      threads=`cat radix.threads | grep Threads | awk '{print $2'}`
      cmax=$(( threads > cmax ? threads : cmax ))
      grep "Single Elapsed" radix.single >/dev/null
      if [ $? -eq 0 ]
      then
        if [ "$single" = "true" ] 
        then
          if [ $cmax -gt 2 ]
          then 
            (( cmax -= 1 ))
            echo ""
            echo -n "Speedup lists: $lists cores: $cores required: $req% "
            echo "FAIL ( too many cores on single test: $cmax )"
            return
          else
            single=false;
          fi
        fi
        echo -n .
      else
        echo -n ^
      fi
    else
      echo -n -
    fi

    sleep 0.04
  done

  echo ""
  # cat radix.single

  echo -n "Speedup lists: $lists cores: $cores required: $req% "

  fail=`grep FAIL radix.single | wc -l`
  pass=`grep PASS radix.single | wc -l`

  if [[ fail -gt 0 ]]
  then
    echo "FAIL ( functional - $fail failures )"
  else
    if [[ pass -gt 0 ]]
    then
      (( cmax -= 1 ))
      if [ $cmax -le $cores ]
      then
        speedup=`grep 'Speedup:' radix.single | awk '{print $2}' | sed 's/\%//'`
        printf "achieved: %.0f%% : " $speedup

        if (( $(echo "$speedup > $req" | bc -l) ))
        then
          echo "PASS"
        else
          (( attempts -= 1 ))
          if [[ attempts -gt 0 ]]
          then 
            echo "RETRY ( insufficient speedup )"
            speedup $num $lists $cores $type $pct
          else
            echo "FAIL ( insufficient speedup )"
          fi
        fi
      else
        echo "FAIL ( too many cores: $cmax, should have been no more than $cores )"
      fi
    else
      echo "FAIL ( functional - no passes )"
    fi
  fi
}

perf() {
  num=$1
  lists=$2
  cores=$3
  type=$4
  secs=$5

  ./radix $num $lists $cores $type > radix.single &
  pid=$!

  count=0
  cmax=0
  single=true
  while true
  do
    cat /proc/$pid/status > radix.threads 2>/dev/null
    status=$?
    if [ $status -ne 0 ]
    then
      break
    fi

    grep "Generate time:" radix.single >/dev/null
    if [ $? -eq 0 ]
    then
      threads=`cat radix.threads | grep Threads | awk '{print $2'}`
      cmax=$(( threads > cmax ? threads : cmax ))
      grep "Elapsed time:" radix.single >/dev/null
      if [ $? -eq 0 ]
      then
        (( cmax -= 1 ))
        if [ $cmax -gt $cores ]
        then 
          echo ""
          echo -n "Performance lists: $lists cores: $cores required: $secs seconds "
          echo "FAIL ( too many cores: $cmax, should have been no more than $cores )"
          return
        fi
      else
        echo -n ^
      fi
    else
      echo -n -
    fi

    count=`echo "scale=2; $count + 0.04" | bc -l`
    if (( $(echo "$count >= $secs" | bc -l) ))
    then
      kill -9 $pid
      echo ""
      echo -n "Performance lists: $lists cores: $cores required: $secs seconds "
      echo "FAIL ( insufficient speed )"
      return
    fi
    sleep 0.04
  done

  echo ""
  echo -n "Performance lists: $lists cores: $cores required: $secs seconds "

  fail=`grep FAIL radix.single | wc -l`
  pass=`grep PASS radix.single | wc -l`

  if [[ fail -gt 0 ]]
  then
    echo "FAIL ( functional - $fail failures )"
  else
    if [[ pass -gt 0 ]]
    then
      (( cmax -= 1 ))
      if [ $cmax -le $cores ]
      then
        elapsed=`grep 'Elapsed time:' radix.single | awk '{print $3}' | sed 's/\%//'`
        printf "achieved: %.0f seconds : " $elapsed

        if (( $(echo "$elapsed < $secs" | bc -l) ))
        then
          echo "PASS"
        else
          echo "FAIL ( insufficient speed )"
        fi
      else
        echo "FAIL ( too many cores: $cmax, should have been no more than $cores )"
      fi
    else
      echo "FAIL ( functional - no passes )"
    fi
  fi
}

check() {
  type=$1
  pass=`grep PASS absolute.out | wc -l`
  rm absolute.out
  if (( $(echo "$pass < 1" | bc -l) ))
  then
    echo "FAIL Insufficient "$type" Performance"
    exit
  fi
}

echo "###### Sequential Absolute Performance"
# One million in less than 10 seconds
perf 1000000 1 1 -s 10 | tee absolute.out
check "Sequential"

echo "###### Embarrassingly Parallel Absolute Performance"
# Two million in less than 10 seconds
perf 1000000 2 2 -e 10 | tee absolute.out
check "Embarrassingly Parallel"

echo "###### Embarrassingly Parallel Relative Performance"
attempts=3
speedup $num 8 8 -e 600
attempts=3
speedup $num 4 2 -e 190

echo "###### Tuuly Parallel Absolute Performance"
# One million in less than 5 seconds
perf 1000000 1 2 -t 5 | tee absolute.out
check "Truly Parallel"

echo "###### Truly Parallel Relative Performance"
attempts=3
speedup $num 1 8 -t 300
attempts=3
speedup $num 1 8 -t 300
attempts=3
speedup $num 1 16 -t 400

rm radix.single radix.quad radix.threads 2>/dev/null
