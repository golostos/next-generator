#!/bin/bash

name=$1
if [ ! -n "$1" ]
then
  read -p 'Enter the name of new app [skip for the default name: frontend]: ' project
  if [ ! -n "$project" ]
  then
    name=frontend
  else
    name=$project
  fi
fi

curl https://codeload.github.com/mui/material-ui/tar.gz/master | tar -xz --strip=2  material-ui-master/examples/nextjs-with-typescript
mv nextjs-with-typescript $name
cd $name && npm pkg set name="$name"

echo "Set version of the packages"
arrayDeps=( $(npm pkg get dependencies | sed -n "/{/,/}/{s/\"[[:blank:]]*:[^:]*//p;}" | sed -n "s/\"//p") )
for i in "${arrayDeps[@]}"
do
  version=`npm view $i version`
	echo "$i@^$version"
  npm pkg set dependencies.$i="^$version"
done

arrayDevDeps=( $(npm pkg get devDependencies | sed -n "/{/,/}/{s/\"[[:blank:]]*:[^:]*//p;}" | sed -n "s/\"//p") )
for i in "${arrayDevDeps[@]}"
do
  version=`npm view $i version`
	echo "$i@^$version"
  npm pkg set devDependencies.$i="^$version"
done

cd ..

FILE=package.json
if test -f "$FILE"; then
  echo "Dependencies installation"
  npm pkg set workspaces[]="$name"
  npm i -w $name
else
  echo "Dependencies installation in the workspace"
  cd $name && npm i
fi
