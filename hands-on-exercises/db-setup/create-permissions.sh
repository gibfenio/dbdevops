# set your root password from the setup output
ROOTPW='acY,Bx8]Rlm92E*N4xLs/QwA'
HOST=13.201.87.216

for P in 15000 16000 17000 18000; do
  echo "Fixing admin on port $P..."
  mysql -h "$HOST" -P "$P" -uroot -p"$ROOTPW" -e "
    CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
    ALTER USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY '1234';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    SELECT user, host, plugin FROM mysql.user WHERE user='admin';
  "
done

echo "Done."