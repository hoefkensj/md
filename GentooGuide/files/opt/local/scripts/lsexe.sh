#!/usr/bin/env bash
# ##############################################################################
# # PATH: /opt/local/scripts/                     AUTHOR: Hoefkens.j@gmail.com #
# # FILE: lsexe.sh                                                             #
# ##############################################################################
#
function lscompgen()
{
	printf "################################################################################"
	compgen "${2}${3}"
	echo "############################################"
	}
case $1 in
	a*)
	lscompgen ALIASSES -a | sort |uniq
	;;
	b*)
	lscompgen BUILDINS -b|  sort |uniq
	;;
	c*)
	lscompgen COMMANDS -c | sort |uniq
	;;
	f*)
	lscompgen FUNCTIONS -A 'function' | sort |uniq
	;;
	k*)
	lscompgen KEYWORDS -k | sort |uniq
	;;
	*|A*)
	lsexe a
	lsexe b
	lsexe c
	lsexe f
	lsexe k
	echo "############# HELP #################"
	echo "use: $lsexe [a|b|c|f|k|A]"
	;;
esac