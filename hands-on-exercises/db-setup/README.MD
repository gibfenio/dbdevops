

Local login on database server
```bash
  mysql -h $MYSQL_DB_IP -P 15000 -u root -p
  mysql -h $MYSQL_DB_IP -P 16000 -u root -p
  mysql -h $MYSQL_DB_IP -P 17000 -u root -p
  mysql -h $MYSQL_DB_IP -P 18000 -u root -p
```

Login to DB from remote client
``` bash
export MYSQL_DB_IP=43.205.242.89
export DB_PASSWORD=1234
mysql -h $MYSQL_DB_IP -P 15000 -u admin -p$DB_PASSWORD
mysql -h $MYSQL_DB_IP -P 16000 -u admin -p$DB_PASSWORD
mysql -h $MYSQL_DB_IP -P 17000 -u admin -p$DB_PASSWORD
mysql -h $MYSQL_DB_IP -P 18000 -u admin -p$DB_PASSWORD
```

