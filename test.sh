#!/usr/bin/env bash

source $MY_OPT_DIR/prepend.sh

Z="$(tput sgr0)" # Reset
R="$(tput setaf 1)" # Red
G="$(tput setaf 2)" # Green

test () {
	SILENT=true
	TEST=$1
	prepend_path TEST "a" "a"
	if [ "$TEST" = "$2" ]; then
		echo "[${G}PASS${Z}] '$1' -> '$2'"
	else
		echo "[${R}FAIL${Z}] '$1' -> '$TEST' (expected: '$2')"
	fi
}

test "" "a:"
test "a" "a"
test "aba" "a:aba"
test "a:aba" "a:aba"
test "a:a" "a"
test "a:a:a" "a"
test "a:a:a:a" "a"
test "a:a:a:a:a" "a"

test "ab:a:ba" "a:ab:ba"
test "a:aba:a" "a:aba"
test "ba:a:ab" "a:ba:ab"

test ":" "a::"
test ":a" "a:"
test ":a:" "a::"
test "a:a:" "a:"
test "a::a" "a:"
test ":a:a" "a:"

test " " "a: "
test " a " "a: a "
