#!/bin/sh
#
# versionate.sh	
#
#     Injects version information into a variety of different language source files.
#
# (c) Copyright 2008, Christopher J. McKenzie under
#     the terms of the GNU Public License, incorporated
#     herein by reference.
#
# To ignore versionate, have this string in the file (documented below)
#
# NOVERSIONATE
#

C_Extensions=".c .cpp .cxx .h .hpp"
C_String=\\/\\*VERSIONATE\\*\\/
C_StartString=\\/\\*BEGIN_VERSIONATE\\*\\/
C_EndString=\\/\\*END_VERSIONATE\\*\\/

JS_Extensions=".js"
JS_String=\\/\\*VERSIONATE\\*\\/
JS_StartString=\\/\\*BEGIN_VERSIONATE\\*\\/
JS_EndString=\\/\\*END_VERSIONATE\\*\\/

PERL_Extensions=".pl .cgi"
PERL_String=\#VERSIONATE
PERL_StartString="="
PERL_EndString=\#VERSIONATE

PYTHON_Extensions=".py"
PYTHON_String=\#VERSIONATE
PYTHON_StartString=\#VERSIONATE
PYTHON_EndString=\#VERSIONATE

PHP_Extensions=".php"
PHP_String=\#VERSIONATE
PHP_StartString=\#VERSIONATE
PHP_EndString=\#VERSIONATE

RUBY_Extensions=".rb"
RUBY_String=\#VERSIONATE
RUBY_StartString="="
RUBY_EndString=\#VERSIONATE

SHELL_Extensions=".sh .bash"
SHELL_String=\#VERSIONATE
SHELL_StartString="="
SHELL_EndString=\#VERSIONATE

if [ $# = "0" ] || [ $1 = "--help" ] ; then 
	echo $0" (Major) (Minor) (Start year) (Directory)"
	echo "	Major - The major version number"
	echo "	Minor - The minor version number"
	echo "	Start year - The starting year of the project for the amount of days elapsed"
	echo "	Directory - The source directory to versionate"
	echo 
	echo " To avoid being versionated, have the string NOVERSIONATE somewhere in the file"
	echo
	echo "C/C++ Example: ("$C_Extensions")"
	echo "  Before: #define VERSION /*VERSIONATE*/"
	echo "  After:  #define VERSION /*BEGIN_VERSIONATE*/\"1.2.123\"/*END_VERSIONATE*/"
	echo
	echo "Perl Example: ("$PERL_Extensions")"
	echo "  Before: my \$Version = #VERSIONATE"
	echo "  After:  my \$Version = \"1.2.123\"#VERSIONATE"
	echo
	echo "Python Example: ("$PYTHON_Extensions")"
	echo "  Before: my \$Version = #VERSIONATE"
	echo "  After:  my \$Version = \"1.2.123\"#VERSIONATE"
	echo
	echo "PHP Example: ("$PHP_Extensions")"
	echo "  Before: \$Version = /*VERSIONATE*/"
	echo "  After:  \$Version = /*BEGIN_VERSIONATE*/\"1.2.123\"/*END_VERSIONATE*/"
	echo
	echo "Ruby Example: ("$RUBY_Extensions")"
	echo "  Before: Version = #VERSIONATE" 
	echo "  After:  Version = \"1.2.123\"#VERSIONATE"
	echo
	echo "BASH shell example: ("$SHELL_Extensions")"
	echo "  Before: Version = #VERSIONATE"
	echo "  After:  Version = \"1.2.123\"#VERSIONATE"
	echo
	exit
fi
[ $# -gt 0 ] && Major=$1 || Major=0
[ $# -gt 1 ] && Minor=$2 || Minor=0
StartYear=$3
[ $# -gt 3 ] && Directory=$4 || Directory=.

ComputeDays ()
{
	CurrentYear=`date +%Y`
	CurrentDay=`date +%j`

	if [ "$StartYear" -gt "$CurrentYear" ]; then
		echo "Fatal Error: The start year provided ($StartYear) is in the future. Current year is $CurrentYear."
		exit -1
	fi
	if [ "$StartYear" -lt "1970" ]; then
		echo "Fatal Error: The start year provided ($StartYear) is less then the Epoch (1970)."
		exit -1
	fi

	YearsDiff=$(($CurrentYear - $StartYear))
	LeapYears=$(( ( ($YearsDiff - 1) + ( $StartYear % 4 )) / 4))
	DaysElapsed=$(( $CurrentDay + $LeapYears + $YearsDiff * 365 ))
}

ComputeDays 
Version=\"$1"."$2"."$DaysElapsed\"
echo Version to Use is $Version
echo

generic_replace()
{
	echo "Searching "$Extensions
	fileCount=0
	foundFiles=""
	for n in $Extensions; do
		foundFiles=$foundFiles" "`find $Directory -type f -name \*$n`
	done
	for n in $foundFiles; do
		((fileCount++))
		fname=$0.$$
		versionate_count=`grep VERSIONATE $n | wc -l`
		noversionate_count=`grep NOVERSIONATE $n | wc -l`

		if [ $versionate_count -gt "0" ] && [ $noversionate_count -eq "0" ]; then
			[ -f /tmp/$fname ] && rm /tmp/$fname
			cat $n | sed s/"$StartString".\*"$EndString"/"$StartString"$Version"$EndString"/g | sed s/"$String"/"$StartString"$Version"$EndString"/g  > /tmp/$fname
			if [ -f /tmp/$fname ]; then
				# protective measure
				lines=`wc -l /tmp/$fname | awk ' { print $1 } '`
				if [ "$lines" -gt "0" ]; then
					echo " "Versionating $n at $versionate_count line\(s\)
					mv /tmp/$fname $n
				fi
			fi
		fi
	done
	if [ "$fileCount" -eq "0" ]; then
		echo " None Found!"
	fi
}

# C
Extensions="$C_Extensions"
StartString=$C_StartString
String=$C_String
EndString=$C_EndString
generic_replace

# JS
Extensions="$JS_Extensions"
StartString=$JS_StartString
String=$JS_String
EndString=$JS_EndString
generic_replace

# Perl
Extensions=$PERL_Extensions
StartString=$PERL_StartString
String=$PERL_String
EndString=$PERL_EndString
generic_replace

# Python
Extensions=$PYTHON_Extensions
StartString=$PYTHON_StartString
String=$PYTHON_String
EndString=$PYTHON_EndString
generic_replace

# PHP
Extensions=$PHP_Extensions
StartString=$PHP_StartString
String=$PHP_String
EndString=$PHP_EndString
generic_replace

# Ruby
Extensions=$RUBY_Extensions
StartString=$RUBY_StartString
String=$RUBY_String
EndString=$RUBY_EndString
generic_replace

# Bash
Extensions=$SHELL_Extensions
StartString=$SHELL_StartString
String=$SHELL_String
EndString=$SHELL_EndString
generic_replace
