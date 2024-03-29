-- first query
explain (verbose, analyze) select title from film where ((rating='R' or rating='PG-13') and film_id in (select film_id from film_category where (category_id=11 or category_id=14)) and film_id not in (select film_id from inventory where inventory_id in (select inventory_id from rental)));

-- second query
explain (verbose, analyze) select * from (select store_id, sum(amount) as money from payment right join customer using (customer_id) right join store using (store_id) where payment_date > '2007/04/14' and payment_date <= '2007/05/14' group by store_id) as answer order by money desc;

-- solution for first query:
create index on inventory using btree (inventory_id, film_id);
create index on film_category using btree (category_id, film_id);

-- solution for second query:
create index on payment using btree(payment_date);
