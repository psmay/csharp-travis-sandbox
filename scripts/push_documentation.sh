#!/bin/bash

. scripts/functions.bash

require_variable GITHUB_DOC_REPO_OWNER
require_variable GITHUB_DOC_REPO
require_variable GITHUB_DOC_GENERATION_TOKEN
require_variable DOCFX_PROJECT_DIR
default_variable GITHUB_DOC_COMMIT_USER travis_ci_build
default_variable GITHUB_DOC_COMMIT_EMAIL "travis_ci_build@invalid.invalid"
default_variable PAGES_BRANCH gh-pages
default_variable PAGES_REPO_DIR pages_repo

git_commit_if_changed () {
	# Prevent a failed exit if the repo turns out to be unchanged.
	# https://stackoverflow.com/questions/8123674/how-to-git-commit-nothing-without-an-error
	(
		git diff-index --quiet HEAD &&
		eecho 'No changes detected; skipping commit.'
	) || (
		eecho 'Changes detected; proceeding with commit.' &&
		git commit "$@"
	)
}

SITE_DEST_IN_REPO="$PAGES_REPO_DIR/docfx"

GITHUB_DOC_REPO_URL_WITH_TOKEN="https://$GITHUB_DOC_REPO_OWNER:$GITHUB_DOC_GENERATION_TOKEN@github.com/$GITHUB_DOC_REPO_OWNER/$GITHUB_DOC_REPO.git"

DOC_PUSH_TEMP_DIR="`mktemp -d`" &&
(
	cd "$DOC_PUSH_TEMP_DIR" &&

	# Get pages repo and config commit user
	git clone "$GITHUB_DOC_REPO_URL_WITH_TOKEN" -b $PAGES_BRANCH $PAGES_REPO_DIR -q &&
	(
		cd $PAGES_REPO_DIR &&
		git config user.email "$GITHUB_DOC_COMMIT_EMAIL" &&
		git config user.name "$GITHUB_DOC_COMMIT_USER"
	) &&

	# Clobber existing site dir and replace with new one
	rm -rf $SITE_DEST_IN_REPO &&
	cp -a "$DOCFX_PROJECT_DIR/_site" $SITE_DEST_IN_REPO &&

	# Commit and push
	(
		cd $PAGES_REPO_DIR &&
		git add -A &&
		git_commit_if_changed -m "Update from CI #$TRAVIS_BUILD_NUMBER, branch $TRAVIS_BRANCH" -q &&
		git push origin $PAGES_BRANCH -q
	)
)
