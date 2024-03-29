```sql
postgres=# -- transaction T1
postgres=# 
postgres=# BEGIN;
BEGIN
postgres=*# 
postgres=*# SAVEPOINT T1;
SAVEPOINT
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit - 500
postgres-*# WHERE account_id = 1;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 500
postgres-*# WHERE account_id = 3;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 0
postgres-*# WHERE account_id = 4;
UPDATE 1
postgres=*# 
postgres=*# SELECT * from accounts;
 account_id | account_name | account_credit | account_bank 
------------+--------------+----------------+--------------
          2 | German       |           1000 | Tinkoff
          1 | Vladimir     |            500 | SpearBank
          3 | Andrey       |           1500 | SpearBank
          4 | Fees         |              0 | 
(4 rows)

postgres=*# 
postgres=*# -- transaction T2
postgres=*# 
postgres=*# SAVEPOINT T2;
SAVEPOINT
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit - 700 - 30
postgres-*# WHERE account_id = 2;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 700
postgres-*# WHERE account_id = 1;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 30
postgres-*# WHERE account_id = 4;
UPDATE 1
postgres=*# 
postgres=*# SELECT * from accounts;
 account_id | account_name | account_credit | account_bank 
------------+--------------+----------------+--------------
          3 | Andrey       |           1500 | SpearBank
          2 | German       |            270 | Tinkoff
          1 | Vladimir     |           1200 | SpearBank
          4 | Fees         |             30 | 
(4 rows)

postgres=*# 
postgres=*# -- transaction T3
postgres=*# 
postgres=*# SAVEPOINT T3;
SAVEPOINT
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit - 100 - 30
postgres-*# WHERE account_id = 2;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 100
postgres-*# WHERE account_id = 3;
UPDATE 1
postgres=*# 
postgres=*# UPDATE accounts
postgres-*# SET account_credit = account_credit + 30
postgres-*# WHERE account_id = 4;
UPDATE 1
postgres=*# 
postgres=*# SELECT * from accounts;
 account_id | account_name | account_credit | account_bank 
------------+--------------+----------------+--------------
          1 | Vladimir     |           1200 | SpearBank
          2 | German       |            140 | Tinkoff
          3 | Andrey       |           1600 | SpearBank
          4 | Fees         |             60 | 
(4 rows)

postgres=*# 
postgres=*# ROLLBACK TO T1;
ROLLBACK
postgres=*# 
postgres=*# COMMIT;
COMMIT
postgres=# SELECT * from accounts;
 account_id | account_name | account_credit | account_bank 
------------+--------------+----------------+--------------
          2 | German       |           1000 | Tinkoff
          1 | Vladimir     |           1000 | SpearBank
          3 | Andrey       |           1000 | SpearBank
          4 | Fees         |              0 | 
(4 rows)

postgres=#
```
