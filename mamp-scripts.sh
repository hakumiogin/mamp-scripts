## first install pv. "apt-get install pv" or "brew install pv"
## secondly, instaill the wp-cli.
## make sure the mysql command is working and connected to your local XAMPP/MAMP
## The easiest way to to add an alias, like I did below for the path to your local database install.
## for windows, I think it would look like: alias mysql="C:\Program Files\xampp\mysql\bin\mysql.exe"
## if its not, try adding c:\xampp\mysql\bin or C:\MAMP\bin\mysql\bin to your path and then test out the mysql command.
## lastly, change the two variables below to match whatever they are on your system.
DB_USER="root"
DB_PASSWORD="root"

alias mysql='/Applications/MAMP/Library/bin/mysql'

alias start_mamp='open /Applications/MAMP/MAMP.app/ && /Applications/MAMP/bin/start.sh'

alias list_db="mysql -u $DB_USER -p$DB_PASSWORD -e 'SHOW DATABASES'"

## Update_db will create a db if it doesn't already exist, then update the database with the current dump from platform.
## Then it will update the db by replacing every instance of a string with another string, ie, swapping production urls for local urls.
## USAGE:
### cd to project directory
### update_db DBNAME "string to replace"(optional) "replacing string"(optional)
update_db(){
	echo "Checking if database exists."
	if ! mysql -u $DB_USER -p$DB_PASSWORD -e "use $1"; then
		echo "Did you want to create a database called $1? [y/n]: "
		read  willmakedb
		if [[ $willmakedb == "y" ]]; then
			echo "create database $1" | mysql -u $DB_USER -p$DB_PASSWORD &&
			echo "Database created"
		else
			exit
		fi
	fi
	echo "Grabbing platform database dump."
	platform db:dump --yes --gzip -f db.sql.gz &&
	echo "Updating Database:" &&
	pv db.sql.gz | gunzip | mysql -u $DB_USER -p$DB_PASSWORD $1
	if [[ "$#" == 3 ]]; then
		echo "Replacing $2 with $3"
		wp search-replace '$2' '$3' --skip-columns=guid
	fi
	echo "Flushing URLs."
	wp rewrite flush
}

## USAGE:
### make_db DBNAME
make_db(){
	echo "CREATE DATABASE $1" | mysql -u $DB_USER -p$DB_PASSWORD &&
	echo "$1 database created."
}

## USAGE:
### delete_db DBNAME
delete_db(){
	echo "DROP DATABASE $1" | mysql -u $DB_USER -p$DB_PASSWORD &&
	echo "$1 database deleted."
}


