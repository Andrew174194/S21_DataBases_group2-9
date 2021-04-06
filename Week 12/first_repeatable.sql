-- REPEATABLE READ

-- step I
-- terminal 1
begin;
set transaction isolation level repeatable read;
select * from test_table;

-- step II
-- terminal 2
begin;
set transaction isolation level repeatable read;
update test_table set username = 'ajones' where fullname = 'Alice Jones';

-- we're simply reading previous copy of test_table in first terminal, so no problem occured
-- after commit we have updated test_table on first & second terminal

-- step III
select * from test_table;
-- terminal 1 output:
 id | username |     fullname     | balance | group_id 
----+----------+------------------+---------+----------
  1 | jones    | Alice Jones      |      82 |        1
  2 | bitdiddl | Ben Bitdiddle    |      65 |        1
  3 | mike     | Michael Dole     |      73 |        2
  4 | alyssa   | Alyssa P. Hacker |      79 |        3
  5 | bbrown   | Bob Brown        |     100 |        3
(5 rows)

-- step IV
select * from test_table;
-- terminal 2 output:
 id | username |     fullname     | balance | group_id 
----+----------+------------------+---------+----------
  2 | bitdiddl | Ben Bitdiddle    |      65 |        1
  3 | mike     | Michael Dole     |      73 |        2
  4 | alyssa   | Alyssa P. Hacker |      79 |        3
  5 | bbrown   | Bob Brown        |     100 |        3
  1 | ajones   | Alice Jones      |      82 |        1
(5 rows)

-- step V
commit;
select * from test_table;
-- terminal 1 && 2 output:
 id | username |     fullname     | balance | group_id 
----+----------+------------------+---------+----------
  2 | bitdiddl | Ben Bitdiddle    |      65 |        1
  3 | mike     | Michael Dole     |      73 |        2
  4 | alyssa   | Alyssa P. Hacker |      79 |        3
  5 | bbrown   | Bob Brown        |     100 |        3
  1 | ajones   | Alice Jones      |      82 |        1
(5 rows)

-- step VI
-- terminal 2
begin;
set transaction isolation level repeatable read;
savepoint T1;

-- step VII
-- terminal 1
begin;
set transaction isolation level repeatable read;
update test_table set balance = balance + 10 where fullname = 'Alice Jones';

-- step VIII
-- terminal 2
begin;
set transaction isolation level repeatable read;
update test_table set balance = balance + 20 where fullname = 'Alice Jones';

-- we're hang on terminal 2, waiting for commit on first terminal

-- step IX
-- terminal 1
commit;

-- step X
-- terminal 2
-- ERROR:  could not serialize access due to concurrent update
rollback to T1;
end;

-- terminal 1 && 2 output:
postgres=# select * from test_table;
 id | username |     fullname     | balance | group_id 
----+----------+------------------+---------+----------
  2 | bitdiddl | Ben Bitdiddle    |      65 |        1
  3 | mike     | Michael Dole     |      73 |        2
  4 | alyssa   | Alyssa P. Hacker |      79 |        3
  5 | bbrown   | Bob Brown        |     100 |        3
  1 | ajones   | Alice Jones      |      92 |        1
(5 rows)
