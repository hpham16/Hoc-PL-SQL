set serveroutput on;
------------------------------DATATYPE, CONTROL STATEMENT, CURSOR--------------------------------
--Bài 1: Vi?t ch??ng trình PL/SQL cho phép truy?n vào 1 tham s?: Id nhân viên. L?y ra first_name,last_name c?a nhân viên ?ó(s? d?ng thu?c tính% ROWTYPE).
DECLARE
    v_emp employee%ROWTYPE;
	v_emp_id employee.emp_id%type:=&employee_id;
BEGIN
    SELECT *
    INTO   v_emp
    FROM   employee
    WHERE  emp_id = v_emp_id;
    
    dbms_output.Put_line (v_emp.first_name || ' ' || v_emp.last_name);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.Put_line ('No employee have id: ' || v_emp_id);
END; 
--Bài 2: Vi?t ch??ng trình PL/SQL ?? hi?n th? thông tin chi ti?t c?a t?t c? nhân viên bao g?m: emp_id, first_name,last_name  (S? d?ng con tr?).
DECLARE 
    CURSOR emp_info IS 
        SELECT first_name, last_name
        FROM   employee; 
    v_emp_info emp_info%ROWTYPE; 
BEGIN 
    OPEN emp_info; 

    LOOP 
        FETCH emp_info INTO v_emp_info; 

        EXIT WHEN emp_info%NOTFOUND; 

        dbms_output.Put_line('ID: ' ||v_emp_info.emp_id ||'  Name: ' ||v_emp_info.first_name  ||' '  ||v_emp_info.last_name); 
    END LOOP; 
    CLOSE emp_info; 
END;
--Bài 3: Vi?t ch??ng trình PL/SQL ?? hi?n th? thông tin chi ti?t c?a t?t c? nhân viên bao g?m: emp_id,first_name,last_name, salary 
--(Ki?m tra n?u salary > 500 thì tr? v? salary hi?n t?i, n?u  <500 thì tr? ra thông báo: salary is less then 500). (S? d?ng con tr?).
DECLARE 
    CURSOR emp_info_sal IS 
        SELECT emp_id, first_name, last_name, salary 
        FROM   employee; 
    v_emp_info emp_info_sal%ROWTYPE; 
BEGIN 
    OPEN emp_info_sal; 

    LOOP 
        FETCH emp_info_sal INTO v_emp_info; 

        EXIT WHEN emp_info_sal%NOTFOUND; 
        
        dbms_output.Put_line('ID: ' ||v_emp_info.emp_id ||'  Name: ' ||v_emp_info.first_name  ||' '  ||v_emp_info.last_name); 
        if v_emp_info.salary > 500 then
        dbms_output.Put_line('salary: ' || v_emp_info.salary); 
        else
        dbms_output.Put_line('salary is less then 500'); 
        end if;
    END LOOP; 
    CLOSE emp_info_sal; 
END;
--Bài 4: Vi?t ch??ng trình PL/SQL ?? hi?n th? ra h? và tên c?a nh?ng nhân viên ?ang có m?c l??ng > m?c l??ng trung bình c?a phòng ban nhân viên ?ó ?ang làm vi?c (S? d?ng con tr?).
DECLARE
    CURSOR emp_cur IS
        SELECT first_name,last_name
        FROM employee e
        WHERE salary > ( SELECT avg(salary) FROM employee WHERE e.dept_id = dept_id);
BEGIN
  FOR i IN emp_cur
  LOOP
    DBMS_OUTPUT.PUT_LINE(i.first_name || ' '  || i.last_name);
    
  END LOOP;
END;
--Bài 5: Vi?t ch??ng trình PL/SQL cho phép hi?n th? s? l??ng nhân viên ?ã b?t ??u vào công ty làm vi?c theo tháng.
DECLARE
    sonv NUMBER;
BEGIN

FOR i IN 1..12 LOOP
    SELECT Count(*)
    INTO   sonv
    FROM   employee
    WHERE  extract(month from start_date) = i;

    dbms_output.Put_line('Month: ' || i || 'Number of emp: ' || sonv);
END LOOP;
END; 
------------------------------------------------FUCTION -----------------------------------------------------
--Bài 6: Vi?t 1 Function cho phép chuy?n ??i nhi?t ?? theo thang ?? F sang ?? C và ng??c l?i (Truy?n tham s? bao g?m: Nhi?t ??, thang ?? c?n chuy?n) tính theo công th?c sau:
--T (° F) = T (° C) × 9/5 + 32
--T (° C) = T (° F) - 32 * 5/9
CREATE OR REPLACE FUNCTION change_temp(v_temp NUMBER, v_name in  varCHAR2)
RETURN number
IS 
new_temp  NUMBER;

BEGIN
    if v_name = 'C' then
        new_temp := v_temp * 9 / 5 + 32;
    elsif v_name = 'F' then
        new_temp := v_temp - 32 * 5 / 9;
    end if;
RETURN new_temp;
END;

--Bài 7: Vi?t 1 Function cho phép truy?n vào tên phòng ban và tr? v? danh sách t?t c? nhân viên c?a phòng ban ?ó (m?i tên nhân viên phân tách b?ng d?u ph?y).
CREATE OR REPLACE FUNCTION info_emp_in_dept(v_dept_id in department.name%type) 
return VARCHAR2
is emp VARCHAR2(1000);
begin
        SELECT LISTAGG(first_name || ' ' || last_name, ',') WITHIN GROUP(ORDER BY first_name) INTO emp
        FROM employee e
        join department d
        on e.dept_id = d.dept_id
        where  e.dept_id = v_dept_id;
    return emp;
end;
--Bài 8: Vi?t 1 Function cho phép truy?n vào mã tài kho?n (account_id) và ki?m tra xem ngày m? tài kho?n (open_date) ?ó có ph?i là ngày cu?i tu?n hay không (T7,CN)
CREATE OR REPLACE FUNCTION check_open_day(acc_id IN number) 
RETURN VARCHAR2
IS 
get_day VARCHAR2(20);
new_day varchar2(10);
v_open_date DATE;
BEGIN
        select open_date into v_open_date
        from account
        where account_id = acc_id;
        get_day := RTRIM(TO_CHAR(v_open_date, 'DAY'));
        IF get_day IN ('SATURDAY', 'SUNDAY') THEN
        new_day:='Yes';
        ELSE
        new_day:='No';
        END IF;
RETURN new_day;
END;
--Bài 9:  Vi?t 1 Function cho phép truy?n vào mã phòng ban, 
--??m t?ng s? l??ng nhân viên c?a phòng ban ?ó và ki?m tra xem phòng ban ?ó có c?n tuy?n d?ng thêm hay không . (Gi? s? s? l??ng nhân viên yêu c?u m?i phòng là: 30 ng??i)
CREATE OR REPLACE FUNCTION check_dept(v_dept_id in department.dept_id%type) 
RETURN VARCHAR2
IS 
v_result VARCHAR2(20);
v_numemp number;
    
BEGIN
    select count(*) into v_numemp
    from employee 
    where dept_id = v_dept_id;
    if v_numemp < 30 then
        v_result := 'Yes';
    else
        v_result := 'No';
    end if;
RETURN v_result;
END;

--Bài 10: Vi?t 1 Function cho phép truy?n vào mã khách hàng, ngày b?t k?. 
--Ki?m tra xem tính t? ngày là tham s? truy?n vào ?ã bao nhiêu ngày khách hàng ch?a phát sinh giao d?ch (TXN_date). N?u >=50 ngày ??a ra c?nh báo.
CREATE OR REPLACE FUNCTION check_txn_date(v_cust_id in customer.cust_id%type, v_date in date) 
RETURN VARCHAR2
IS 
    max_txn_date date;
    v_result varchar2(20);
    time_date number;
BEGIN
    select max(txn_date) into max_txn_date
    from acc_transaction acc
    join account a
    on acc.account_id = a.account_id
    where a.cust_id = v_cust_id;
    time_date:= trunc(v_date) - trunc(max_txn_date);
    if time_date >= 50 then
        v_result := 'Waring';
    else
        v_result := 'Ok';
    end if;
RETURN v_result;
END;

  

------------------------------------------------PROCEDURE/PACKAGE/TRIGGER/MERGE -----------------------------------
--Bài 11: Vi?t 1 Procedure cho phép Insert d? li?u vào b?ng emp_temp t? b?ng employee. In ra t?ng s? l??ng b?n ghi ?ã INSERT
--S? d?ng câu l?nh sau ?? t?o b?ng ?ích
DROP TABLE emp_temp;
CREATE TABLE emp_temp (
  emp_id      NUMBER,
  end_date DATE
);

CREATE OR REPLACE PROCEDURE insert_emp_temp
AS
    rows_inserted integer; 
BEGIN
    INSERT INTO emp_temp (emp_id, end_date)
    SELECT emp_id, end_date 
    FROM employee ;
    rows_inserted := sql%rowcount;
    dbms_output.Put_line(', inserted=>' || to_char(rows_inserted));
    COMMIT;
END;
exec insert_emp_temp;
--Bài 12: S? d?ng b?ng emp_temp t? bài 11.Vi?t 1 Procedure cho phép truy?n vào mã mã nhân viên. 
--Ki?m tra nhân viên ?ó trong b?ng employee, n?u nhân viên ?ó ?ã ngh? vi?c thì xóa nhân viên ?ó trong b?ng emp_temp.  In ra thông báo (S? d?ng SQL%FOUND)
CREATE OR REPLACE PROCEDURE check_emp_id ( v_emp_id NUMBER)
IS
BEGIN
    DELETE  FROM emp_temp
    WHERE  emp_temp.emp_id = v_emp_id AND
    EXISTS (
    SELECT * FROM employee emp 
    WHERE emp.emp_id = emp_temp.emp_id AND emp.end_date IS NOT NULL);
 
  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE ('Delete succeeded for employee_id: ' || v_emp_id);
  ELSE
    DBMS_OUTPUT.PUT_LINE ('No employee of ID '|| v_emp_id||' is found.');
  END IF;
  COMMIT;
END;
--Bài 13: Vi?t 1 Procedure cho phép truy?n mã khách hàng.
--Ki?m tra xem ?ng v?i m?i tài kho?n c?a khách hàng ?ó ngày th?c hi?n giao d?ch ??u tiên (funds_avail_date) 
--có trùng v?i ngày m? tài kho?n (open_date) hay không? N?u có thì in ra thông báo
create or replace procedure check_cust_date (v_cust_id in customer.cust_id%type)
is
    cursor c_open_date is
        select account_id, open_date
        from account a
        where a.cust_id = v_cust_id;
    first_date date;
    v_open_date date;
begin
    for i in c_open_date 
    loop
        select funds_avail_date into first_date
        from acc_transaction acc
        where acc.account_id = i.account_id;
    if first_date = i.open_date then
        DBMS_OUTPUT.PUT_LINE ('Tai khoan ' || i.account_id ||' Giao dich voi ngay dau tien mo tai khoan');
    else
        DBMS_OUTPUT.PUT_LINE ('Tai khoan ' || i.account_id ||' Khong giao dich');
    end if;
    end loop;
end;

exec check_cust_date(1);
    

--Bài 14: Vi?t 1 Procedure cho phép truy?n 2 tham s?: mã nhân viên, m?c target. Tính l?i m?c l??ng c?a nhân viên trong b?ng hocvien_customer theo công th?c sau:
--+ N?u t?ng s? tài kho?n ?ã m? theo nhân viên ?ó (total_acc_achieve) > m?c target truy?n vào + 2 (target_qty) thì: M?c l??ng m?i = m?c l??ng c? * (acc_achieve - target_qty)/4
--+ N?u không ??t theo ch? tiêu này thì m?c l??ng gi? nguyên
create or replace procedure check_target (v_emp_id in employee.emp_id%type, v_target number)
is
    total_acc_achieve number;
begin
    select count (distinct account_id) into total_acc_achieve
    from account  
    where open_emp_id = v_emp_id;       
    if total_acc_achieve > v_target + 2 then
        UPDATE employee_backup
        SET salary = salary * (total_acc_achieve - v_target) / 4 
        WHERE emp_id = emp_id;
    DBMS_OUTPUT.PUT_LINE ('Vuot chi tieu. Da tang luong!');
    else
    DBMS_OUTPUT.PUT_LINE ('Khong vuot chi tieu luong giu nguyen');
    end if;
end;
exec check_target(10,8);

--Bài 15:  Vi?t 1 Procedure cho phép INSERT/UPDATE d? li?u trong b?ng <Tên h?c viên>_EMP_LOAD theo yêu c?u sau:
--+ N?u nhân viên ?ó ?ã có trong b?ng: <Tên h?c viên>_EMP_LOAD. Ki?m tra t? b?ng EMPLOYEE n?u nhân viên ?ó có ngày 
--END_DATE  >= START_DATE thì c?p nh?t l?i  END_DATE và STATUS  c?a b?ng <Tên h?c viên>_EMP_LOAD nh? sau:
--<Tên h?c viên>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE và <Tên h?c viên>_EMP_LOAD.STATUS = 0
--+ N?u nhân viên ?ó ch?a có trong b?ng: <Tên h?c viên>_EMP_LOAD. INSERT toàn b? d? li?u t? b?ng EMPLOYEE vào <Tên h?c viên>_EMP_LOAD
create or replace procedure update_emp
is
begin
    merge into huyhung_EMP_LOAD empl 
    USING
        (select emp_id, first_name, last_name, end_date, start_date,
         CASE WHEN end_date >= start_date THEN 0 ELSE 1 END STATUS
         from employee) emp
    ON (emp.emp_id = empl.emp_id)
    WHEN MATCHED THEN
        UPDATE 
        SET 
        empl.end_date = emp.end_date,
        empl.status = 0
    WHERE empl.start_date <= emp.end_date
WHEN NOT MATCHED THEN
        INSERT 
        (empl.EMP_ID,
        empl.END_DATE,
        empl.FIRST_NAME,
        empl.LAST_NAME,
        empl.START_DATE,
        empl.STATUS)
        VALUES (emp.EMP_ID,
        emp.END_DATE,
        emp.FIRST_NAME,
        emp.LAST_NAME,
        emp.START_DATE,
        emp.STATUS);
commit;
end;


--Bài 16: Vi?t 1 Procedure không tham s? th?c hi?n công vi?c UPDATE/INSERT d? li?u trong b?ng hocvien_customer theo ?i?u ki?n sau:
--Ki?m tra trong b?ng hocvien_customer ?ã có d? li?u khách hàng c?a b?ng customer ch?a? (So sánh cust_id 2 b?ng v?i nhau)
--+ N?u ?ã có thì UPDATE l?i toàn b? d? li?u c?a các tr??ng b?ng hocvien_customer theo d? li?u các tr??ng t??ng ?ng b?ng customer
--+ N?u ch?a thì INSERT d? li?u vào b?ng hocvien_customer  theo các tr??ng t??ng ?ng c?a b?ng customer
select * from customer;
create or replace procedure update_customer
is
begin
    merge into hocvien_customer hv 
    USING customer c
    ON (c.cust_id = hv.cust_id)
    WHEN MATCHED THEN
        UPDATE 
        SET 
        hv.address = c.address,
        hv.city = c.city,
        hv.cust_type_cd = c.cust_type_cd,
        hv.fed_id = c.fed_id,
        hv.postal_code = c.postal_code,
        hv.state = c.state
    WHEN NOT MATCHED THEN
        INSERT 
        (cust_id, address, city, cust_type_cd, fed_id, postal_code, state)
        VALUES 
        (c.cust_id, c.address, c.city, c.cust_type_cd, c.fed_id, c.postal_code, c.state);
--commit;
end;
--Bài 17: Vi?t 1 Package th?c hi?n yêu c?u sau:
---  1 Con tr? tr? v? chi ti?t tài kho?n theo ID khách hàng truy?n vào bao g?m các thông tin sau: Mã khách hàng, ??a ch? khách hàng, ID tài kho?n, S? d?, Tr?ng thái
---  1 Hàm cho phép truy?n vào: ID khách hàng. Tr? v? T?ng s? d? theo khách hàng
---  1 Hàm cho phép truy?n vào: ID nhân viên m? + N?m m? tài kho?n. Tr? v? T?ng s? d? theo nhân viên m? tài kho?n 
--G?i con tr?, Hàm thông qua package v?a t?o
create or replace package spec_cust 
as
    cursor info_cust (v_cust_id customer.cust_id%type)
    is
        select a.cust_id, address, account_id, avail_balance, status
        from account a
        join customer c
        on c.cust_id = a.cust_id
        where c.cust_id = v_cust_id;
    
    function total_cust (v_cust_id customer.cust_id%type)
    return float;
    
    function emp_open (v_emp_id employee.emp_id%type, v_open_date number)
    return float;
end;
create or replace package body spec_cust 
as
    function total_cust (v_cust_id customer.cust_id%type)
    return float
    is v_total float;
    begin
        select sum(avail_balance) into v_total
        from account a
        join customer c
        on a.cust_id = c.cust_id
        where a.cust_id = v_cust_id;
    return v_total;
    exception
        when no_data_found then
        dbms_output.put_line('NO DATA FOUND');
    end;
    ------
    function emp_open (v_emp_id employee.emp_id%type, v_open_date number)
    return float
    is v_total_emp float;
    begin
        select nvl(sum(avail_balance),0.0) into v_total_emp
        from account a
        right join employee e
        on a.open_emp_id = e.emp_id
        where e.emp_id = v_emp_id
        and extract(year from open_date) = v_open_date; 
        return v_total_emp;

    exception
        when no_data_found then
        dbms_output.put_line('NO DATA FOUND');
    end emp_open;
end;

--goi con tro
DECLARE
    cust_id number;
    address varchar2(100);
    account_id number;
    tot_bal number;
    status varchar2(100);
BEGIN
   OPEN spec_cust.info_cust(3);
   LOOP
      FETCH spec_cust.info_cust INTO cust_id,address,account_id,tot_bal,status; 
      Dbms_Output.Put_Line(' ID: ' || cust_id);
      Dbms_Output.Put_Line(' Dia chi:  ' || address); 
      Dbms_Output.Put_Line(' So tai khoan: ' || account_id);
      Dbms_Output.Put_Line(' Tong so du: ' || tot_bal);
      Dbms_Output.Put_Line(' Trang Thai: ' || status);
      EXIT WHEN  spec_cust.info_cust%NOTFOUND;
   END LOOP;
  CLOSE spec_cust.info_cust;
END;
--goi ham
select spec_cust.total_cust(1) from dual;
select spec_cust.emp_open(10,2005) from dual;
--Bài 18: Vi?t 1 Trigger cho phép t? ??ng Bonus cho ng??i qu?n lý 10% l??ng c?a nhân viên m?i 
--G?i ý: Khi có nhân viên m?i ???c thêm vào database. Insert thêm 1 b?ng ghi m?i vào b?ng BONUS v?i (ID nhân viên qu?n lý, 10% l??ng t??ng ?ng)
--
create or replace trigger bonus_manager
after insert or update on employee
    for each row
    begin
        insert into bonus(superior_emp_id, emp_id, bonus)
        values(:new.superior_emp_id, :new.emp_id, :new.salary/10)  ;
end;
------------------------------------------------INDEX/ PARTITION -----------------------------------
--Bài 19 : Hãy ?ánh index cho b?ng HOCVIEN_EMPLOYEE ?? t?ng t?c truy v?n nhân viên theo tên (FIRST_NAME,LAST_NAME)
CREATE INDEX ind_fn_ln ON hocvien_employee(first_name, last_name);


--Bài 20: ?ánh index ?? t?ng t?c ?? truy v?n c?a khác hàng theo khu v?c (STATE) c?a b?ng HOVVIEN_CUSTOMER
CREATE BITMAP INDEX ind_state ON hocvien_customer(state);
--Bài 21:  S? d?ng ki?u Phân vùng ph?m vi (Range Partition) ?? th?c hi?n phân vùng ph?m vi trên tr??ng TXN_DATE c?a bàng HOCVIEN_ACC_TRANSACTION theo 5 partition:
--ACC_TRANSACTION_2001 VALUES LESS THAN (TO_DATE('01-JAN-2001','DD-MON-YYYY')),
--ACC_TRANSACTION_2002 VALUES LESS THAN (TO_DATE('01-JAN-2002','DD-MON-YYYY')),
--ACC_TRANSACTION_2003 VALUES LESS THAN (TO_DATE('01-JAN-2003','DD-MON-YYYY')),
--ACC_TRANSACTION_2004 VALUES LESS THAN (TO_DATE('01-JAN-2004','DD-MON-YYYY')),
--ACC_TRANSACTION_2005 VALUES LESS THAN (TO_DATE('01-JAN-2005','DD-MON-YYYY'))
-- 
ALTER TABLE acc_transaction
MODIFY PARTITION BY RANGE(txn_date)
(
 partition ACC_TRANSACTION_2001 VALUES LESS THAN (TO_DATE('01-JAN-2001','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2002 VALUES LESS THAN (TO_DATE('01-JAN-2002','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2003 VALUES LESS THAN (TO_DATE('01-JAN-2003','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2004 VALUES LESS THAN (TO_DATE('01-JAN-2004','DD-MON-YYYY')),
 partition ACC_TRANSACTION_2005 VALUES LESS THAN (TO_DATE('01-JAN-2005','DD-MON-YYYY'))
);
--Bài 22:  S? d?ng ki?u Phân vùng danh sách (List Partition) ?? th?c hi?n phân vùng theo theo t?ng STATE c?a khách hàng (b?ng HOCVIEN_CUSTOMER)
--PARTITION STATE_MA VALUES ('MA'),
--PARTITION STATE_NH VALUES ('NH'),
--PARTITION STATE_MA VALUES (DEFAULT)
--
select * from customer;
ALTER TABLE CUSTOMER MODIFY
  PARTITION BY LIST (STATE) 
  (
    PARTITION STATE_MA VALUES ('MA'),
    PARTITION STATE_NH VALUES ('NH'),
    PARTITION STATE_MA VALUES (DEFAULT),
  );
