#!/bin/sh

Red="\033[0;31m"    # Red
Green="\033[0;32m"  # Green
BICyan="\033[1;96m" # Bold Cyan
Color_Off="\033[0m" # Text Reset

# Get the current version
VERSION=$(node -p "require('./package.json').version")
TAG_NAME="v$VERSION"
PACKAGE_FILE="anythink-ltd-react-kanban-$VERSION.tgz"

# Check if the package file exists
if [ ! -f "$PACKAGE_FILE" ]; then
  printf "\n\n$Red$(echo Package file $PACKAGE_FILE not found. Run ./scripts/clean-build.sh first.)$Color_Off\n\n"
  exit 1
fi

# Create a git tag if it doesn't exist
printf "\n\n$BICyan$(echo Creating git tag $TAG_NAME...)$Color_Off\n\n"
git tag -a "$TAG_NAME" -m "Release $TAG_NAME" 2>/dev/null || echo "Tag $TAG_NAME already exists"

# Push the tag to GitHub
printf "\n\n$BICyan$(echo Pushing tag to GitHub...)$Color_Off\n\n"
git push origin "$TAG_NAME"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  printf "\n\n$Red$(echo GitHub CLI (gh) is not installed. Please install it to create releases.)$Color_Off\n\n"
  printf "\n\n$BICyan$(echo You can manually create a release on GitHub and upload the package file $PACKAGE_FILE)$Color_Off\n\n"
  exit 1
fi

# Create a GitHub release
printf "\n\n$BICyan$(echo Creating GitHub release...)$Color_Off\n\n"
gh release create "$TAG_NAME" \
  --title "Release $TAG_NAME" \
  --notes "React Kanban component release $TAG_NAME" \
  "$PACKAGE_FILE"

if [ $? != 0 ]; then
  printf "\n\n$Red$(echo Failed to create GitHub release.)$Color_Off\n\n"
  exit 1
fi

printf "\n\n$Green$(echo Successfully published $TAG_NAME to GitHub!)$Color_Off\n\n"
printf "\n\n$BICyan$(echo You can now use this package in your projects with:)$Color_Off\n\n"
printf "\"@anythink-ltd/react-kanban\": \"https://github.com/Anythink-Ltd/react-kanban/releases/download/$TAG_NAME/$PACKAGE_FILE\"\n\n" 