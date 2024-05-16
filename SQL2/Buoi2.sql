set serveroutput on;
------------------------ CÁC L?NH C? B?N PL/SQL-----------------------
--Bài 1: 
--S? d?ng vòng l?p IF-ELSE ?? th?c hi?n yêu c?u sau: Ki?m tra s? d? tài kho?n c?a khách hàng có  ID = 1. 
--N?u s? d? tài kho?n > 1000$ thì in ra thông báo “S? d? hi?n t?i c?a b?n hi?n ?ang l?n h?n 1000$”, 
--ng??c l?i in ra thông báo “S? d? hi?n t?i c?a b?n không ??t 1000$” (b?ng ACCOUNT). 
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line()
Declare
	v_avail number;
Begin
	select sum(AVAIL_BALANCE) into v_avail 
    from account 
    where CUST_ID = 1;
	If v_avail > 1000 THEN
    	DBMS_OUTPUT.PUT_LINE('S? d? hi?n t?i c?a b?n hi?n ?ang l?n h?n 1000$');
	Else
    	DBMS_OUTPUT.PUT_LINE('S? d? hi?n t?i c?a b?n không ??t 1000$');
	END IF;
End;
--Bài 2: 
--S? d?ng FOR..LOOP ?? l?y ra các thông tin: ID: Mã_phòng ban - Tên_phòng ban ”. (B?ng Department)
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
Declare
Begin
    for i in (  select dept_id, name
                from department)
    loop
       DBMS_OUTPUT.PUT_LINE('Mã phòng ban:' || i.dept_id || ' Tên Phòng ban: '||i.name ); 
    end loop;
End;
--Bài 3:  
--S? d?ng FOR..LOOP ?? l?y ra các thông tin: Amount c?a 10 ngày g?n nh?t c?a t?t c? các giao d?ch tính t? ngày 25-01-2004 (25-01-2004, 26-01-2004, 27-01-2004…..) 
--. (B?ng Acc_transaction )
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
--
DECLARE 
    start_date date := to_date('25-01-2004','DD-MM-YYYY'); 
    v_amount NUMBER; 
    vDate date;
BEGIN 
    FOR i IN 0..9 
    LOOP 
  	begin         	
        vDate := start_date + i;
        SELECT amount 
        INTO v_amount 
        FROM acc_transaction 
        WHERE txn_date = vDate; 
            dbms_output.put_line('Date: ' || TO_CHAR(vDate,'DD-MM-YYYY') || ': ' || v_amount);
    exception
        when no_data_found then
            dbms_Output.Put_Line('Khong co du lieu ngay: ' || TO_CHAR(vDate,'DD-MM-YYYY'));
    end;
    end loop; 
end; 
--Bài 4: 3
--S? d?ng WHILE..FOR ?? l?y ra các thông tin: Amount  c?a t?t c? các giao d?ch tính t? ngày 24-01-2004 cho ??n ngày 28-02-2014 .(B?ng Acc_transaction )
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
--
declare
    type e_tbl is table of acc_transaction%rowtype
    index by binary_integer;
    v_amount e_tbl;
    s_date date := to_date('24-01-2004','DD-MM-YYYY');
    e_date date := to_date('28-02-2014','DD-MM-YYYY');
    i number;
begin
    select * bulk collect into v_amount
    from acc_transaction
    where txn_date between s_date and e_date;
    i:= v_amount.first;
    while i <= v_amount.count loop
        dbms_output.put_line('Date: ' || TO_CHAR(v_amount(i).txn_date,'DD-MM-YYYY') || ' Amount: ' || v_amount(i).amount);
        i := i + 1;
    end loop;
end;
--
---------------------- CURSOR--------------------------
--
--Bài 1: 
--S? d?ng cursor ?? l?y các thông tin: Mã s?n ph?m (product_cd), Tên gói s?n ph?m (name)  mà ngân hàng ?ang cung c?p(b?ng Product). 
--Và hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
--
DECLARE
    CURSOR c_product is
    SELECT product_cd, name
    FROM PRODUCT;
BEGIN
    FOR i IN c_product
    LOOP
    dbms_output.put_line( i.product_cd || ': ' ||  i.name );
    END LOOP;
END;
--Bài 2:
--S? d?ng cursor t??ng minh ?? l?y ra thông tin g?m Mã Khách hàng và tên s?n ph?m mà KH ?ó s? ??ng, l?y t? b?ng Account và Product (account join Product on account .Product_CD = Product.Product_CD)
--Và hi?n th? k?t qu? ra màn hình  “Cust_ID,Product Name” b?ng l?nh: dbms_output.put_line()
--
DECLARE
    cursor c_pro is
    SELECT cust_id, name
    FROM account a
    join product p on p.product_cd = a.product_cd;
    v_cursor c_pro%Rowtype;
BEGIN
    open c_pro;
    loop
    fetch c_pro into v_cursor;
    Exit When c_pro%Notfound;
    Dbms_Output.Put_Line('ID: ' || v_cursor.cust_id || '- Name: ' || v_cursor.name);
    end loop;
    close c_pro;
END;
--Bài 3:  
--S? d?ng cursor con tr? t??ng minh ?? l?y ra thông tin bao g?m: “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT” c?a t?t c? các khách hàng.
--N?u:
-- “AVAIL_BALANCE <= 4000” thì SEGMENT là: “LOW”, 
--“AVAIL_BALANCE > 4000 và AVAIL_BALANCE <= 7000” thì SEGMENT là: “MEDIUM”, 
--
--“AVAIL_BALANCE >7000” thì SEGMENT là: “HIGH”
--Sau ?ó hi?n th? k?t qu?:  “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT”  ra màn hình b?ng l?nh dbms_output.put_line().
--G?i ý: S? d?ng d? li?u t? các b?ng sau: Customer, Account, Individual), g?i ý:
-- account join customer on customer.cust_id = account.cust_id
--join individual on individual.cust_id = customer.cust_id
DECLARE
    cursor c_pro is
    SELECT sum(avail_balance) Tong,
    FIRST_NAME || LAST_NAME NAME
    FROM account
    join customer on customer.cust_id = account.cust_id
    join individual on individual.cust_id = customer.cust_id
    GROUP BY FIRST_NAME || LAST_NAME;
    v_cursor c_pro%Rowtype;
    segment varchar2(20);
BEGIN
    open c_pro;
    loop
    fetch c_pro into v_cursor;
    IF v_cursor.tong <= 4000 THEN
        segment := 'Low';
    ELSIF v_cursor.tong > 4000 and v_cursor.tong <= 7000 THEN
        segment := 'Medium';
    ELSE
        segment := 'High';
    END IF;
    Exit When c_pro%Notfound;
        Dbms_Output.Put_Line('KH: ' || v_cursor.name || ' - ' || segment);
    end loop;
    close c_pro;
END;
--Bài 4: ?? bài nh? bài 2. Nh?ng s? d?ng lo?i con tr? không t??ng minh
-- Bai 2 
DECLARE
    cursor c_pro is
    SELECT cust_id, name
    FROM account a
    join product p on p.product_cd = a.product_cd;
BEGIN
    for i in c_pro loop
    Dbms_Output.Put_Line('ID: ' || i.cust_id || ' - Name: ' || i.name);
    end loop;
END;
-- Bai 3
DECLARE
    cursor c_pro is
    SELECT sum(avail_balance) Tong,
    FIRST_NAME || LAST_NAME NAME
    FROM account
    join customer on customer.cust_id = account.cust_id
    join individual on individual.cust_id = customer.cust_id
    GROUP BY FIRST_NAME || LAST_NAME;
    segment varchar2(20);
BEGIN
    for i in c_pro loop
    IF i.tong <= 4000 THEN
        segment := 'Low';
    ELSIF i.tong > 4000 and i.tong <= 7000 THEN
        segment := 'Medium';
    ELSE
        segment := 'High';
    END IF;
    Exit When c_pro%Notfound;
        Dbms_Output.Put_Line('KH: ' ||i.name || ' - ' || segment);
    end loop;
END;
--Bài 5: T?o b?ng ETL_CUSTOMER theo code m?u sau:
CREATE TABLE HuyHung_ETL_CUSTOMER(
	cust_id NUMBER,
	segment VARCHAR2(50) NOT NULL,
	etl_date date NOT NULL
);
--+ Làm t??ng t? bài 3 ?? tính ???c SEGMENT c?a t?ng khách hàng. 
--Sau ?ó Insert d? li?u vào b?ng ETL_CUSTOMER v?i các tr??ng nh? sau:
---  	cust_id = ID_KHÁCH_HÀNG,
---  	segment = SEGMENT,
---  	elt_date = Ngày hi?n t?i (Ngày thêm d? li?u)
-- 
declare 
    cursor c_pro is
 	SELECT customer.cust_id, sum(AVAIL_BALANCE) Tong,
 	FIRST_NAME || LAST_NAME NAME
 	FROM account
 	join customer on customer.cust_id = account.cust_id
 	join individual on individual.cust_id = customer.cust_id
 	GROUP BY customer.cust_id, FIRST_NAME || LAST_NAME;
    segment varchar2(20);
    count_id number;
 BEGIN
    for i in c_pro loop
   	IF i.Tong <= 4000 THEN
      	segment := 'Low';
   	ELSIF i.Tong > 4000 and i.Tong <= 7000 THEN
      	segment := 'Medium';
   	ELSE
      	segment := 'High';
   	END IF;
    insert into HuyHung_ETL_CUSTOMER values(i.cust_id,segment,sysdate);  
    commit;
   	Dbms_Output.Put_Line('Name: ' || i.name || ' / Segment: ' || segment);
    end loop;
    select count(*) into count_id from huyhung_etl_customer;
    Dbms_Output.Put_Line('So ban ghi duoc them vao la: ' || count_id);
    -- Tinh tong thoi gian chay?
End;
--+ In ra  ra màn hình b?ng l?nh dbms_output.put_line() các thông tin sau: T?ng s? b?ng ghi ?ã ???c thêm vào + T?ng th?i gian ch?y
-- (G?i ý: S? d?ng d? li?u t? các b?ng sau: Customer, Account, Individual)
--
--BÀI T?P V? NHÀ:
--Bài 1:
--S? d?ng vòng l?p ?? l?y ra các thông tin: ID: Mã nhân viên, H? và Tên nhân viên, Mã phòng ban, Tên Phòng bàn c?a các nhân viên 
--có mã chi nhánh = 1. (Join 2 b?ng Employee và Department)
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
declare
begin
    for i in ( 
    select e.emp_id, e.First_name , e.Last_name, d.dept_id, d.name
    from employee e
    join department d
    on e.dept_id = d.dept_id
    where assigned_branch_id = 1)
    loop
    Dbms_Output.Put_Line('ID: ' || i.emp_id || ' Name: ' || i.First_name || i.Last_name || ' / Department ID: ' 
    || i.dept_id || ' Department Name: ' ||i.name);
    end loop;
end;

--Bài 2: 
--S? d?ng vòng l?p ?? l?y ra thông tin: T?ng s? tài kho?n ?ã ???c m? b?i nhân viên có ID = 10
--N?u:
-- “T?ng s? tài kho?n ?ã m? <= 1” thì Level là: “LOW”, 
--“T?ng s? tài kho?n ?ã m? > 2 và T?ng s? tài kho?n ?ã m? <= 4” thì Level  là: “Avg”, 
--“T?ng s? tài kho?n ?ã m? > 4 và T?ng s? tài kho?n ?ã m? <= 6” thì Level  là: “Moderate”, 
--Tr??ng h?p còn l?i Level là: “Hight”
--Sau ?ó hi?n th? k?t qu? Level ra màn hình b?ng l?nh dbms_output.put_line().
declare
    level varchar(20);
    tong number;
begin
    select count(account_id) into tong 
    from account
    where open_emp_id = 10;
    if tong <= 1 then
    level := 'LOW';
    elsif tong > 2 and  tong <= 4 then
    level := 'Avg';
    elsif tong > 4 and tong <= 6 then
    level := 'Moderate';
    else 
    level := 'Hight';
    end if;
    Dbms_Output.Put_Line('Tong so tai khoan: ' || TO_CHAR(tong)  ||' - Level: ' || Level);    
end;
--Bài 3: 
--S? d?ng vòng l?p ?? l?y ra t?ng s? tài kho?n ?ã m? tính t? n?m 2000 ??n n?m 20005
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
declare
    tong number;
begin
    select count(account_id) into tong 
    from account
    where extract(year from open_date) between 2000 and 2005;
    Dbms_Output.Put_Line('Tong so tai khoan: ' || TO_CHAR(tong));    
end;
--Em làm 2theo 2 h??ng c?a ??
declare
    star_year number := 2000;
    tong number;
begin
    for i in 2000..2005 loop
    select count(account_id) into tong 
    from account 
    where extract(year from open_date) = star_year;
    Dbms_Output.Put_Line('Nam: '|| star_year || ' Tong so tai khoan: ' || tong); 
    star_year := star_year + 1;
    end loop;
end;
--Bài 4: S? d?ng con tr? ?? l?y ra báo cáo bao g?m: 
--Mã nhân viên, h? và tên nhân viên và ngày ??u tiên mà nhân viên ?ó ?ã m? tài kho?n cho khách hàng 
--(G?i ý: s? d?ng 2 b?ng Employee và b?ng Account)
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
declare
    cursor c_emp is
    select emp_id, first_name || ' ' || last_name as name, min(open_date) as ngay
    from employee e 
    left join account a
    on e.emp_id = a.open_emp_id
    group by emp_id, first_name || ' ' || last_name
    order by emp_id;
begin
    for i in c_emp 
    loop
        if i.ngay is null then
        Dbms_Output.Put_Line('ID: '|| i.emp_id || ' Name: ' || i.name ||' / Nhan vien chua mo tai khoan cho khach hang.');
        else
        Dbms_Output.Put_Line('ID: '|| i.emp_id || ' Name: ' || i.name || ' / Ngay mo tai khoan: ' || i.ngay); 
        end if; 
    end loop;
end;


--Bài 5:
--S? d?ng con tr? ?? l?y ra báo cáo bao g?m: Mã nhân viên, h? và tên nhân viên, ngày b?t ??u vào làm và 
--s? ti?n th??ng ??t ???c theo kinh nghi?m làm vi?c
--S? ti?n th??ng ???c tính theo CT sau: 
--+ Th?i gian làm vi?c = S? tháng c?a Ngày hi?n t?i so v?i ngày b?t ??u vào làm / 12
--+ N?u th?i gian làm vi?c > 13: Ti?n th??ng = 8000
--+ N?u th?i gian làm vi?c > 11: Ti?n th??ng = 5000
--+ N?u th?i gian làm vi?c > 9: Ti?n th??ng = 3000
--+ N?u th?i gian làm vi?c > 7: Ti?n th??ng = 2000
--+ N?u th?i gian làm vi?c > 4: Ti?n th??ng = 1000
--Hi?n th? ra màn hình b?ng l?nh: dbms_output.put_line().
declare
    cursor c_sal 
    is 
    select emp_id, first_name || ' ' ||last_name name, start_date
    from employee;
    tienthuong float;
    thoigian float;
begin
    for i in c_sal
    loop
    thoigian := months_between(sysdate, i.start_date) / 12;
    if thoigian > 13 then
    tienthuong := 8000;
    elsif thoigian > 11 and thoigian <= 13 then
    tienthuong := 5000;
    elsif thoigian > 9 and thoigian <= 11 then
    tienthuong := 3000;
    elsif thoigian > 7 and thoigian <= 9 then
    tienthuong := 2000;
    elsif thoigian > 4 and thoigian <= 7 then
    tienthuong := 1000;
    else
    tienthuong := 200;
    end if;
    Dbms_Output.Put_Line('ID: '|| rpad(i.emp_id,4) 
                        || rpad(' Name: ',8) || rpad(i.name,16) 
                        || ' Ngay vao lam: ' || i.start_date 
                        || rpad(' - Tien thuong: ',15) || to_char(tienthuong, '9,999.999')); 
    end loop;
end;

