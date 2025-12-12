#!/usr/bin/env bash
set -euo pipefail
flag() {
	for f in "$@"
		do [[ -e ".flags/$f" ]] || return 1
	done
}
scss="$(mktemp)"
trap "rm -f $scss" EXIT
sass style.scss --style=compressed > "$scss" 2>& 1 || :
export style="$(cat "$scss")"
export break="{{SPLIT}}"
ruby="$(mktemp)"
trap "rm -f $ruby" EXIT
./index.rb > $ruby
re() {
	a="[\S\s]*?"
	s="$(echo "$break" | perl -pe 's|([{}])|\\$1|g')"
	c="([\S\s]*?)"
	w="\s*"
	case $1 in
		html)r="$c$w$s$a";;
		md)r="$a$s$w$c";;
	esac
	perl -0777 -pe "s|^$r$|\$1|g"
}
cat $ruby | re html > index.html
cat $ruby | re md > README.md