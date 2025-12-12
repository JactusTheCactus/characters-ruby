#!/usr/bin/env bash
set -euo pipefail
flag() {
	for f in "$@"
		do [[ -e ".flags/$f" ]] || return 1
	done
}
export style="$(sass style.scss --style=compressed)"
./index.rb > ruby.html
cat index.html | perl -pe '
	s|<!DOCTYPE html>||g;
' > README.md