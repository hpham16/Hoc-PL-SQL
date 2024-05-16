--D? li?u ?? th?c hành ???c mô t? chi ti?t t?i bài th?c hành 1, N?u ch?a n?m rõ xin vui lòng xem l?i. 
------------------ PACKAGE-----------------------------
--Bài 1.
--Làm l?i ví d? m?u trong Slide
--Vi?t 1 Package th?c hi?n yêu c?u sau:
---  1 Con tr? tr? v? chi ti?t tài kho?n theo ID khách hàng truy?n vào bao g?m các thông tin sau:
--Mã khách hàng, ??a ch? khách hàng, ID tài kho?n, S? d?, Tr?ng thái
---  1 Hàm cho phép truy?n vào: ID khách hàng. Tr? v? T?ng s? d? theo khách hàng
---  1 Hàm cho phép truy?n vào: ID nhân viên m? + N?m m? tài kho?n. Tr? v? T?ng s? d? theo nhân viên m? tài kho?n 
--G?i con tr?, Hàm thông qua package v?a t?o
--
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


select spec_cust.info_cust(3) from dual;
select spec_cust.total_cust(1) from dual;
select spec_cust.emp_open(10,2005) from dual;

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

--Bài 2.  
--Vi?t 1 Package th?c hi?n yêu c?u sau:
--- 1 Th? t?c cho phép truy?n vào: ID nhân viên. Tr? v? H?, Tên, Mã phòng ban nhân viên ?ó.
--- 1 Hàm cho phép truy?n vào: ID nhân viên. Tr? v? Tên phòng ban c?a nhân viên ?ó.
--G?i Th? t?c và Hàm thông qua Package v?a t?o
create or replace package info_empp 
as
    procedure gett_info_emp( v_emp_id in employee.emp_id%type,
                            v_fname out employee.first_name%type,
                            v_lname out employee.last_name%type,
                            v_dept_id out employee.dept_id%type);
    function emp_dept_info (v_emp_id employee.emp_id%type)
    return Department.name%Type;
end;

create or replace package body info_empp 
as
    procedure gett_info_emp( v_emp_id in employee.emp_id%type,
                            v_fname out employee.first_name%type,
                            v_lname out employee.last_name%type,
                            v_dept_id out employee.dept_id%type)
    is
    begin
        select first_name, last_name, dept_id 
        into  v_fname, v_lname, v_dept_id
        from employee
        where emp_id = v_emp_id;
        
--        Dbms_Output.Put_Line('Ho: ' || v_emp_id);
--        Dbms_Output.Put_Line('Ten: ' || v_fname); 
--        Dbms_Output.Put_Line('dept_id ' || v_dept_id);

    end;
    --------
    function emp_dept_info (v_emp_id employee.emp_id%type)
    return Department.name%Type
    is v_name_dept Department.name%Type;
    begin
        select name into v_name_dept
        from employee e
        join department d
        on e.dept_id = d.dept_id
        where e.emp_id = v_emp_id;
        return v_name_dept;
    end;
end;

DECLARE
    v_emp_id number := 1;
    v_First_Name VARCHAR2(50);
    v_Last_Name VARCHAR2(50);
    v_Dept_Id Number;
    v_Emp_Department_name VARCHAR2(100);
BEGIN
dbms_output.put_line('Thông tin nhân viên bao g?m: ');
info_empp.gett_info_emp(v_emp_id, v_First_Name,v_Last_Name, v_Dept_Id);
v_Emp_Department_name:= info_empp.emp_dept_info(v_emp_id);
dbms_output.put_line('ID:' || v_emp_id || ' - Ho: ' || v_First_Name || '- Ten: ' || v_Last_Name || '- Department: ' || v_Emp_Department_name);	
END;
------------- TRIGGER------------------------
--Bài 1:
--T?o 1 Trigger cho phép backup l?i t?t c? nh?ng thay ??i c?a b?ng EMPLOYEE 
--(Insert d? li?u thay ??i c?a các tr??ng t??ng ?ng b?ng EMPLOYEE vào b?ng EMPLOYEE_BACKUP, CHANGE_DATE = SYSDATE)
create or replace trigger insert_employee
before insert on employee
    for each row
    begin
        insert into employee_backup(emp_id, end_date, first_name,
            last_name, start_date, title,
            assigned_branch_id, dept_id,
            superior_emp_id, salary, change_date)
        values(:new.emp_id, :new.end_date, :new.first_name,
            :new.last_name, :new.start_date, :new.title,
            :new.assigned_branch_id, :new.dept_id,
            :new.superior_emp_id, :new.salary, sysdate);
end;

create or replace trigger update_employee
before update on employee
    for each row
    begin
        insert into employee_backup(emp_id, end_date, first_name,
            last_name, start_date, title,
            assigned_branch_id, dept_id,
            superior_emp_id, salary, change_date)
        values(:new.emp_id, :new.end_date, :new.first_name,
            :new.last_name, :new.start_date, :new.title,
            :new.assigned_branch_id, :new.dept_id,
            :new.superior_emp_id, :new.salary, sysdate);
end;

create or replace trigger delete_employee
before delete on employee
    for each row
    begin
        insert into inda_employee_backup(emp_id, end_date, first_name,
            last_name, start_date, title,
            assigned_branch_id, dept_id,
            superior_emp_id, salary, change_date)
        values(:old.emp_id, :old.end_date, :old.first_name,
            :old.last_name, :old.start_date, :old.title,
            :old.assigned_branch_id, :old.dept_id,
            :old.superior_emp_id, :old.salary, sysdate);
end;

--Bài 2: 
--T?o 1 Trigger cho phép update l?i tr?ng thái c?a 2 tr??ng: Updated_date = sysdate, Updated_by = User khi có thay ??i b?ng ETL_CUSTOMER
create or replace trigger update_etl_cust
after insert or update on etl_customer
    for each row
    begin
    :new.Updated_by := User;
    :new.Updated_date := sysdate;    
end;
--Bài 3:
--Vi?t 1 Trigger cho phép t? ??ng Bonus cho ng??i qu?n lý 10% l??ng c?a nhân viên m?i 
--G?i ý: Khi có nhân viên m?i ???c thêm vào database. Insert thêm 1 b?ng ghi m?i vào b?ng BONUS v?i (ID nhân viên qu?n lý, 10% l??ng t??ng ?ng)
create or replace trigger bonus_manager
after insert or update on employee
    for each row
    begin
        insert into bonus(superior_emp_id, emp_id, bonus)
        values(:new.superior_emp_id, :new.emp_id, :new.salary/10)  ;
end;
