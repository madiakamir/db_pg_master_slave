-- MERCHANT_REPORT_SERVICE connect to slave with root user like postgres, merchant_user
-- All operations need to be done on master db, then slave db all pick up.

-- Create postgres_fdw extension on the destination
create extension postgres_fdw;

-- Create a server definition
CREATE SERVER product 
 FOREIGN DATA WRAPPER postgres_fdw
 OPTIONS (dbname 'merchant_product_service_db', host 'localhost', port '5432');
 
CREATE SERVER merchant 
 FOREIGN DATA WRAPPER postgres_fdw
 OPTIONS (dbname 'merchant_service_db', host 'localhost', port '5432');
 
-- dropping SERVER, firstable need to drop all depeneds on this server things like ( foreign table, mapping users)
-- drop server merchant;
 
-- Create user mapping from destination user to source user
-- change user and password if prod -- postgres -> merchant_user
-- Create a mapping on the destination side for destination user (postgres) to remote source user (postgres)

 CREATE USER MAPPING for postgres
	SERVER product
	OPTIONS (user 'postgres' /*merchant_user*/, password 'postgres' /*merchantq!213Q1!*/);
	
 CREATE USER MAPPING for postgres
	SERVER merchant
	OPTIONS (user 'postgres' /*merchant_user*/, password 'postgres' /*merchantq!213Q1!*/);
	
-- drop USER MAPPING for  merchant_replicator server merchant

-- if grant is required
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO merchant_replicator /*merchant_user*/;
	
-- Create foreign table definition on the destination
-- import all tables from schema of remote database except some tables
IMPORT FOREIGN SCHEMA "public" except (databasechangelog, databasechangeloglock ) FROM SERVER product INTO public;
IMPORT FOREIGN SCHEMA "public" except (databasechangelog, databasechangeloglock ) FROM SERVER merchant INTO public;


-- after changing remote table, necessary to make appropriate changes foreign table 
-- alter table contract add column test boolean;

-- dropping foreign table 
-- drop foreign table contract;

