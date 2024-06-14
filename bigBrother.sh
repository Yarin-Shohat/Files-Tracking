#!/bin/bash

############### FIRST RUN ###############
path="$1"
pwd_dir=$PWD
script_path="$(cd "$(dirname "$0")" && pwd)"

# Check if this is the first time
if [ ! -d ".data" ] ; then
	# Check that we got path at least
	if [ "$#" -eq 0 ] ; then
		echo "Must include valid path" >&2
		exit
	fi
	# Check if the path ia valid
	if [ ! -d "$path" ] ; then
		echo "Must include valid path" >&2
		exit
	fi
	# Remove / from the end of the path
	if [[ "$path" == */ ]] ; then
		path="${path%/}"
	fi
	# Check if the path is full or part
	if [[ "$path" = /* ]] ; then
		# Full path
		echo "$path" > .path
	else
		# Part path
		echo "$pwd_dir/$path" > .path
	fi
	# Save the full path
	full_path=$( cat .path )
	
	# Print hello messege
	echo "Welcome to the Big Brother" >&1
	# Create data folder to save data
	mkdir .data
	# Get the given args
	recived_args=($@)
	cd "$full_path"
	
	if [ "$#" -gt 1 ] ; then # If given args track them
		# Take the given args to track and save
		names_to_track=("${recived_args[@]:1}")
	else
		# Else: follow all - dont create list file
		names_to_track=($( ls -1 | grep -vE ".data" | grep -vE "bigBrother.sh" | grep -vE ".path" ))
	fi
	# Save thhe names in list file
	cd "$script_path/.data"
	touch list
	> list # Clear file
	# Fill list file with the names of the files we will track
	for name in "${names_to_track[@]}" ; do
		echo "$name" >> list
	done
	
	# Create logs to save data about files
	touch Folder_Exist
	touch File_Exist
	> Folder_Exist
	> File_Exist
	# Number of lines - names to track on them
	arg_num=$( wc -l < list )
	
	# Check every name in file list	
	for (( i=1 ; i<=$arg_num ; i+=1 )) ; do
		p="p"
		name=$( sed -n "$i$p" list )
		if [ -e "$full_path/$name" ] ; then
			# Exist!
			if [ -d "$full_path/$name" ] ; then
			# Its a Folder
				echo $name >> Folder_Exist
			fi
			if [ -f "$full_path/$name" ] ; then
			# Its a File
				echo $name >> File_Exist
			fi
		fi
	done
	
	if [ "$#" -eq 1 ] ; then # If no args given we will track all, no need list
		rm list
		touch ALL
	fi
############### END FIRST RUN ###############
else
############### SECOND+ RUN ###############
	# Get paths
	script_path="$(cd "$(dirname "$0")" && pwd)"
	path=$( cat .path )
	
	# Get names of the files that exist in the spy_on folder
	cd "$path"
	existing_files=($( ls -1 | grep -vE ".data" | grep -vE "bigBrother.sh" | grep -vE ".path" ))
	sort_existing_files=($(printf '%s\n' "${existing_files[@]}" | sort ))
	
	# ARRAY: ${sort_existing_files[@]}
	cd "$script_path/.data"
	touch existing_files_txt
	
	# Save in array which files and folder we have
	readarray -t Folder_Exist_Arr < Folder_Exist
	readarray -t File_Exist_Arr < File_Exist
	
	# Check who we will track
	if [ -f list ] ; then
	# If has list, get the data to have the names to track on
		readarray -t list_arr < list
	else
	# Else we will track all
		list_arr=(${existing_files[@]})
		list_arr+=(${Folder_Exist_Arr[@]})
		list_arr+=(${File_Exist_Arr[@]})
	fi
	sort_list_arr=($(printf '%s\n' "${list_arr[@]}" | sort ))

	# Start checking the files
	###### Check Folders ######
	for file in "${sort_list_arr[@]}" ; do
		if [[ $( echo "${sort_existing_files[@]}" | fgrep -w "$file" ) ]] ; then
		# Folder Exist and in the list
			if [ -d "$path/$file" ] ; then
			# Its a Folder
				if [[ ! $( echo "${Folder_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then 
				# Check if we didnt report that the FOLDER exist
					echo "Folder added: $file" >&1
					echo $file >> Folder_Exist
				fi
			else
				# Folder Dont Exist and in the list
				if [[ $( echo "${Folder_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then
				# Check if someone DELETE the Folder
					echo "Folder deleted: $file" >&2
					sed -i "/^$file$/d" Folder_Exist
				fi
			fi
		else
		# Folder Dont Exist and in the list
			if [[ $( echo "${Folder_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then
			# Check if someone DELETE the Folder
				echo "Folder deleted: $file" >&2
				sed -i "/^$file$/d" Folder_Exist
			fi
		fi
	done
	###### Check Files ######
		for file in "${sort_list_arr[@]}" ; do
		if [[ $( echo "${sort_existing_files[@]}" | fgrep -w "$file" ) ]] ; then
		# File Exist and in the list
			if [ -f "$path/$file" ] ; then
			# Its a File
				if [[ ! $( echo "${File_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then 
				# Check if we didnt report that the FILE exist
					echo "File added: $file" >&1
					echo $file >> File_Exist
				fi
			else
				if [[ $( echo "${File_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then
				# Check if someone DELETE the File
					echo "File deleted: $file" >&2
					sed -i "/^$file$/d" File_Exist
				fi
			fi
		else
			if [[ $( echo "${File_Exist_Arr[@]}" | fgrep -w "$file" ) ]] ; then
			# Check if someone DELETE the File
				echo "File deleted: $file" >&2
				sed -i "/^$file$/d" File_Exist
			fi
		fi
	done
fi

