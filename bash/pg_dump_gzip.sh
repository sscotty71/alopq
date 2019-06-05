# This is just a cheat sheet:

# On production
sudo -u postgres pg_dump database | gzip -9 > database.sql.gz

# On local
scp -C production:~/database.sql.gz
dropdb database && createdb database
gunzip < database.sql.gz | psql database