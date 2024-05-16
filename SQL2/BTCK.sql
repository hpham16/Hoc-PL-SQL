set serveroutput on;
------------------------------DATATYPE, CONTROL STATEMENT, CURSOR--------------------------------
--B�i 1: Vi?t ch??ng tr�nh PL/SQL cho ph�p truy?n v�o 1 tham s?: Id nh�n vi�n. L?y ra first_name,last_name c?a nh�n vi�n ?�(s? d?ng thu?c t�nh% ROWTYPE).
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
--B�i 2: Vi?t ch??ng tr�nh PL/SQL ?? hi?n th? th�ng tin chi ti?t c?a t?t c? nh�n vi�n bao g?m: emp_id, first_name,last_name  (S? d?ng con tr?).
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
--B�i 3: Vi?t ch??ng tr�nh PL/SQL ?? hi?n th? th�ng tin chi ti?t c?a t?t c? nh�n vi�n bao g?m: emp_id,first_name,last_name, salary 
--(Ki?m tra n?u salary > 500 th� tr? v? salary hi?n t?i, n?u  <500 th� tr? ra th�ng b�o: salary is less then 500). (S? d?ng con tr?).
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
--B�i 4: Vi?t ch??ng tr�nh PL/SQL ?? hi?n th? ra h? v� t�n c?a nh?ng nh�n vi�n ?ang c� m?c l??ng > m?c l??ng trung b�nh c?a ph�ng ban nh�n vi�n ?� ?ang l�m vi?c (S? d?ng con tr?).
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
--B�i 5: Vi?t ch??ng tr�nh PL/SQL cho ph�p hi?n th? s? l??ng nh�n vi�n ?� b?t ??u v�o c�ng ty l�m vi?c theo th�ng.
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
--B�i 6: Vi?t 1 Function cho ph�p chuy?n ??i nhi?t ?? theo thang ?? F sang ?? C v� ng??c l?i (Truy?n tham s? bao g?m: Nhi?t ??, thang ?? c?n chuy?n) t�nh theo c�ng th?c sau:
--T (� F) = T (� C) � 9/5 + 32
--T (� C) = T (� F) - 32 * 5/9
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

--B�i 7: Vi?t 1 Function cho ph�p truy?n v�o t�n ph�ng ban v� tr? v? danh s�ch t?t c? nh�n vi�n c?a ph�ng ban ?� (m?i t�n nh�n vi�n ph�n t�ch b?ng d?u ph?y).
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
--B�i 8: Vi?t 1 Function cho ph�p truy?n v�o m� t�i kho?n (account_id) v� ki?m tra xem ng�y m? t�i kho?n (open_date) ?� c� ph?i l� ng�y cu?i tu?n hay kh�ng (T7,CN)
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
--B�i 9:  Vi?t 1 Function cho ph�p truy?n v�o m� ph�ng ban, 
--??m t?ng s? l??ng nh�n vi�n c?a ph�ng ban ?� v� ki?m tra xem ph�ng ban ?� c� c?n tuy?n d?ng th�m hay kh�ng . (Gi? s? s? l??ng nh�n vi�n y�u c?u m?i ph�ng l�: 30 ng??i)
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

--B�i 10: Vi?t 1 Function cho ph�p truy?n v�o m� kh�ch h�ng, ng�y b?t k?. 
--Ki?m tra xem t�nh t? ng�y l� tham s? truy?n v�o ?� bao nhi�u ng�y kh�ch h�ng ch?a ph�t sinh giao d?ch (TXN_date). N?u >=50 ng�y ??a ra c?nh b�o.
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
--B�i 11: Vi?t 1 Procedure cho ph�p Insert d? li?u v�o b?ng emp_temp t? b?ng employee. In ra t?ng s? l??ng b?n ghi ?� INSERT
--S? d?ng c�u l?nh sau ?? t?o b?ng ?�ch
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
--B�i 12: S? d?ng b?ng emp_temp t? b�i 11.Vi?t 1 Procedure cho ph�p truy?n v�o m� m� nh�n vi�n. 
--Ki?m tra nh�n vi�n ?� trong b?ng employee, n?u nh�n vi�n ?� ?� ngh? vi?c th� x�a nh�n vi�n ?� trong b?ng emp_temp.  In ra th�ng b�o (S? d?ng SQL%FOUND)
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
--B�i 13: Vi?t 1 Procedure cho ph�p truy?n m� kh�ch h�ng.
--Ki?m tra xem ?ng v?i m?i t�i kho?n c?a kh�ch h�ng ?� ng�y th?c hi?n giao d?ch ??u ti�n (funds_avail_date) 
--c� tr�ng v?i ng�y m? t�i kho?n (open_date) hay kh�ng? N?u c� th� in ra th�ng b�o
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
    

--B�i 14: Vi?t 1 Procedure cho ph�p truy?n 2 tham s?: m� nh�n vi�n, m?c target. T�nh l?i m?c l??ng c?a nh�n vi�n trong b?ng hocvien_customer theo c�ng th?c sau:
--+ N?u t?ng s? t�i kho?n ?� m? theo nh�n vi�n ?� (total_acc_achieve) > m?c target truy?n v�o + 2 (target_qty) th�: M?c l??ng m?i = m?c l??ng c? * (acc_achieve - target_qty)/4
--+ N?u kh�ng ??t theo ch? ti�u n�y th� m?c l??ng gi? nguy�n
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

--B�i 15:  Vi?t 1 Procedure cho ph�p INSERT/UPDATE d? li?u trong b?ng <T�n h?c vi�n>_EMP_LOAD theo y�u c?u sau:
--+ N?u nh�n vi�n ?� ?� c� trong b?ng: <T�n h?c vi�n>_EMP_LOAD. Ki?m tra t? b?ng EMPLOYEE n?u nh�n vi�n ?� c� ng�y 
--END_DATE  >= START_DATE th� c?p nh?t l?i  END_DATE v� STATUS  c?a b?ng <T�n h?c vi�n>_EMP_LOAD nh? sau:
--<T�n h?c vi�n>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE v� <T�n h?c vi�n>_EMP_LOAD.STATUS = 0
--+ N?u nh�n vi�n ?� ch?a c� trong b?ng: <T�n h?c vi�n>_EMP_LOAD. INSERT to�n b? d? li?u t? b?ng EMPLOYEE v�o <T�n h?c vi�n>_EMP_LOAD
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


--B�i 16: Vi?t 1 Procedure kh�ng tham s? th?c hi?n c�ng vi?c UPDATE/INSERT d? li?u trong b?ng hocvien_customer theo ?i?u ki?n sau:
--Ki?m tra trong b?ng hocvien_customer ?� c� d? li?u kh�ch h�ng c?a b?ng customer ch?a? (So s�nh cust_id 2 b?ng v?i nhau)
--+ N?u ?� c� th� UPDATE l?i to�n b? d? li?u c?a c�c tr??ng b?ng hocvien_customer theo d? li?u c�c tr??ng t??ng ?ng b?ng customer
--+ N?u ch?a th� INSERT d? li?u v�o b?ng hocvien_customer  theo c�c tr??ng t??ng ?ng c?a b?ng customer
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
--B�i 17: Vi?t 1 Package th?c hi?n y�u c?u sau:
---  1 Con tr? tr? v? chi ti?t t�i kho?n theo ID kh�ch h�ng truy?n v�o bao g?m c�c th�ng tin sau: M� kh�ch h�ng, ??a ch? kh�ch h�ng, ID t�i kho?n, S? d?, Tr?ng th�i
---  1 H�m cho ph�p truy?n v�o: ID kh�ch h�ng. Tr? v? T?ng s? d? theo kh�ch h�ng
---  1 H�m cho ph�p truy?n v�o: ID nh�n vi�n m? + N?m m? t�i kho?n. Tr? v? T?ng s? d? theo nh�n vi�n m? t�i kho?n 
--G?i con tr?, H�m th�ng qua package v?a t?o
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
--B�i 18: Vi?t 1 Trigger cho ph�p t? ??ng Bonus cho ng??i qu?n l� 10% l??ng c?a nh�n vi�n m?i 
--G?i �: Khi c� nh�n vi�n m?i ???c th�m v�o database. Insert th�m 1 b?ng ghi m?i v�o b?ng BONUS v?i (ID nh�n vi�n qu?n l�, 10% l??ng t??ng ?ng)
--
create or replace trigger bonus_manager
after insert or update on employee
    for each row
    begin
        insert into bonus(superior_emp_id, emp_id, bonus)
        values(:new.superior_emp_id, :new.emp_id, :new.salary/10)  ;
end;
------------------------------------------------INDEX/ PARTITION -----------------------------------
--B�i 19 : H�y ?�nh index cho b?ng HOCVIEN_EMPLOYEE ?? t?ng t?c truy v?n nh�n vi�n theo t�n (FIRST_NAME,LAST_NAME)
CREATE INDEX ind_fn_ln ON hocvien_employee(first_name, last_name);


--B�i 20: ?�nh index ?? t?ng t?c ?? truy v?n c?a kh�c h�ng theo khu v?c (STATE) c?a b?ng HOVVIEN_CUSTOMER
CREATE BITMAP INDEX ind_state ON hocvien_customer(state);
--B�i 21:  S? d?ng ki?u Ph�n v�ng ph?m vi (Range Partition) ?? th?c hi?n ph�n v�ng ph?m vi tr�n tr??ng TXN_DATE c?a b�ng HOCVIEN_ACC_TRANSACTION theo 5 partition:
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
--B�i 22:  S? d?ng ki?u Ph�n v�ng danh s�ch (List Partition) ?? th?c hi?n ph�n v�ng theo theo t?ng STATE c?a kh�ch h�ng (b?ng HOCVIEN_CUSTOMER)
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
