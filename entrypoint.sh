#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo "-------- PHP files:"
git diff --name-only --diff-filter=ACMRTUXB origin/${GITHUB_BASE_REF}..origin/${GITHUB_HEAD_REF} | grep -E \.php$
echo "--------"

if [ "${INPUT_ONLY_SNIFF_DIFF}" = true ]; then
	php vendor/bin/phpcs --standard=${INPUT_STANDARD} --extensions=php --report=checkstyle -q $(git diff --name-only --diff-filter=ACMRTUXB origin/${GITHUB_BASE_REF}..origin/${GITHUB_HEAD_REF} | grep -E \.php$) \
	| reviewdog -name=PHP_CodeSniffer -f=checkstyle -reporter=${INPUT_REPORTER} -level=${INPUT_LEVEL} -diff='git diff'
else
	php vendor/bin/phpcs --standard=${INPUT_STANDARD} --extensions=php --report=checkstyle -q ${INPUT_TARGET_DIRECTORY} \
	| reviewdog -name=PHP_CodeSniffer -f=checkstyle -reporter=${INPUT_REPORTER} -level=${INPUT_LEVEL} -diff='git diff'
fi
