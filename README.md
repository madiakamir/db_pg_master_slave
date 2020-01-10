# SETUP DATABASE SERVER INSTRUCTION:  

#### STEPS:

Go to master or slave folder 

1) run following command:

	> docker-compose up -d
		
2) create database if not exist "merchant_report_service_db"

3) run script_db_link_script.sql in "merchant_report_service_db" of "MASTER PostgreSQL server" for to create foreign-data wrapper, which can be used to access data stored in external PostgreSQL servers. 


