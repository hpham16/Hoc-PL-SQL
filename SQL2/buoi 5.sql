----D? li?u ?? th?c hành ???c mô t? chi ti?t t?i bài th?c hành 1, N?u ch?a n?m rõ xin vui lòng xem l?i. 
----?ây là 2 table s? s? d?ng trong bài lab này:
--
------------------ FUNCTION-----------------------------
--Bài 1.
-- Vi?t 1 Function v?i tham s? ??u vào là N?M c?n l?y d? li?u. 
--Tính t?ng s? d? tài kho?n (ACCOUNT) c?a t?t c? khách hàng có N?m m? tài kho?n b?ng N?M truy?n vào
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
--Bài 2.  
--Vi?t 1 Function v?i tham s? ??u vào là ID c?a khách hàng.
--L?y ra T?ng s? TK ?ã m? c?a khách hàng có ID = ID truy?n vào
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

--Bài 3.
--Vi?t 1 Function v?i tham s? ??u vào là ID nhân viên
--Th?c hi?n Tính s? n?m ?ã làm vi?c c?a nhân viên ?ó theo công th?c sau:
--work_exp  = S? tháng c?a Ngày hi?n t?i so v?i ngày b?t ??u vào làm / 12
--Th?c hi?n truy v?n l?y ra thông tin c?a nhân viên bao g?m: H?, Tên, Ngày b?t ??u làm vi?c, s? tháng ?ã làm vi?c (G?i ??n Function trên)
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
--Bài 4:
--Vi?t Function “FUNC_Get_Emp_Department” v?i tham s? ??u vào là mã nhân viên EMP_ID và tr? v? tên phòng ban mà nhân viên ?ó làm vi?c (Dept_Name).
---      Yêu c?u 1: Truy?n vào ID là 1 và hi?n th? k?t qu? ra màn hình “Get_Emp_Department(1)”;
---  	Yêu c?u 2: Vi?t l?nh SELECT ?? l?y ra toàn b? EMP_ID, First_Name, Last_Name và tên phòng ban s? d?ng Function “FUNC_Get_Emp_Department”.
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
--Bài 1:
-- Vi?t  1 procedure không có tham s?. Tr? v? t?t c? thông tin c?a các nhân viên bao g?m: H?, Tên, Phòng ban, Ngày vào làm
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
--Bài 2:
--Vi?t procedure “PRO_Get_Employee_Info” cho phép truy?n vào ID c?a nhân viên và tr? v? First_Name, Last_Name, Dept_ID c?a nhân viên ?ó.
--G?i ý: khai báo 3 bi?n: First_Name, Last_Name, Dept_ID ?? ?ón k?t qu?  OUT t?  procedure.
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
--Ch?y Procedure và hi?n th? k?t qu? b?ng câu l?nh DBMS_OUTPUT.PUT_LINE().
--Bài 3: 
-- Vi?t 1 Procedure tr? ra phân khúc khách hàng theo t?ng khách hàng truy?n vào theo công th?c sau:
--N?u:
-- “AVAIL_BALANCE <= 4000” thì SEGMENT là: “LOW”,
--“AVAIL_BALANCE > 4000 và AVAIL_BALANCE <= 7000” thì SEGMENT là: “MEDIUM”, “AVAIL_BALANCE >7000” thì SEGMENT là: “HIGH”
--(G?i y: 2 tham s?: IN – id khách hàng, OUT- segment)
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
--1. Vi?t 1 FUNCTION cho phép truy?n vào 1 tham s?. N?u tham s? truy?n vào là ‘EMP’ thì l?y ra t?ng s? nhân viên, 
--n?u tham s? truy?n vào là ‘DEPT’ thì l?y ra t?ng s? phòng ban.
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
--2.Vi?t 1 FUNCTION cho phép truy?n vào ID tài kho?n (account_id). 
--L?y ra tr?ng thái c?a giao d?ch m?i nh?t ?ng v?i ID tài kho?n ?ó theo yêu c?u sau:
--+ N?u Giao d?ch m?i nh?t >= ngày hi?n t?i thì tr?ng thái : 'The payment has been Completed'
--+ N?u Giao d?ch m?i nh?t < ngày hi?n t?i thì tr?ng thái : Ngày giao d?ch + ' yet to be paid'
--+ Còn l?i: 'Invalid payment'
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
--3.Vi?t 1 Function cho phép truy?n vào tham s? là ngày b?t k?. 
--L?y ra t?t c? nhân viên có ngày b?t ??u làm vi?c >= ngày truy?n vào 
--(L?u ý: Có tr??ng h?p nhân vi?n ?ã ngh? và l?i ti?p t?c ?i làm tr? l?i)
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

--Vi?t 1 Function cho phép truy?n vào tham s? là ngày b?t k?. 
--L?y ra t?ng s? các tài kho?n ?ã ???c m? c?a t?t c? nhân viên 
--tính ??n th?i ?i?m là ngày truy?n vào và ch? tính nh?ng nhân viên có s? tháng làm vi?c tính ??n th?i ?i?m ngày truy?n vào là >13 tháng.
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

--Vi?t 1 Procedure cho phép truy?n vào 2 tham s?: Mã phòng ban, H?  s? l??ng. 
--C?p nh?t l?i l??ng c?a NV có mã phòng ban truy?n vào theo yêu  c?u sau:
--* S? d?ng Function work_time ?? ki?m tra xem nhân viên ?ó có s? n?m làm vi?c  >=13 hay không.
--N?u ?? thì update l?i l??ng c?a NV (B?ng hocvien_employee) ?ó theo CT:
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
--Vi?t 1 Procedure cho phép truy?n vào tên s?n ph?m d?ch v? c?a ngân hàng ?ang cung c?p và th?c hi?n công vi?c sau:
--+ Tính t?ng s? d? theo t?ng tên s?n ph?m d?ch v? c?a ngân hàng ?ang cung c?p tính ??n ngày hi?n t?i (sysdate) 
--(Mã s?n ph?m, T?ng s? d?, Ngày tính toán)
--+ INSERT d? li?u ?ó vào b?ng HOCVIEN_BC_PRODUCT theo các tr??ng thông tin t??ng ?ng (Check ?i?u ki?n: M?i s?n ph?m ch? ???c INSERT 1 l?n/1 ngày)
create or replace procedure insert_serv(
    v_product_name in product.name%type
)
as
    V_PRO_CD product.product_cd%type;
    v_total account.avail_balance%type;
    v_existing_count number;
begin
    -- Ki?m tra xem d? li?u cho s?n ph?m ?ã t?n t?i trong ngày hi?n t?i ch?a
    select count(*) into v_existing_count
    from hocvien_bc_product
    where product_cd in (select p.product_cd
                         from product p
                         where p.name = v_product_name)
    and trunc(calc_date) = trunc(sysdate);

    -- N?u không t?n t?i d? li?u cho s?n ph?m trong ngày hi?n t?i, ti?n hành chèn d? li?u m?i
    if v_existing_count = 0 then
        select p.product_cd, sum(avail_balance) into v_pro_cd, v_total
        from account a
        join product p
        on a.product_cd = p.product_cd
        where p.name = v_product_name
        group by p.product_cd;
        
        INSERT INTO hocvien_bc_product(PRODUCT_CD, total_balance, calc_date)
        values(v_pro_cd, v_total, sysdate);
        
        dbms_output.put_line('D? li?u ?ã ???c chèn thành công cho s?n ph?m ' || v_product_name);
    else
        dbms_output.put_line('D? li?u cho s?n ph?m ' || v_product_name || ' ?ã t?n t?i trong ngày hôm nay.');
    end if;
end;

exec insert_serv('savings account');
select * from hocvien_bc_product;
select * from product;
--Vi?t 1 Procedure không tham s? th?c hi?n công vi?c UPDATE/INSERT d? li?u trong b?ng hocvien_customer theo ?i?u ki?n sau:
--Ki?m tra trong b?ng hocvien_customer ?ã có d? li?u khách hàng c?a b?ng customer ch?a? (So sánh cust_id 2 b?ng v?i nhau)
--+ N?u ?ã có thì UPDATE l?i toàn b? d? li?u c?a các tr??ng b?ng hocvien_customer theo d? li?u các tr??ng t??ng ?ng b?ng customer
--+ N?u ch?a thì INSERT d? li?u vào b?ng hocvien_customer  theo các tr??ng t??ng ?ng c?a b?ng customer
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
--Vi?t 1 Procedure cho phép truy?n 3 tham s?: User ??ng nh?p db, ki?u d? li?u c?a c?t, giá tr? c?n tìm. 
--Tìm t?ng s? b?n ghi c?a m?i tr??ng trong m?i b?ng có giá tr? gi?ng v?i giá tr? truy?n vào. 
--In ra k?t qu? theo m?u sau: TÊN BÁNG + TÊN C?T + T?NG S? GIÁ TR?
--(Ví d?: V?i b?ng CUSTOMER v?i giá tr? c?n tìm là ‘%ma%’ thì m?i C?T trong b?ng CUSTOMER s? có t?ng nh?ng giá tr? t??ng ?ng vs giá tr? c?n tìm nh? sau :
--CUSTOMER - ADDRESS - 4
--CUSTOMER - CITY - 4
--)
--* G?i ý: S? d?ng câu l?nh sau ?? l?y ra t?t c? b?ng + c?t trong db: 
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
