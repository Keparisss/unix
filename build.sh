#!/bin/bash

# запуск скрипта 
# перейти в каталог, в котором находится файл
# ввести ./build.sh src/main.cpp


ok=0;
notOk=1;

function clean() {
  printf "Cleaning... \n";
  rm -rf $1;

	printf "Exited with status: $2 \n";
  exit $2;
}

sourceFile=$(basename $1); # $1 - берет первый аргумент вызова
sourceFileDir=$(dirname $1);
outputFileName=$(cat $1 | sed -n 's/.*Output: //p' | tr -d '\r'); # /p - выводит найденное выражение https://www.grymoire.com/Unix/Sed.html#uh-9
# | - труба, перенаправляет поток
# -n - использует только строку с найденным условием

tempDir=$(mktemp -d); # mktemp - создает временную директорию

trap "clean $tempDir $ok" SIGINT SIGTERM;

cp $sourceFileDir/$sourceFile $tempDir; #cp - copy file to dir
g++ $tempDir/$sourceFile -o $tempDir/$outputFileName;

if [ $? -eq $ok ] # $? - код выполнения последней команды (g++)
then
	printf "Success \n";
	exitCode=$ok;
	cp $tempDir/$outputFileName $sourceFileDir;
else
	printf "Compilation went wrong \n";
	exitCode=$notOk;
fi

clean $tempDir $exitCode; # вызов функции с 2мя параметрами
