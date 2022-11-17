#######################################################################
#
# Copyright (C) 2018-2021 David C. Harrison. All rights reserved.
#
# You may not use, distribute, publish, or modify this code without 
# the express written permission of the copyright holder.
#
#######################################################################

################### DO NOT MODIFY THIS FILE ###########################
#
# It is not included in the subission archive ceated by 'make submit'.
#
# If you modify it and your code relies on those modifications, your code
# will not compile in the automated test harness and will be unable to
# execute any tests.
#
#######################################################################

CFLAGS = -g -Llib -Wall -Wextra -Iinclude -fno-exceptions -pthread
VFLAGS = --track-origins=yes --leak-check=full --show-leak-kinds=all
# C++ 20 via GCC 10 as 11 lcov is mildly broken
CC = g++-10 -std=c++20 

# Assignment No.
a = 7

HEADERS = $(wildcard include/*.h)
SRC = src
OBJ = obj
SRCFILES = $(wildcard $(SRC)/*.cc)
SRCOBJS = $(addprefix $(OBJ)/, $(notdir $(patsubst $(SRC)/%.cc, %.o, $(SRCFILES))))

all: clean radix mperf

unsetcov: 
	$(eval TCFLAGS := -Wall)

setcov: 
	$(eval TCFLAGS := --coverage)

radix: unsetcov $(SRCOBJS) 
	$(CC) $(CFLAGS) $(TCFLAGS) -o radix $(SRCOBJS) -lradix 2>&1 | tee cc.out
	@cat cc.out >> make.out

mperf: unsetcov $(SRCOBJS)
	$(CC) $(CFLAGS) $(TCFLAGS) -o perf $(SRCOBJS) -lperf 

test: clean setcov $(SRCOBJS)
	$(CC) $(CFLAGS) $(TCFLAGS) -o test $(SRCOBJS) -lradix 
	@-./test 128 1 1 -s
	@-./test 128 1 1 -e
	@-./test 256 3 2 -e
	@-./test 128 1 1 -t
	@-./test 256 3 2 -t
	@lcov --rc lcov_branch_coverage=1 -q --capture --directory obj --directory src --output-file coverage.info --no-external 2>/dev/null
	@genhtml coverage.info --branch-coverage --output-directory coverage

valgrind: clean radix
	valgrind $(VFLAGS) ./radix 128 1 1 -s 1>/dev/null 2>valgrind.out
	valgrind $(VFLAGS) ./radix 128 3 2 -e 1>/dev/null 2>>valgrind.out
	valgrind $(VFLAGS) ./radix 128 3 2 -t 1>/dev/null 2>>valgrind.out
	@tail valgrind.out
	@echo "****************************************"
	@echo "***** See valgrind.out for details *****"
	@echo "****************************************"

$(OBJ)/%.o: $(SRC)/%.cc $(HEADERS)
	$(CC) $(CFLAGS) $(TCFLAGS) -c $< -o $@ 2>&1 | tee cc.out
	@cat cc.out >> make.out

check: radix
	@./check.sh 50000

perf: mperf
	@./perf.sh 500000

grade: clean radix mperf 
	@./grade.sh $a 

clean:
	@rm -rf test radix perf cc.out make.out valgrind.out obj/* coverage/*

submit: clean
	@echo ""
	@echo "#### Only these file are submitted:"
	@echo ""
	@tar czvf ~/CSE111-Assignment$(a).tar.gz src/*
	@echo ""
	@echo "##### Confirming submission is good..."
	@echo ""
	@./confirm.sh $(a)
	@echo ""
	@echo "#### If that failed, fix the problem and try again."
	@echo ""
	@echo "Finally, don't forget to upload ~/CSE111-Assignment$(a).tar.gz to Canvas!"
	@echo ""
