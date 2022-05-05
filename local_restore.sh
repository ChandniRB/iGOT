directory_path=~/cassandra_backup_2022-04-11
file_name=schema.cql

for d in $directory_path/*; do
	cd $d
	keyspace=${PWD##*/}
	echo CREATING   KEYSPACE   ${PWD##*/}
	cqlsh -e "CREATE KEYSPACE "${PWD##*/}" WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};"
	for f in $d ; do
		exists=$(find $f -name $file_name | tr " "  "\n")
		for dr in $exists; do
			sed -i 's/AND dclocal_read_repair_chance = 0.1/-- AND dclocal_read_repair_chance = 0.1/' $dr
			sed -i 's/AND read_repair_chance = 0.0/-- AND read_repair_chance = 0.0/' $dr
			echo CREATING  TABLE   from   $dr
			cqlsh -f  $dr
				
			table_path=$(find $dr -type f -name 'schema.cql' | sed -r 's|/[^/]+$||' |sort |uniq)
			db=$(find $table_path -type f -name '*.db' | sed -r 's|/[^/]+$||' |sort |uniq)
			if [ "$db" != "" ]; then
				echo RESTORING DATA . . .
				sstableloader -d 127.0.0.1 $db
				
			fi
		done
	done
 done

