#!/bin/bash
echo "Welcome to the automated Aleks Multi Platfrom Git Commit With ToDoList Script"
echo "Also known as AMPGCWTS, a memorable acronym"
read -p "Insert your Git Comment:" gitcomment
SDdirInBF="/media/BigTank"
SDdirInAG="/mnt/Tank"
dirFoundFlag=0
if [ -e $SDdirInBF/cloud/Aleksology/SpaceEarsToDoList.md ]
then
	echo "ToDoList file found on Black Fortress"
	cp -v $SDdirInBF/cloud/Aleksology/SpaceEarsToDoList.md $SDdirInBF/gamedev/SpaceEars/ToDoList.md
	dirFoundFlag=1
	currentDir=$SDdirInBF
else
	echo "couldn't find Black Fortress folder"
fi
if [ -e $SDdirInAG/cloud/Aleksology/SpaceEarsToDoList.md ]
then
	echo "ToDoList file found on Aleks Go"
	cp -v $SDdirInAG/cloud/Aleksology/SpaceEarsToDoList.md $SDdirInAG/gamedev/SpaceEars/ToDoList.md
	dirFoundFlag=1
	currentDir=$SDdirInAG
else
	echo "couldn't find Aleks Go folder"
fi
if [ dirFoundFlag=1 ]
then
	echo "Starting Git Commit ..."
	cd $currentDir/gamedev/SpaceEars
	git add .
	git commit -m "$gitcomment"
	git push
else
	echo "Couldn't find a directory to commit from"
fi
