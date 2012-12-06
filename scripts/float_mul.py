#! /usr/bin/env python

import sys

def convert_str(s):
	try:
		num=int(s)
	except ValueError:
		num=float(s)
	return num

def main(argv = None):
	if argv == None:
		argv = sys.argv

	num1 = convert_str(argv[1])
	num2 = convert_str(argv[2])
	s = str(int(round(num1 * num2)))
	print s
	return 0

if __name__ == '__main__':
	sys.exit(main())
