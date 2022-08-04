#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo "-------- All files:"
git diff --name-only --diff-filter=ACMRTUXB origin/${GITHUB_BASE_REF}..origin/${GITHUB_HEAD_REF}
echo "-------- PHP files:"
git diff --name-only --diff-filter=ACMRTUXB origin/${GITHUB_BASE_REF}..origin/${GITHUB_HEAD_REF} | grep -E \.php$
echo "--------"

if [ "${INPUT_ONLY_SNIFF_DIFF}" = true ]; then
	php /usr/local/bin/phpcs.phar --standard=${INPUT_STANDARD} --extensions=php --report=sniff.xml
	cat sniff.xml
	cat sniff.xml | reviewdog -name=PHP_CodeSniffer -f=checkstyle -reporter=${INPUT_REPORTER} -level=${INPUT_LEVEL} -diff='git diff'
	#php /usr/local/bin/phpcs.phar --standard=${INPUT_STANDARD} --extensions=php --report=checkstyle -q $(git diff --name-only --diff-filter=ACMRTUXB origin/${GITHUB_BASE_REF}..origin/${GITHUB_HEAD_REF} | grep -E \.php$) \
	#| reviewdog -name=PHP_CodeSniffer -f=checkstyle -reporter=${INPUT_REPORTER} -level=${INPUT_LEVEL} -diff='git diff'
else
	php /usr/local/bin/phpcs.phar --standard=${INPUT_STANDARD} --extensions=php --report=checkstyle -q ${INPUT_TARGET_DIRECTORY} \
	| reviewdog -name=PHP_CodeSniffer -f=checkstyle -reporter=${INPUT_REPORTER} -level=${INPUT_LEVEL} -diff='git diff'
fi
