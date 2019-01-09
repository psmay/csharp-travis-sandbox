#!/bin/bash

if [ "-$GITHUB_DOC_REPO_OWNER-" = "--" ]; then
	echo GITHUB_DOC_REPO_OWNER is not set. >&2
	exit 2
fi

if [ "-$GITHUB_DOC_REPO-" = "--" ]; then
	echo GITHUB_DOC_REPO is not set. >&2
	exit 3
fi

if [ "-$GITHUB_DOC_GENERATION_TOKEN-" = "--" ]; then
	echo GITHUB_DOC_GENERATION_TOKEN is not set. >&2
	exit 4
fi

if [ "-$DOCFX_PROJECT_DIR-" = "--" ]; then
	echo DOCFX_PROJECT_DIR is not set. >&2
	exit 5
fi

if [ "-$GITHUB_DOC_COMMIT_USER-" = "--" ]; then
	export GITHUB_DOC_COMMIT_USER="travis_ci_build"
fi
if [ "-$GITHUB_DOC_COMMIT_EMAIL-" = "--" ]; then
	export GITHUB_DOC_COMMIT_EMAIL="travis_ci_build@invalid.invalid"
fi

git_commit_if_changed () {
	# Prevent a failed exit if the repo turns out to be unchanged.
	# https://stackoverflow.com/questions/8123674/how-to-git-commit-nothing-without-an-error
	git diff-index --quiet HEAD || git commit "$@"
}

PAGES_BRANCH=gh-pages
PAGES_REPO_DIR=pages_repo
SITE_DEST_IN_REPO="$PAGES_REPO_DIR/docfx"

GITHUB_DOC_REPO_URL_WITH_TOKEN="https://$GITHUB_DOC_REPO_OWNER:$GITHUB_DOC_GENERATION_TOKEN@github.com/$GITHUB_DOC_REPO_OWNER/$GITHUB_DOC_REPO.git"

DOC_PUSH_TEMP_DIR="`mktemp -d`" &&
cd "$DOC_PUSH_TEMP_DIR" &&

# Get pages repo and config commit user
git clone "$GITHUB_DOC_REPO_URL_WITH_TOKEN" -b $PAGES_BRANCH $PAGES_REPO_DIR -q &&
cd $PAGES_REPO_DIR &&
git config user.email "$GITHUB_DOC_COMMIT_EMAIL" &&
git config user.name "$GITHUB_DOC_COMMIT_USER" &&
cd .. &&

# Clobber existing site dir and replace with new one
rm -rf $SITE_DEST_IN_REPO &&
cp -a "$DOCFX_PROJECT_DIR/_site" $SITE_DEST_IN_REPO &&

# Commit and push
cd $PAGES_REPO_DIR &&
git add -A &&
git_commit_if_changed -m "Update from CI #$TRAVIS_BUILD_NUMBER, branch $TRAVIS_BRANCH" -q &&
git push origin $PAGES_BRANCH -q
