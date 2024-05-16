--B�i 1:  Ta c� 2 b?ng: CUSTOMER v� HOCVIEN_CUSTOMER
--S? d?ng l?nh MERGE ?? s?a ??i b?ng HOCVIEN_CUSTOMER d?a tr�n nh?ng thay ??i c?a b?ng CUSTOMER
--+ N?u d? li?u tr??ng CUST_TYPE_CD c?a b?ng CUSTOMER kh�c v?i tr??ng CUST_TYPE_CD c?a b?ng HOCVIEN_CUSTOMER th� UPDATE: 
----HOCVIEN_CUSTOMER.CUST_TYPE_CD  = CUSTOMER .CUST_TYPE_CD  
--+ N?u kh�ng t?n t?i d? li?u tr�ng kh?p gi?a 2 b?ng th� INSERT to�n b? d? li?u t? b?ng CUSTOMER v�o HOCVIEN_CUSTOMER
MERGE into hocvien_customer hvc
USING customer c 
ON (c.cust_id = hvc.cust_id)
    when matched then 
    update set hvc.cust_type_cd = c.cust_type_cd 
    when not MATCHED then
    INSERT (cust_id, address, city, cust_type_cd, fed_id, postal_code, state)
    VALUES (c.cust_id, c.address, c.city, c.cust_type_cd, c.fed_id, c.postal_code, c.state);

--B�i 2: Vi?t c�u l?nh l?y ra t�n c�c g�i s?n ph?m v� t?ng s? d? theo t?ng s?n ph?m m� ng�n h�ng ?ang cung c?p. 
--S? d?ng ROW_NUMBER() ?? x?p lo?i c�c g�i s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n
SELECT  p.name, 
        sum(a.avail_balance),
        ROW_NUMBER() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;
--B�i 3 Vi?t c�u l?nh l?y ra t�n c�c g�i s?n ph?m v� t?ng s? d? theo t?ng s?n ph?m m� ng�n h�ng ?ang cung c?p. 
--S? d?ng DENSE_RANK() ?? x?p lo?i c�c g�i s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n 
SELECT  p.name, 
        sum(a.avail_balance),
        dense_rank() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;
--B�i 4: Vi?t c�u l?nh l?y ra t�n c�c g�i s?n ph?m v� t?ng s? d? theo t?ng s?n ph?m m� ng�n h�ng ?ang cung c?p. 
--S? d?ng RANK() ?? x?p lo?i c�c g�i s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n 
SELECT  p.name, 
        sum(a.avail_balance),
        rank() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;

--B�i 5: T�nh t?ng gi� tr? giao d?ch theo t?ng n?m, so s�nh n?m hi?n t?i v?i n?m tr??c ?�
--
--+ B??c 1: T�nh t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng h�m LAG ?? tr? v? t?ng giao d?ch so v?i n?m tr??c
select  extract(year from txn_date) Year,
        sum(amount),
        lag(sum(amount),1) over (order by extract(year from txn_date))
from acc_transaction ac
group by extract(year from txn_date);

--B�i 6: T�nh t?ng gi� tr? giao d?ch c?a t?ng chi nh�nh theo t?ng n?m. So s�nh gi� tr? n?m ?� v?i n?m ti?p theo 
--+ B??c 1: T�nh t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng h�m LEAD ?? tr? v? t?ng giao d?ch so v?i n?m sau

select  b.name,
        extract(year from txn_date) Year,
        sum(amount) total_amount,
        lead(sum(amount),1) over (partition by b.name order by b.name) next_amount
from branch b
join account a
on b.branch_id = a.open_branch_id
join acc_transaction ac
on ac.account_id = a.account_id
group by name,extract(year from txn_date);

--B�i 7: T�nh t?ng gi� tr? giao d?ch c?a t?ng chi nh�nh theo t?ng n?m. So s�nh gi� tr? n?m ?� v?i n?m ti?p theo v� t�nh % thay ??i 
--+ B??c 1: T�nh t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng h�m LAD ?? tr? v? t?ng giao d?ch so v?i n?m sau
select  b.name,
        extract(year from txn_date) Year,
        sum(amount) total_amount,
        lead(sum(amount),1) over (partition by b.name order by b.name) over_amount,
        ((lead(sum(amount),1) over (partition by b.name order by b.name)- sum(amount)) / SUM(amount)) * 100 || '%' tyle
from branch b
join account a
on b.branch_id = a.open_branch_id
join acc_transaction ac
on ac.account_id = a.account_id
group by name,extract(year from txn_date);


--B�I T?P V? NH�
--
--
--B�i 1: 
--T?o ra 1 b?ng <T�n h?c vi�n>_EMP_LOAD l?y t? b?ng EMP_LOAD. S?a ??i ng�y ngh? vi?c (END_DATE) v� tr?ng th�i (STATUS) 
--c?a nh�n vi�n trong b?ng <T�n h?c vi�n>_EMP_LOAD theo y�u c?u sau
--S? d?ng Merge
--N?u nh�n vi�n ?� ?� c� trong b?ng: <T�n h?c vi�n>_EMP_LOAD. Ki?m tra t? b?ng EMPLOYEE n?u nh�n vi�n ?� c� 
--ng�y END_DATE  >= START_DATE th� c?p nh?t l?i  END_DATE v� STATUS  c?a b?ng <T�n h?c vi�n>_EMP_LOAD nh? sau:
--<T�n h?c vi�n>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE v� <T�n h?c vi�n>_EMP_LOAD.STATUS = 0
--N?u nh�n vi�n ?� ch?a c� trong b?ng: <T�n h?c vi�n>_EMP_LOAD. INSERT to�n b? d? li?u t? b?ng EMPLOYEE v�o <T�n h?c vi�n>_EMP_LOAD 
--S? d?ng Cursor, loop� ?? th?c hi?n y�u c?u tr�n

CREATE TABLE huyhung_emp_load AS
SELECT * FROM emp_load;
-------------
select * from huyhung_emp_load;
select * from employee;

MERGE into huyhung_emp_load hv
USING (select   emp_id,
                first_name,
                last_name,
                end_date,
                start_date,
                CASE WHEN end_date >= start_date THEN 0
                    ELSE 1
                    END STATUS
                from employee) e
ON (e.emp_id = hv.emp_id)
    when matched then 
        update set  hv.end_date = e.end_date,
                    hv.status = 0
        where e.end_date >= e.start_date 
    when not MATCHED then
        INSERT (emp_id, end_date, first_name, last_name, start_date, status)
        VALUES (e.emp_id, e.end_date, e.first_name, e.last_name, e.start_date, e.status);
--con tr?
declare
    cursor c_emp is
    select  a.emp_id,
            b.emp_id emp_id_b,
            a.first_name,
            a.last_name,
            a.end_date,
            a.start_date,
            CASE WHEN a.end_date >= a.start_date THEN 0
            ELSE 1
            END STATUS
            from employee a
    left  join huyhung_EMP_LOAD b
    on a.emp_id = b.emp_id;
            
    type bt_emp is table of c_emp%rowtype index by binary_integer;
    b_emp bt_emp;
begin
    open c_emp;
    loop
        fetch c_emp bulk collect into b_emp limit 10000;
        
        exit when b_emp.count = 0;
        
        for i in b_emp.first..b_emp.last loop
            if b_emp(i).emp_id_b is null then
                INSERT into huyhung_emp_load (emp_id, end_date, first_name, last_name, start_date, status)
                VALUES (b_emp(i).emp_id, b_emp(i).end_date, b_emp(i).first_name, b_emp(i).last_name, b_emp(i).start_date, b_emp(i).status);
            else
                update huyhung_emp_load set END_DATE = b_emp(i).END_DATE,
                STATUS = b_emp(i).STATUS
                where emp_id = b_emp(i).emp_id_b ;
            end if;
        end loop;
    end loop;
    close c_emp;
end;

--B�i 2: 
--T?o ra 1 b?ng <T�n h?c vi�n>_CUST_LOAD l?y t? b?ng CUST_LOAD. 
--S? d?ng Merge ?? x?p h?ng kh�ch h�ng (RANK_TRANS) c?a b?ng <T�n h?c vi�n>_CUST_LOAD theo h??ng d?n sau:
--1.D�ng h�m ranking ?? x?p h?ng kh�ch h�ng theo t?ng s? l?n giao d?ch (kh�ch h�ng c�ng t?ng s? l?n giao d?ch s? c�ng h?ng).
--2.C?p nh?t l?i x?p h?ng (RANK_TRANS) c?a b?ng <T�n h?c vi�n>_CUST_LOAD theo nh? Rank ?� t�nh ???c ? 
--b??c 1 n?u nh? Rank c?a ch�ng kh�c nhau
--3.Th�m m?i to�n b? d? li?u ?� t�nh ???c t? b??c 1 v�o b?ng <T�n h?c vi�n>_CUST_LOAD n?u nh? kh�ch h�ng 
--?� ch?a ???c x?p h?ng v�o ng�y h�m ?�
--* Gi? s?: M?i ng�y s? ph?i t�nh Rank c?a kh�ch h�ng 1 l?n. Ngh? ??n ph??ng �n l�m sao ch? cho 
--ph�p c?p nh?t ho?c th�m m?i v�o b?ng <T�n h?c vi�n>_CUST_LOAD 1 l?n/1 ng�y
CREATE TABLE huyhung_cust_load AS
SELECT * FROM cust_load;
select * from huyhung_cust_load;
merge into huyhung_cust_load hv
using   (select  c.cust_id,
            count(acc.account_id),
            dense_rank() over (order by count(acc.account_id) desc) rank_trans,
            TRUNC(SYSDATE) AS UPDATE_DATE
        from customer c
        join account a
            on c.cust_id = a.cust_id
        join acc_transaction acc
            on a.account_id = acc.account_id
        group by c.cust_id, TRUNC(SYSDATE)) src
on (src.cust_id = hv.cust_id)
    when matched then 
        update set  hv.rank_trans = src.rank_trans
    when not matched then 
        insert (cust_id, rank_trans, update_date)
        values (src.cust_id, src.rank_trans, src.UPDATE_DATE);
        
--C�u 3 Vi?t c�u l?nh l?y ra t?ng s? d? theo t?ng t�i kho?n c?a m?i kh�ch h�ng. 
--S? d?ng H�m Ranking ?? x?p lo?i t�i kho?n c?a m?i kh�ch h�ng theo s? d? t�i kho?n. 
--L?y ra top 1 v� 2 c?a m?i t�i kho?n ?�
select * from(
    select  c.cust_id,
            a.account_id,
            sum(a.avail_balance),
            ROW_NUMBER() OVER (PARTITION BY c.cust_id ORDER BY SUM(AVAIL_BALANCE) desc ) AVAIL_BALANCE_RANK
    from customer c
    join account a
    on a.cust_id = c.cust_id 
    group by c.cust_id, a.account_id
    order by c.cust_id
    ) where avail_balance_rank in (1,2);
    
--B�i 4
--T�nh t?ng s? d? t�i kho?n (AVAIL_BALANCE) theo t?ng n?m v� s?n ph?m s?n ph?m d?ch v? c?a ng�n h�ng. 
--Ch? t�nh nh?ng t�i kho?n s?n ph?m m? t? n?m 2000 ??n n?m 2003 (OPEN_DATE).So s�nh v?i n?m tr??c ?� v� t�nh % thay ??i
select  extract(year from open_date) Nam,
        name,
        sum(avail_balance) tong,
        lag(sum(avail_balance),1,0) over (partition by name order by name) next_tong,
        nvl(round(((sum(avail_balance)-(lag(sum(avail_balance),1,0) over (partition by name order by name))) 
        / nullif( sum(avail_balance),0)) * 100,1),0) Tyle
from account a
join product p
on p.product_cd = a.product_cd
where extract(year from open_date) between 2000 and 2003
group by extract(year from open_date), name;







