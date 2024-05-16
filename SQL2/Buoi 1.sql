--Y�u c?u:
--B�i 1:  
--S? d?ng ki?u khai b�o 1 c?t %type ?? l?y ra t�n c?a nh�n vi�n c� id = 2. (B?ng Employee )
set serveroutput on;
declare
    v_FristName Employee.First_Name%type;
    v_empid Employee.Emp_id%type := 2;
begin
    select First_Name into v_FristName
    from Employee
    where emp_id = v_empid;
    dbms_output.put_line('First Name:' || v_FristName);
end;
--B�i 2:  
--S? d?ng ki?u khai b�o 1 d�ng %Rowtype ?? l?y ra t?t c? th�ng tin c?a nh�n vi�n c� id = 2. (B?ng Employee )
declare
    v_Emp Employee%Rowtype;
    v_empid Employee.Emp_id%type := 2;
begin
    select * into v_Emp
    from Employee
    where emp_id = v_empid;
    dbms_output.put_line('First Name: ' || V_emp.First_Name);
    dbms_output.put_line('Last Name: ' || V_emp.Last_Name);
    dbms_output.put_line('Title: ' || V_emp.Title);
end;

--B�i 3:  
--S? d?ng ki?u khai b�o 1 d�ng %Rowtype ?? l?y ra t?t c? th�ng tin c?a nh�n vi�n c� id = 10000. (B?ng Employee ). 
--S? d?ng Exception n?u kh�ng c� d? li?u tr? v? (When No_Data_Found Then) th� in ra c�u l?nh : �No data with emp_id= id c?a nh�n vi�n
declare
    v_Emp Employee%Rowtype;
    v_empid Employee.Emp_id%type := 10000;
begin
    select * into v_Emp
    from Employee
    where emp_id = v_empid;
    dbms_output.put_line('First Name: ' || V_emp.First_Name);
    dbms_output.put_line('Last Name: ' || V_emp.Last_Name);
    dbms_output.put_line('Title: ' || V_emp.Title);
    
    exception 
    when no_data_found then
    dbms_output.put_line('No data with emp_id = ' || V_empid);
end;
--B�i 4: 
--Khai b�o 1 bi?n v_Cust_id = 1. L?y ra t?t c? th�ng tin kh�ch h�ng c� ID = bi?n v?a khai b�o 
declare
    v_cust customer%rowtype;
    v_Cust_id customer.cust_id%type := 1;
begin
    select * into v_cust
    from customer
    where cust_id = v_cust_id;
    dbms_output.put_line('Customer ID:' || v_cust.cust_id);
    dbms_output.put_line('Customer Address:' || v_cust.address);
    dbms_output.put_line('Customer City:' || v_cust.city);    
end;
--B�i 5:  
--S? d?ng ki?u khai b�o Table ?? l?y ra t?t c? th�ng tin:  �ID - FIRSTNAME - LASTNAME� (B?ng Employee )
--Hi?n th? ra m�n h�nh b?ng l?nh: dbms_output.put_line().
declare
    type E_tbl is table of employee%rowtype;
    v_emp E_tbl;
begin
    select * bulk collect into v_emp
    from employee;
    for i in 1..v_emp.count loop
    dbms_output.put_line(v_emp(i).emp_id || ' ' || v_emp(i).First_name || ' '|| v_emp(i).last_name);    
    end loop;
end;

--
--
--B�I T?P V? NH�: 
--B�i 1: Khai b�o 2 bi?n a,b (integer) c� gi� tr? l?n l??t l� 10 v� 20. 
--Y�u c?u:
declare 
    a integer := 10;
    b integer := 20;
    c integer;
    d integer;
    e float;
begin
--1.       In ra t?ng c?a 2 gi� tr?
    c := a + b;
    dbms_output.put_line('Tong 2 gia tri: ' || c);
--2.       In ra hi?u c?a 2 gi� tr?
    d := a - b;
    dbms_output.put_line('Hieu 2 gia tri: ' || d);
--3.       In ra th??ng c?a 2 gi� tr?
    e := b/a;
    dbms_output.put_line('Thuong 2 gia tri: ' || e);
end;

--B�i 2: Vi?t code PL/SQL t�nh di?n t�ch h�nh tr�n khi bi?t b�n k�nh r = 9.4
declare 
    r float ;
    pi constant float := 3.14;
    S float;
begin
    r  := 9.4;
    S := pi * r * r;
    dbms_output.put_line('Dien tich hinh tron co gia tri: ' || S);

end;
--B�i 3: S? d?ng ki?u khai b�o %Type ?? l?y ra th�ng tin kh�ch h�ng bao g?m: 
--M� kh�ch h�ng, H? v� t�n, ??a ch?, Ng�y th�ng n?m sinh c?a kh�ch h�ng c� ID = 4 (Join 2 b?ng INDIVIDUAL v� CUSTOMER)
declare
    v_cust_id customer.cust_id%type := 4;
    v_address customer.address%type;
    v_firstname individual.first_name%type;
    v_lastname individual.last_name%type;
    v_birthdate individual.birth_date%type;
begin
    select c.cust_id, c.address, i.first_name, i.last_name, i.birth_date 
    into v_cust_id, v_address, v_firstname, v_lastname, v_birthdate
    from customer c 
    join individual i
    on c.cust_id = i.cust_id
    where v_cust_id = c.cust_id;
    dbms_output.put_line(v_cust_id || '-' || v_address || ' ' || v_firstname || '-' || v_lastname || '-' || v_birthdate);    
end;

--B�i 4: S? d?ng ki?u khai b�o %Type ?? l?y ra t�n kh�ch h�ng c� nhi?u t�i kho?n nh?t (Join 2 b?ng INDIVIDUAL v� ACCOUNT).
declare
    v_cust_id account.cust_id%type;
    v_firstname individual.first_name%type;
    v_lastname individual.last_name%type;
    v_account number;
begin
    select i.First_Name, i.Last_name, count(a.account_id)
    into v_firstname, v_lastname, v_account
    from individual i 
    join account a
    on a.cust_id = i.cust_id
    group by i.First_Name, i.Last_name
    order by count(a.account_id) desc
    fetch first 1 rows only;
    dbms_output.put_line( v_firstname || ' ' || v_lastname || ': ' || v_account);    
end;    

--B�i 5: S? d?ng ki?u khai b�o bi?n th�ch h?p l?y ra s? d? kh? d?ng (AVAIL_BALANCE) 
--nh? nh?t, l?n nh?t, trung b�nh c?a t�i kho?n (b?ng ACCOUNT) 
declare
    v_avail_balance   account.avail_balance%type;
    v_min float;
    v_max float;
    v_avg float;
begin
    select min(avail_balance), max(avail_balance), round(avg(avail_balance),2)
    into v_min ,v_max, v_avg 
    from account ;
    dbms_output.put_line( v_min || ' ' || v_max || ' ' || v_avg);    
end;   
--B�i 6: S? d?ng ki?u khai b�o Table l?y ra 2 t?p  nh�n vi�n:
--+ T?p nh�n vi�n  1: Nh?ng nh�n vi�n c�  ID >4
--+ T?p nh�n vi�n 2: Nh?ng nh�n vi�n c� ID <2
--Union 2 t?p nh�n vi�n l?i v?i nhau
--Y�u c?u:
--1.       In ra m�n h�nh t?ng s? nh�n vi�n
--2.       In ra ch? s? c?a nh�n vi�n ??u ti�n
--3.       In ra ch? s? nh�n vi�n cu?i c�ng
--4.       In ra l?n l??t ID + T�n nh�n vi�n
declare
    type E_tbl is table of employee%rowtype
    index by binary_integer ;
    v_emp E_tbl;    
begin
    SELECT * bulk collect
    into v_emp
    FROM employee e
    WHERE NOT EXISTS (
    SELECT *
    FROM employee
    WHERE emp_id BETWEEN 2 AND 4
    AND e.emp_id = employee.emp_id
    );
            
    dbms_output.put_line('Tong so nhan vien: ' || v_emp.count);    
    dbms_output.put_line('Chi so cua nhan vien dau dien: ' || v_emp.first || ' ID: ' || v_emp(v_emp.first).emp_id);    
    dbms_output.put_line('Chi so cua nhan vien cuoi cung: ' || v_emp.last || ' ID: ' || v_emp(v_emp.last).emp_id);  
    for i in v_emp.first..v_emp.last loop
    dbms_output.put_line(v_emp(i).emp_id || ' ' || v_emp(i).First_name || ' '|| v_emp(i).last_name);    
    end loop;
end; 












