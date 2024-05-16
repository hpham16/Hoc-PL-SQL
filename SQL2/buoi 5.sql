----D? li?u ?? th?c h�nh ???c m� t? chi ti?t t?i b�i th?c h�nh 1, N?u ch?a n?m r� xin vui l�ng xem l?i. 
----?�y l� 2 table s? s? d?ng trong b�i lab n�y:
--
------------------ FUNCTION-----------------------------
--B�i 1.
-- Vi?t 1 Function v?i tham s? ??u v�o l� N?M c?n l?y d? li?u. 
--T�nh t?ng s? d? t�i kho?n (ACCOUNT) c?a t?t c? kh�ch h�ng c� N?m m? t�i kho?n b?ng N?M truy?n v�o
--
create or replace function sum_year(year_acc in number)
return account.avail_balance%type
is
v_sum account.avail_balance%type;
begin
    select sum(avail_balance) into v_sum
    from account
    where extract(year from open_date) = year_acc;
    return v_sum;
end;  

select sum_year(2004) from dual;
--B�i 2.  
--Vi?t 1 Function v?i tham s? ??u v�o l� ID c?a kh�ch h�ng.
--L?y ra T?ng s? TK ?� m? c?a kh�ch h�ng c� ID = ID truy?n v�o
--
create or replace function sum_id(v_id in number)
return number
is
count_id number;
begin
    select count(account_id) into count_id
    from account a
    join customer c
    on a.cust_id = c.cust_id
    where a.cust_id = v_id;
    return count_id;
end;

--B�i 3.
--Vi?t 1 Function v?i tham s? ??u v�o l� ID nh�n vi�n
--Th?c hi?n T�nh s? n?m ?� l�m vi?c c?a nh�n vi�n ?� theo c�ng th?c sau:
--work_exp  = S? th�ng c?a Ng�y hi?n t?i so v?i ng�y b?t ??u v�o l�m / 12
--Th?c hi?n truy v?n l?y ra th�ng tin c?a nh�n vi�n bao g?m: H?, T�n, Ng�y b?t ??u l�m vi?c, s? th�ng ?� l�m vi?c (G?i ??n Function tr�n)
--
create or replace function exp_work(v_id in number)
return float
is
work_exp float;
begin
    select months_between(sysdate, start_date)/12 into work_exp
    from employee
    where emp_id = v_id;
    return work_exp;
end;
select first_name, last_name, start_date, exp_work(emp_id) from 
employee;
--B�i 4:
--Vi?t Function �FUNC_Get_Emp_Department� v?i tham s? ??u v�o l� m� nh�n vi�n EMP_ID v� tr? v? t�n ph�ng ban m� nh�n vi�n ?� l�m vi?c (Dept_Name).
---      Y�u c?u 1: Truy?n v�o ID l� 1 v� hi?n th? k?t qu? ra m�n h�nh �Get_Emp_Department(1)�;
---  	Y�u c?u 2: Vi?t l?nh SELECT ?? l?y ra to�n b? EMP_ID, First_Name, Last_Name v� t�n ph�ng ban s? d?ng Function �FUNC_Get_Emp_Department�.
--
--
create or replace function FUNC_Get_Emp_Department(v_id in number)
return department.name%type
is
v_dept department.name%type;
begin
    select d.name into v_dept
    from department d
    join employee e
    on d.dept_id = e.dept_id
    where v_id = e.emp_id;
    return v_dept;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
end;

select FUNC_Get_Emp_Department(1) from dual;
select EMP_ID, First_Name, Last_Name, FUNC_Get_Emp_Department(emp_id)  from employee;

--
------------- PROCEDURE------------------------
--B�i 1:
-- Vi?t  1 procedure kh�ng c� tham s?. Tr? v? t?t c? th�ng tin c?a c�c nh�n vi�n bao g?m: H?, T�n, Ph�ng ban, Ng�y v�o l�m
create or replace procedure info_emp
as
begin
    for i in (
        select first_name, last_name, name, start_date 
        from employee e
        join department dept
        on e.dept_id = dept.dept_id
        )
    loop
        DBMS_OUTPUT.PUT_LINE('First Name: ' || i.first_name);
        DBMS_OUTPUT.PUT_LINE('Last Name: ' || i.last_name);
        DBMS_OUTPUT.PUT_LINE('Department: ' || i.name);
        DBMS_OUTPUT.PUT_LINE('Start Date: ' || i.start_date);
        DBMS_OUTPUT.PUT_LINE('------------------------------------');
    end loop;
end;
set serveroutput on;
exec info_emp;
--B�i 2:
--Vi?t procedure �PRO_Get_Employee_Info� cho ph�p truy?n v�o ID c?a nh�n vi�n v� tr? v? First_Name, Last_Name, Dept_ID c?a nh�n vi�n ?�.
--G?i �: khai b�o 3 bi?n: First_Name, Last_Name, Dept_ID ?? ?�n k?t qu?  OUT t?  procedure.
create or replace procedure info_emp (ID_emp in employee.emp_id%type)
as
    Fname employee.first_name%type;
    LName employee.last_name%type;
    d_id department.dept_id%type;
begin
    select first_name, last_name, dept_id 
        into Fname,LName, d_id
        from employee e
        where ID_emp = emp_id;

    DBMS_OUTPUT.PUT_LINE('First Name: ' || Fname);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || LName);
    DBMS_OUTPUT.PUT_LINE('Department: ' || d_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fname := NULL;
            lname := NULL;
            d_id := NULL;
end;
set serveroutput on;
BEGIN
    info_emp(3);
END;
--Ch?y Procedure v� hi?n th? k?t qu? b?ng c�u l?nh DBMS_OUTPUT.PUT_LINE().
--B�i 3: 
-- Vi?t 1 Procedure tr? ra ph�n kh�c kh�ch h�ng theo t?ng kh�ch h�ng truy?n v�o theo c�ng th?c sau:
--N?u:
-- �AVAIL_BALANCE <= 4000� th� SEGMENT l�: �LOW�,
--�AVAIL_BALANCE > 4000 v� AVAIL_BALANCE <= 7000� th� SEGMENT l�: �MEDIUM�, �AVAIL_BALANCE >7000� th� SEGMENT l�: �HIGH�
--(G?i y: 2 tham s?: IN � id kh�ch h�ng, OUT- segment)
create or replace procedure cust_segment (cu_id in number)
as
    segment varchar2(20);
    avail_bal float; 
begin
    select sum(a.avail_balance) into avail_bal 
    from customer c
    join account a
    on a.cust_id = c.cust_id
    where cu_id = a.cust_id;
    if avail_bal <= 4000 then
    segment := 'LOW';
    elsif avail_bal > 4000 and avail_bal <= 7000 then
    segment := 'Medium';
    else 
    segment := 'High';
    end if;
    DBMS_OUTPUT.PUT_LINE('Segment: ' || segment);
end;
BEGIN
    cust_segment(3); 
END;

create or replace procedure cust_segment (cu_id in number,segment out varchar2)
as
    avail_bal float; 
begin
    select sum(a.avail_balance) into avail_bal 
    from customer c
    join account a
    on a.cust_id = c.cust_id
    where cu_id = a.cust_id;
    if avail_bal <= 4000 then
    segment := 'LOW';
    elsif avail_bal > 4000 and avail_bal <= 7000 then
    segment := 'Medium';
    else 
    segment := 'High';
    end if;
end;

exec cust_segment(3); 

declare
    v_segment varchar(20);
begin
    cust_segment(2,v_segment);
    Dbms_Output.Put_Line(v_segment);
end;
--
--
--1. Vi?t 1 FUNCTION cho ph�p truy?n v�o 1 tham s?. N?u tham s? truy?n v�o l� �EMP� th� l?y ra t?ng s? nh�n vi�n, 
--n?u tham s? truy?n v�o l� �DEPT� th� l?y ra t?ng s? ph�ng ban.
create or replace function count_company(insert_info in varchar2 )
return number
is
    v_count number;
begin 
    if insert_info = 'EMP' then
    select count(emp_id) into v_count
    from employee;
    elsif insert_info ='DEPT' then
    select count(dept_id) into v_count
    from department;
    end if;
    return v_count;
end;
select count_company('DEPT') from dual;
--2.Vi?t 1 FUNCTION cho ph�p truy?n v�o ID t�i kho?n (account_id). 
--L?y ra tr?ng th�i c?a giao d?ch m?i nh?t ?ng v?i ID t�i kho?n ?� theo y�u c?u sau:
--+ N?u Giao d?ch m?i nh?t >= ng�y hi?n t?i th� tr?ng th�i : 'The payment has been Completed'
--+ N?u Giao d?ch m?i nh?t < ng�y hi?n t?i th� tr?ng th�i : Ng�y giao d?ch + ' yet to be paid'
--+ C�n l?i: 'Invalid payment'
create or replace function status_trans(a_id number)
return varchar2
is 
    status varchar2(100);
    v_date acc_transaction.funds_avail_date%type;
begin
    select max(CAST(FUNDS_AVAIL_DATE AS DATE)) --into v_date
    from acc_transaction
    where 1 = account_id;
    if v_date = sysdate then
    status := 'The payment has been Completed';
    elsif v_date < sysdate then
    status := to_char(v_date) || ' yet to be paid';
    else 
    status := 'Invalid payment';   
    end if;
    return status;
end;
select status_trans(1) from dual;
--3.Vi?t 1 Function cho ph�p truy?n v�o tham s? l� ng�y b?t k?. 
--L?y ra t?t c? nh�n vi�n c� ng�y b?t ??u l�m vi?c >= ng�y truy?n v�o 
--(L?u �: C� tr??ng h?p nh�n vi?n ?� ngh? v� l?i ti?p t?c ?i l�m tr? l?i)
create TYPE PersonTable as TABLE OF VARCHAR2(100);
create or replace function search_date(date_type date)
return PersonTable
is 
    list_emp PersonTable;
begin
    select emp_id bulk collect into list_emp
    from employee
    where start_date >= date_type ;
    return list_emp;
end;
SELECT * from table(search_date(to_date('09/02/2000', 'dd/mm/yyyy')));



create type short_string_tt as table of varchar2(100);
create or replace function get_employees
    ( p_role_date_cutoff employee.start_date%type )
    return short_string_tt
as

    l_employee_list short_string_tt;
begin
    select emp_id bulk collect into l_employee_list
    from   ( select emp_id
                  , row_number() over(partition by emp_id order by start_date desc, emp_id desc) rn
             from   ( select e.emp_id, e.first_name, e.last_name, e.start_date, d.name
                      from   employee e
                             join department d
                                  on  e.dept_id = d.dept_id
                      where  e.start_date >= p_role_date_cutoff )
           )
    where  rn = 1;
    return l_employee_list;
end;

--Vi?t 1 Function cho ph�p truy?n v�o tham s? l� ng�y b?t k?. 
--L?y ra t?ng s? c�c t�i kho?n ?� ???c m? c?a t?t c? nh�n vi�n 
--t�nh ??n th?i ?i?m l� ng�y truy?n v�o v� ch? t�nh nh?ng nh�n vi�n c� s? th�ng l�m vi?c t�nh ??n th?i ?i?m ng�y truy?n v�o l� >13 th�ng.
create TYPE EmpTb as TABLE OF VARCHAR2(100);
create or replace function fc_search_date(date_emp date )
return number
is 
    Emp_list emptb;
begin
    select emp_id, count(account_id) bulk collect into emp_list
    from employee e
    join account a
    on e.emp_id = a.open_emp_id
    where months_between(start_date, date_emp) > 13;
    return emp_list;
end;
SELECT * from table(search_date(to_date('09/02/2004', 'dd/mm/yyyy')));

--Vi?t 1 Procedure cho ph�p truy?n v�o 2 tham s?: M� ph�ng ban, H?  s? l??ng. 
--C?p nh?t l?i l??ng c?a NV c� m� ph�ng ban truy?n v�o theo y�u  c?u sau:
--* S? d?ng Function work_time ?? ki?m tra xem nh�n vi�n ?� c� s? n?m l�m vi?c  >=13 hay kh�ng.
--N?u ?? th� update l?i l??ng c?a NV (B?ng hocvien_employee) ?� theo CT:
--L??ng m?i = l??ng c? + l??ng c? * h? s? l??ng
select * from employee where dept_id = 3;
create or replace procedure update_salary_emp(
    v_dept_id in employee.dept_id%type,
    coef_salary in number)
as 
    v_timework number;
begin
    for i in ( select e.emp_id 
                    from employee e
                    where e.dept_id = update_salary_emp.v_dept_id)
    loop
        v_timework := work_time(i.emp_id);
    
        IF v_timework >= 13 then
            update employee emp
            set emp.salary = emp.salary + emp.salary * coef_salary
            where i.emp_id = emp.emp_id;
        end if;
    end loop;
end;

exec update_salary_emp(3,2);
--Vi?t 1 Procedure cho ph�p truy?n v�o t�n s?n ph?m d?ch v? c?a ng�n h�ng ?ang cung c?p v� th?c hi?n c�ng vi?c sau:
--+ T�nh t?ng s? d? theo t?ng t�n s?n ph?m d?ch v? c?a ng�n h�ng ?ang cung c?p t�nh ??n ng�y hi?n t?i (sysdate) 
--(M� s?n ph?m, T?ng s? d?, Ng�y t�nh to�n)
--+ INSERT d? li?u ?� v�o b?ng HOCVIEN_BC_PRODUCT theo c�c tr??ng th�ng tin t??ng ?ng (Check ?i?u ki?n: M?i s?n ph?m ch? ???c INSERT 1 l?n/1 ng�y)
create or replace procedure insert_serv(
    v_product_name in product.name%type
)
as
    V_PRO_CD product.product_cd%type;
    v_total account.avail_balance%type;
    v_existing_count number;
begin
    -- Ki?m tra xem d? li?u cho s?n ph?m ?� t?n t?i trong ng�y hi?n t?i ch?a
    select count(*) into v_existing_count
    from hocvien_bc_product
    where product_cd in (select p.product_cd
                         from product p
                         where p.name = v_product_name)
    and trunc(calc_date) = trunc(sysdate);

    -- N?u kh�ng t?n t?i d? li?u cho s?n ph?m trong ng�y hi?n t?i, ti?n h�nh ch�n d? li?u m?i
    if v_existing_count = 0 then
        select p.product_cd, sum(avail_balance) into v_pro_cd, v_total
        from account a
        join product p
        on a.product_cd = p.product_cd
        where p.name = v_product_name
        group by p.product_cd;
        
        INSERT INTO hocvien_bc_product(PRODUCT_CD, total_balance, calc_date)
        values(v_pro_cd, v_total, sysdate);
        
        dbms_output.put_line('D? li?u ?� ???c ch�n th�nh c�ng cho s?n ph?m ' || v_product_name);
    else
        dbms_output.put_line('D? li?u cho s?n ph?m ' || v_product_name || ' ?� t?n t?i trong ng�y h�m nay.');
    end if;
end;

exec insert_serv('savings account');
select * from hocvien_bc_product;
select * from product;
--Vi?t 1 Procedure kh�ng tham s? th?c hi?n c�ng vi?c UPDATE/INSERT d? li?u trong b?ng hocvien_customer theo ?i?u ki?n sau:
--Ki?m tra trong b?ng hocvien_customer ?� c� d? li?u kh�ch h�ng c?a b?ng customer ch?a? (So s�nh cust_id 2 b?ng v?i nhau)
--+ N?u ?� c� th� UPDATE l?i to�n b? d? li?u c?a c�c tr??ng b?ng hocvien_customer theo d? li?u c�c tr??ng t??ng ?ng b?ng customer
--+ N?u ch?a th� INSERT d? li?u v�o b?ng hocvien_customer  theo c�c tr??ng t??ng ?ng c?a b?ng customer
create or replace procedure update_data 
as
begin
    merge into hocvien_customer h
    using customer c
    on (h.cust_id = c.cust_id)
        when matched then
        update 
        set h.address = c.address,
            h.city = c.city,
            h.cust_type_cd = c.cust_type_cd,
            h.fed_id = c.fed_id,
            h.postal_code = c.postal_code,
            h.state = c.state 
        when not matched then
            INSERT (cust_id, city, address, cust_type_cd, fed_id, postal_code, state)
            VALUES (c.cust_id, c.city, c.address, c.cust_type_cd, c.fed_id, c.postal_code, c.state);
end;
exec update_data;
--Vi?t 1 Procedure cho ph�p truy?n 3 tham s?: User ??ng nh?p db, ki?u d? li?u c?a c?t, gi� tr? c?n t�m. 
--T�m t?ng s? b?n ghi c?a m?i tr??ng trong m?i b?ng c� gi� tr? gi?ng v?i gi� tr? truy?n v�o. 
--In ra k?t qu? theo m?u sau: T�N B�NG + T�N C?T + T?NG S? GI� TR?
--(V� d?: V?i b?ng CUSTOMER v?i gi� tr? c?n t�m l� �%ma%� th� m?i C?T trong b?ng CUSTOMER s? c� t?ng nh?ng gi� tr? t??ng ?ng vs gi� tr? c?n t�m nh? sau :
--CUSTOMER - ADDRESS - 4
--CUSTOMER - CITY - 4
--)
--* G?i �: S? d?ng c�u l?nh sau ?? l?y ra t?t c? b?ng + c?t trong db: 
SELECT  owner, table_name, column_name FROM all_tab_columns WHERE owner = 'USER01' and data_type LIKE '%CHAR%';
CREATE OR REPLACE PROCEDURE find_matching_values (
    p_username IN VARCHAR2,
    p_data_type IN VARCHAR2,
    p_search_value IN VARCHAR2
)
IS
    v_count number;
bEGIN
    for i in (select owner, table_name, column_name
              from all_tab_columns
              WHERE owner = p_username 
              and data_type LIKE Upper('%' || p_search_value || '%'))
    LOOP 
        EXECUTE IMMEDIATE
        'SELECT COUNT(*) FROM ' || i.owner || '.' || i.table_name ||
        ' WHERE '||i.column_name||' like  UPPER(''%'||p_search_value||'%'')'
        INTO v_count;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE(i.table_name || ' - ' || i.column_name || ' - ' || v_count);
        END IF;
    end loop;
end;
set serveroutput on;
exec find_matching_values('INDA02', 'VARCHAR2', 'HCM');
