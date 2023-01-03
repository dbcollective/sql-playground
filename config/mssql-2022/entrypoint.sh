#wait for the SQL Server to come up
sleep 30s

DB_EXISTS=$(/opt/mssql-tools/bin/sqlcmd -S mssql-2022 -U sa -P $DB_ROOT_PASSWORD -d master -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = '$DB_NAME'" | tr -d '-')
if [ $DB_EXISTS == "1" ];
then
    echo "Database is ready to use"
else
    echo "Configuring Database and Seeing for the First Time"
    /opt/mssql-tools/bin/sqlcmd -S mssql-2022 -U sa -P $DB_ROOT_PASSWORD -d master -i init.sql
fi
