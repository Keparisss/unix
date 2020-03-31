#!/bin/bash -e

# запуск скрипта 
# перейти в каталог, в котором находится файл
# ввести ./build.sh src/main.cpp


ok=0;
notOk=1;

EMPTY_ARG="EMPTY_ARG"
READ_PERM_DENIED="READ_PERM_DENIED or FILE_NOT_FOUND"
NO_OUTPUT_SPECIFIED="NO_OUTPUT_SPECIFIED"

function clean() {
  printf "\nCleaning...";
  rm -rf $1;

  exit;
}

function validateFileName() {
	if [ -z $1 ]
		then
			printf $EMPTY_ARG;
			exit $notOk;
	fi

	if [ ! -r $1 ]
		then
			printf $READ_PERM_DENIED;
			exit $notOk;
	fi
}

validateFileName $1

tempDir=$(mktemp -d); # mktem	p - создает временную директорию
trap "clean $tempDir" EXIT SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM;

sourceFile=$(basename $1); # $1 - берет первый аргумент вызова
sourceFileDir=$(dirname $1);
outputFileName=$(cat $1 | sed -n '0,/.*Output: /s/.*Output: //p' | tr -d '\r'); # /p - выводит найденное выражение https://www.grymoire.com/Unix/Sed.html#uh-9

if [ -z $outputFileName ]
	then
		printf $NO_OUTPUT_SPECIFIED;
		exit;
fi

# | - труба, перенаправляет поток
# -n - использует только строку с найденным условием

cp $sourceFileDir/$sourceFile $tempDir; #cp - copy file to dir
g++ $tempDir/$sourceFile -o $tempDir/$outputFileName;

if [ $? -eq $ok ] # $? - код выполнения последней команды (g++)
then
	printf "Success \n";
	cp $tempDir/$outputFileName $sourceFileDir;
else
	printf "Compilation went wrong \n";
fi

