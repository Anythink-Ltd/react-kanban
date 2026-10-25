#!/bin/sh

Red="\033[0;31m"    # Red
Green="\033[0;32m"  # Green
BICyan="\033[1;96m" # Bold Cyan
Color_Off="\033[0m" # Text Reset

# Create a clean build directory
printf "\n\n$BICyan$(echo Creating clean build directory...)$Color_Off\n\n"
rm -rf clean-build
mkdir -p clean-build

# Build the project
printf "\n\n$BICyan$(echo Building the project...)$Color_Off\n\n"

# Run TypeScript compiler
npx tsc -p tsconfig.build.json

if [ $? != 0 ]; then
  printf "\n\n$Red$(echo Build failed.)$Color_Off"
  exit 1
fi

# Fix paths
npx tscpaths -p tsconfig.json -s src -o dist

if [ $? != 0 ]; then
  printf "\n\n$Red$(echo Build failed.)$Color_Off"
  exit 1
fi

# Build CSS
yarn sass src/styles.scss dist/styles.css --no-source-map

if [ $? != 0 ]; then
  printf "\n\n$Red$(echo Build failed.)$Color_Off"
  exit 1
fi

# Copy necessary files to clean build directory
printf "\n\n$BICyan$(echo Copying files to clean build directory...)$Color_Off\n\n"
cp -r dist clean-build/
cp README.md clean-build/
cp LICENSE.txt clean-build/ 2>/dev/null || :

# Create a clean package.json without circular references
printf "\n\n$BICyan$(echo Creating clean package.json...)$Color_Off\n\n"
cat > clean-build/package.json << EOF
{
  "name": "@anythink-ltd/react-kanban",
  "version": "$(node -p "require('./package.json').version")",
  "description": "React Kanban component",
  "main": "dist/index.js",
  "files": [
    "dist"
  ],
  "repository": "https://github.com/Anythink-Ltd/react-kanban",
  "license": "MIT",
  "peerDependencies": {
    "react": ">=16",
    "react-dom": ">=16",
    "@hello-pangea/dnd": ">=16"
  },
  "homepage": "https://anythink-ltd.github.io/react-kanban"
}
EOF

# Create the package
printf "\n\n$BICyan$(echo Creating package...)$Color_Off\n\n"
cd clean-build
npm pack

# Move the package to the parent directory
mv anythink-ltd-react-kanban-*.tgz ../

printf "\n\n$Green$(echo Clean build completed successfully!)$Color_Off\n"
printf "\n\n$Green$(echo Package created: anythink-ltd-react-kanban-$(node -p "require('../package.json').version").tgz)$Color_Off\n\n" 