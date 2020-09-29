cite about-plugin
about-plugin 'postgres helper functions'


PGVERSION=`pg_config --version | awk '{print $2}'`
POSTGRES_BIN=`pg_config --bindir`

export PGVERSION
export POSTGRES_BIN

COMMON_PGDATA_PATHS=("/usr/local/var/postgres" "/var/pgsql" "/Library/Server/PostgreSQL/Data")
for possible in "${COMMON_PGDATA_PATHS[@]}"
do
   :
   if [ -f "$possible/pg_hba.conf" ]
   then
       export PGDATA=$possible
   fi
done

postgres_start () {
  about 'Starts PostgreSQL server'
  group 'postgres'

  echo 'Starting PostgreSQL....';
  $POSTGRES_BIN/pg_ctl -D $PGDATA -l $PGDATA/logfile  start
}

postgres_stop () {
  about 'Stops PostgreSQL server'
  group 'postgres'

  echo 'Stopping PostgreSQL....';
  $POSTGRES_BIN/pg_ctl -D $PGDATA -l $PGDATA/logfile stop -s -m fast
}

postgres_status () {
  about 'Returns status of PostgreSQL server'
  group 'postgres'

  # $POSTGRES_BIN/pg_ctl -D $PGDATA status
  if [[ $(is_postgres_running) == "no server running" ]]
  then
    echo "PostgreSQL service [STOPPED]"
  else
    echo "PostgreSQL service [RUNNING]"
  fi
}


is_postgres_running () {
  $POSTGRES_BIN/pg_ctl -D $PGDATA status | egrep -o "no server running"
}


postgres_restart () {
  about 'Restarts status of PostgreSQL server'
  group 'postgres'

  echo 'Restarting PostgreSQL....';
  $POSTGRES_BIN/pg_ctl -D $PGDATA restart
}

postgres_logfile () {
  about 'View the last 500 lines from logfile'
  group 'postgres'

  tail -500 $PGDATA/logfile | less
}

postgres_serverlog () {
  about 'View the last 500 lines from server.log'
  group 'postgres'

  tail -500 $PGDATA/server.log | less
}

