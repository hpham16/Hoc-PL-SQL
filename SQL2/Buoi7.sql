--Bài 1:
--+ 	?ánh index cho tr??ng TITLE c?a b?ng EMPLOYEE
--+ 	Ki?m tra xem Index ?ã ???c thêm ch?a?
-- 
CREATE INDEX ind_tilte_hung ON employee(title);
SELECT index_name
FROM user_indexes
WHERE table_name = 'EMPLOYEE';
--Bài 2 : Hãy ?ánh index cho b?ng EMPLOYEE ?? t?ng t?c truy v?n nhân viên theo tên (FIRST_NAME,LAST_NAME)
-- 
CREATE INDEX ind_fn_ln ON employee(first_name, last_name);
--Bài 3 : ?ánh index ?? t?ng t?c ?? truy v?n c?a khác hàng theo khu v?c (STATE) c?a b?ng CUSTOMER
CREATE BITMAP INDEX ind_state ON customer(state);



----------------------------------PARTITION --------------------------------------

--Bài 1:
--B??c 1: T?o b?ng theo m?u sau
CREATE TABLE invoices_not_partition_huyhung (
invoice_no NUMBER NOT NULL,
invoice_date DATE NOT NULL,
comments VARCHAR2(500)
);
--B??c 2:  Insert d? li?u gi? l?p theo code m?u:
begin
for i in 1..2000
loop
insert into invoices_not_partition_huyhung values (
(SELECT trunc(DBMS_RANDOM.value(1, 100000)) FROM DUAL),
(SELECT trunc(SYSDATE - DBMS_RANDOM.value(0,3640)) FROM DUAL),
(SELECT DBMS_RANDOM.STRING('A', 20) FROM DUAL));
commit;
end loop;
end;

select count(*) from invoices_not_partition_huyhung;
--B??c 3: T?o b?ng invoices_with_partition, l?y d? li?u t? b?ng INVOICES_NORMAL

CREATE TABLE invoices_with_partition_huyhung
(invoice_no NUMBER NOT NULL,
invoice_date DATE NOT NULL,
comments VARCHAR2(500))
partition by range(invoice_date)
(PARTITION P2010_Q1 VALUES less than(to_date('01-APR-2010', 'DD-MON-YYYY')),
PARTITION P2010_Q2 VALUES less than(to_date('01-JUL-2010', 'DD-MON-YYYY')),
PARTITION P2010_Q3 VALUES less than(to_date('01-OCT-2010', 'DD-MON-YYYY')),
PARTITION P2010_Q4 VALUES less than(to_date('01-JAN-2011', 'DD-MON-YYYY')),
PARTITION P2011_Q1 VALUES less than(to_date('01-APR-2011', 'DD-MON-YYYY')),
PARTITION P2011_Q2 VALUES less than(to_date('01-JUL-2011', 'DD-MON-YYYY')),
PARTITION P2011_Q3 VALUES less than(to_date('01-OCT-2011', 'DD-MON-YYYY')),
PARTITION P2011_Q4 VALUES less than(to_date('01-JAN-2012', 'DD-MON-YYYY')),
PARTITION P2012_Q1 VALUES less than(to_date('01-APR-2012', 'DD-MON-YYYY')),
PARTITION P2012_Q2 VALUES less than(to_date('01-JUL-2012', 'DD-MON-YYYY')),
PARTITION P2012_Q3 VALUES less than(to_date('01-OCT-2012', 'DD-MON-YYYY')),
PARTITION P2012_Q4 VALUES less than(to_date('01-JAN-2013', 'DD-MON-YYYY')),
PARTITION P2013_Q1 VALUES less than(to_date('01-APR-2013', 'DD-MON-YYYY')),
PARTITION P2013_Q2 VALUES less than(to_date('01-JUL-2013', 'DD-MON-YYYY')),
PARTITION P2013_Q3 VALUES less than(to_date('01-OCT-2013', 'DD-MON-YYYY')),
PARTITION P2013_Q4 VALUES less than(to_date('01-JAN-2014', 'DD-MON-YYYY')),
PARTITION P2014_Q1 VALUES less than(to_date('01-APR-2014', 'DD-MON-YYYY')),
PARTITION P2014_Q2 VALUES less than(to_date('01-JUL-2014', 'DD-MON-YYYY')),
PARTITION P2014_Q3 VALUES less than(to_date('01-OCT-2014', 'DD-MON-YYYY')),
PARTITION P2014_Q4 VALUES less than(to_date('01-JAN-2015', 'DD-MON-YYYY')),
PARTITION P2015_Q1 VALUES less than(to_date('01-APR-2015', 'DD-MON-YYYY')),
PARTITION P2015_Q2 VALUES less than(to_date('01-JUL-2015', 'DD-MON-YYYY')),
PARTITION P2015_Q3 VALUES less than(to_date('01-OCT-2015', 'DD-MON-YYYY')),
PARTITION P2015_Q4 VALUES less than(to_date('01-JAN-2016', 'DD-MON-YYYY')),
PARTITION P2016_Q1 VALUES less than(to_date('01-APR-2016', 'DD-MON-YYYY')),
PARTITION P2016_Q2 VALUES less than(to_date('01-JUL-2016', 'DD-MON-YYYY')),
PARTITION P2016_Q3 VALUES less than(to_date('01-OCT-2016', 'DD-MON-YYYY')),
PARTITION P2016_Q4 VALUES less than(to_date('01-JAN-2017', 'DD-MON-YYYY')),
PARTITION P2017_Q1 VALUES less than(to_date('01-APR-2017', 'DD-MON-YYYY')),
PARTITION P2017_Q2 VALUES less than(to_date('01-JUL-2017', 'DD-MON-YYYY')),
PARTITION P2017_Q3 VALUES less than(to_date('01-OCT-2017', 'DD-MON-YYYY')),
PARTITION P2017_Q4 VALUES less than(to_date('01-JAN-2018', 'DD-MON-YYYY')),
PARTITION P2018_Q1 VALUES less than(to_date('01-APR-2018', 'DD-MON-YYYY')),
PARTITION P2018_Q2 VALUES less than(to_date('01-JUL-2018', 'DD-MON-YYYY')),
PARTITION P2018_Q3 VALUES less than(to_date('01-OCT-2018', 'DD-MON-YYYY')),
PARTITION P2018_Q4 VALUES less than(to_date('01-JAN-2019', 'DD-MON-YYYY')),
PARTITION P2019_Q1 VALUES less than(to_date('01-APR-2019', 'DD-MON-YYYY')),
PARTITION P2019_Q2 VALUES less than(to_date('01-JUL-2019', 'DD-MON-YYYY')),
PARTITION P2019_Q3 VALUES less than(to_date('01-OCT-2019', 'DD-MON-YYYY')),
PARTITION P2019_Q4 VALUES less than(to_date('01-JAN-2020', 'DD-MON-YYYY')),
PARTITION P2020_Q1 VALUES less than(to_date('01-APR-2020', 'DD-MON-YYYY')),
PARTITION P2020_Q2 VALUES less than(to_date('01-JUL-2020', 'DD-MON-YYYY')),
PARTITION P2020_Q3 VALUES less than(to_date('01-OCT-2020', 'DD-MON-YYYY')),
PARTITION P2020_Q4 VALUES less than(to_date('01-JAN-2021', 'DD-MON-YYYY')),
PARTITION P2021_Q1 VALUES less than(to_date('01-APR-2021', 'DD-MON-YYYY')),
PARTITION P2021_Q2 VALUES less than(to_date('01-JUL-2021', 'DD-MON-YYYY')),
PARTITION P2021_Q3 VALUES less than(to_date('01-OCT-2021', 'DD-MON-YYYY')),
PARTITION P2021_Q4 VALUES less than(to_date('01-JAN-2022', 'DD-MON-YYYY')),
PARTITION P2022_Q1 VALUES less than(to_date('01-APR-2022', 'DD-MON-YYYY')),
PARTITION P2022_Q2 VALUES less than(to_date('01-JUL-2022', 'DD-MON-YYYY')),
PARTITION P2022_Q3 VALUES less than(to_date('01-OCT-2022', 'DD-MON-YYYY')),
PARTITION P2022_Q4 VALUES less than(to_date('01-JAN-2023', 'DD-MON-YYYY')),
PARTITION P2023_Q1 VALUES less than(to_date('01-APR-2023', 'DD-MON-YYYY')),
PARTITION P2023_Q2 VALUES less than(to_date('01-JUL-2023', 'DD-MON-YYYY')),
PARTITION P2023_Q3 VALUES less than(to_date('01-OCT-2023', 'DD-MON-YYYY')),
PARTITION P2023_Q4 VALUES less than(to_date('01-JAN-2024', 'DD-MON-YYYY')),
PARTITION P2024_Q1 VALUES less than(to_date('01-APR-2024', 'DD-MON-YYYY')),
PARTITION P2024_Q2 VALUES less than(to_date('01-JUL-2024', 'DD-MON-YYYY')),
PARTITION P2024_Q3 VALUES less than(to_date('01-OCT-2024', 'DD-MON-YYYY')),
PARTITION P2024_Q4 VALUES less than(to_date('01-JAN-2025', 'DD-MON-YYYY'))
);



--B??c 4:  Th?c hi?n insert toàn b? d? li?u t? b?ng invoices_not_partition sang b?ng invoices_with_partition
insert into invoices_with_partition_huyhung
select * from invoices_not_partition_huyhung;

--B??c 5:  Th?c hi?n truy v?n trên c? 2 b?ng b?ng câu l?nh SELECT
--? So sánh hi?u n?ng khi truy v?n trê 2 b?ng
--So sánh cho th?y vi?c b?ng có Partition cho ra câu truy v?n có t?c ?? nhanh h?n so v?i câu truy v?n không có partition.

--Bài 2:  S? d?ng ki?u Phân vùng ph?m vi (Range Partition) ?? th?c hi?n phân vùng ph?m vi trên tr??ng TXN_DATE c?a bàng ACC_TRANSACTION theo 5 partition:
ACC_TRANSACTION_2001 VALUES LESS THAN (TO_DATE('01-JAN-2001','DD-MON-YYYY')),
ACC_TRANSACTION_2002 VALUES LESS THAN (TO_DATE('01-JAN-2002','DD-MON-YYYY')),
ACC_TRANSACTION_2003 VALUES LESS THAN (TO_DATE('01-JAN-2003','DD-MON-YYYY')),
ACC_TRANSACTION_2004 VALUES LESS THAN (TO_DATE('01-JAN-2004','DD-MON-YYYY')),
ACC_TRANSACTION_2005 VALUES LESS THAN (TO_DATE('01-JAN-2005','DD-MON-YYYY'))
 
ALTER TABLE acc_transaction
MODIFY PARTITION BY RANGE(txn_date)
(
 partition ACC_TRANSACTION_2001 VALUES LESS THAN (TO_DATE('01-JAN-2001','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2002 VALUES LESS THAN (TO_DATE('01-JAN-2002','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2003 VALUES LESS THAN (TO_DATE('01-JAN-2003','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2004 VALUES LESS THAN (TO_DATE('01-JAN-2004','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2005 VALUES LESS THAN (TO_DATE('01-JAN-2005','DD-MON-YYYY'))
);

--Bài 3:  S? d?ng ki?u Phân vùng danh sách (List Partition) ?? th?c hi?n phân vùng theo theo t?ng STATE c?a khách hàng (b?ng Customer)
select * from customer;
ALTER TABLE CUSTOMER MODIFY
  PARTITION BY LIST (STATE) 
  (
    PARTITION STATE_MA VALUES ('MA'),
    PARTITION STATE_NH VALUES ('NH'),
    PARTITION STATE_MA VALUES (DEFAULT),
  );
