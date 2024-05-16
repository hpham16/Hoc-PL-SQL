--Bài 1:  Ta có 2 b?ng: CUSTOMER và HOCVIEN_CUSTOMER
--S? d?ng l?nh MERGE ?? s?a ??i b?ng HOCVIEN_CUSTOMER d?a trên nh?ng thay ??i c?a b?ng CUSTOMER
--+ N?u d? li?u tr??ng CUST_TYPE_CD c?a b?ng CUSTOMER khác v?i tr??ng CUST_TYPE_CD c?a b?ng HOCVIEN_CUSTOMER thì UPDATE: 
----HOCVIEN_CUSTOMER.CUST_TYPE_CD  = CUSTOMER .CUST_TYPE_CD  
--+ N?u không t?n t?i d? li?u trùng kh?p gi?a 2 b?ng thì INSERT toàn b? d? li?u t? b?ng CUSTOMER vào HOCVIEN_CUSTOMER
MERGE into hocvien_customer hvc
USING customer c 
ON (c.cust_id = hvc.cust_id)
    when matched then 
    update set hvc.cust_type_cd = c.cust_type_cd 
    when not MATCHED then
    INSERT (cust_id, address, city, cust_type_cd, fed_id, postal_code, state)
    VALUES (c.cust_id, c.address, c.city, c.cust_type_cd, c.fed_id, c.postal_code, c.state);

--Bài 2: Vi?t câu l?nh l?y ra tên các gói s?n ph?m và t?ng s? d? theo t?ng s?n ph?m mà ngân hàng ?ang cung c?p. 
--S? d?ng ROW_NUMBER() ?? x?p lo?i các gói s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n
SELECT  p.name, 
        sum(a.avail_balance),
        ROW_NUMBER() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;
--Bài 3 Vi?t câu l?nh l?y ra tên các gói s?n ph?m và t?ng s? d? theo t?ng s?n ph?m mà ngân hàng ?ang cung c?p. 
--S? d?ng DENSE_RANK() ?? x?p lo?i các gói s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n 
SELECT  p.name, 
        sum(a.avail_balance),
        dense_rank() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;
--Bài 4: Vi?t câu l?nh l?y ra tên các gói s?n ph?m và t?ng s? d? theo t?ng s?n ph?m mà ngân hàng ?ang cung c?p. 
--S? d?ng RANK() ?? x?p lo?i các gói s?n ph?m theo t?ng s? d? theo th? t? gi?m d?n 
SELECT  p.name, 
        sum(a.avail_balance),
        rank() OVER (ORDER BY sum(a.avail_balance) desc) AS Top      
FROM product p
join account a
on a.product_cd = p.product_cd
group by p.name;

--Bài 5: Tính t?ng giá tr? giao d?ch theo t?ng n?m, so sánh n?m hi?n t?i v?i n?m tr??c ?ó
--
--+ B??c 1: Tính t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng hàm LAG ?? tr? v? t?ng giao d?ch so v?i n?m tr??c
select  extract(year from txn_date) Year,
        sum(amount),
        lag(sum(amount),1) over (order by extract(year from txn_date))
from acc_transaction ac
group by extract(year from txn_date);

--Bài 6: Tính t?ng giá tr? giao d?ch c?a t?ng chi nhánh theo t?ng n?m. So sánh giá tr? n?m ?ó v?i n?m ti?p theo 
--+ B??c 1: Tính t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng hàm LEAD ?? tr? v? t?ng giao d?ch so v?i n?m sau

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

--Bài 7: Tính t?ng giá tr? giao d?ch c?a t?ng chi nhánh theo t?ng n?m. So sánh giá tr? n?m ?ó v?i n?m ti?p theo và tính % thay ??i 
--+ B??c 1: Tính t?ng giao d?ch theo t?ng n?m
--+ B??c 2: S? d?ng hàm LAD ?? tr? v? t?ng giao d?ch so v?i n?m sau
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


--BÀI T?P V? NHÀ
--
--
--Bài 1: 
--T?o ra 1 b?ng <Tên h?c viên>_EMP_LOAD l?y t? b?ng EMP_LOAD. S?a ??i ngày ngh? vi?c (END_DATE) và tr?ng thái (STATUS) 
--c?a nhân viên trong b?ng <Tên h?c viên>_EMP_LOAD theo yêu c?u sau
--S? d?ng Merge
--N?u nhân viên ?ó ?ã có trong b?ng: <Tên h?c viên>_EMP_LOAD. Ki?m tra t? b?ng EMPLOYEE n?u nhân viên ?ó có 
--ngày END_DATE  >= START_DATE thì c?p nh?t l?i  END_DATE và STATUS  c?a b?ng <Tên h?c viên>_EMP_LOAD nh? sau:
--<Tên h?c viên>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE và <Tên h?c viên>_EMP_LOAD.STATUS = 0
--N?u nhân viên ?ó ch?a có trong b?ng: <Tên h?c viên>_EMP_LOAD. INSERT toàn b? d? li?u t? b?ng EMPLOYEE vào <Tên h?c viên>_EMP_LOAD 
--S? d?ng Cursor, loop… ?? th?c hi?n yêu c?u trên

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

--Bài 2: 
--T?o ra 1 b?ng <Tên h?c viên>_CUST_LOAD l?y t? b?ng CUST_LOAD. 
--S? d?ng Merge ?? x?p h?ng khách hàng (RANK_TRANS) c?a b?ng <Tên h?c viên>_CUST_LOAD theo h??ng d?n sau:
--1.Dùng hàm ranking ?? x?p h?ng khách hàng theo t?ng s? l?n giao d?ch (khách hàng cùng t?ng s? l?n giao d?ch s? cùng h?ng).
--2.C?p nh?t l?i x?p h?ng (RANK_TRANS) c?a b?ng <Tên h?c viên>_CUST_LOAD theo nh? Rank ?ã tính ???c ? 
--b??c 1 n?u nh? Rank c?a chúng khác nhau
--3.Thêm m?i toàn b? d? li?u ?ã tính ???c t? b??c 1 vào b?ng <Tên h?c viên>_CUST_LOAD n?u nh? khách hàng 
--?ó ch?a ???c x?p h?ng vào ngày hôm ?ó
--* Gi? s?: M?i ngày s? ph?i tính Rank c?a khách hàng 1 l?n. Ngh? ??n ph??ng án làm sao ch? cho 
--phép c?p nh?t ho?c thêm m?i vào b?ng <Tên h?c viên>_CUST_LOAD 1 l?n/1 ngày
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
        
--Câu 3 Vi?t câu l?nh l?y ra t?ng s? d? theo t?ng tài kho?n c?a m?i khách hàng. 
--S? d?ng Hàm Ranking ?? x?p lo?i tài kho?n c?a m?i khách hàng theo s? d? tài kho?n. 
--L?y ra top 1 và 2 c?a m?i tài kho?n ?ó
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
    
--Bài 4
--Tính t?ng s? d? tài kho?n (AVAIL_BALANCE) theo t?ng n?m và s?n ph?m s?n ph?m d?ch v? c?a ngân hàng. 
--Ch? tính nh?ng tài kho?n s?n ph?m m? t? n?m 2000 ??n n?m 2003 (OPEN_DATE).So sánh v?i n?m tr??c ?ó và tính % thay ??i
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







