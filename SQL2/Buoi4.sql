------------------ SEQUENCE-----------------------------
--Yêu c?u: 
--B?n hãy m? l?i slide bài h?c v? Sequence và th?c thành theo các ví d? ?ã ???c ?? c?p trong ?ó.
--
--Bài 1: 
--+ T?o ra m?t Sequence là my_seq, b?t ??u t? 1, t?ng 1, giá tr? t?i thi?u 1, giá tr? t?i ?a 10, s? d?ng tùy ch?n Cycle
--+ L?y ra 10 giá tr? ti?p theo c?a Sequence
--+ L?y ra giá tr? hi?n t?i c?a Sequence
create sequence my_seq
INCREMENT by 1
start with 1
maxvalue 10
cycle;
--
SELECT my_seq.NEXTVAL
FROM DUAL
CONNECT BY LEVEL <= 10;
--.
SELECT my_seq.CURRVAL
FROM DUAL;
--Bài 2: 
--+ T?o 1 b?ng theo m?u sau:
--CREATE TABLE My_Table(
--    id NUMBER PRIMARY KEY,
--    title VARCHAR2(255) NOT NULL
--);
--+  INSERT 2 b?n ghi m?i vào b?ng My_Table v?i ID: t? t?ng b?ng cách s? d?ng Sequence bài 1, Tittle: Tùy ch?n
--+ Th?c hi?n truy v?n Select ?? ki?m tra
--
INSERT INTO My_Table(id, title)
VALUES (my_seq.NEXTVAL, 'Title 1');
select * from My_table;
INSERT INTO My_Table(id, title)
VALUES (my_seq.NEXTVAL, 'Title 2');

--Bài 3: 
--+ Drop b?ng My_Table v?a t?o
drop table  my_table;
--+ T?o l?i b?ng theo code m?u sau:
--CREATE TABLE tasks(
--    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--    title VARCHAR2(255) NOT NULL
--);
--+ INSERT 2 b?n ghi m?i vào b?ng My_Table v?i Tittle: Tùy ch?n (L?u ý: Không c?n khai báo id)
--+ Th?c hi?n truy v?n ?? ki?m tra

INSERT INTO tasks(title)
VALUES ('Title ne');
select * from tasks;


-------- TRANSACTION ---------


--Bài 1: 
--+ Thêm 1 b?n ghi m?i vào b?ng ‘HOCVIEN_CUSTOMER’ sau ?ó s? d?ng COMMIT
insert into hocvien_customer values(312, 'Quan 9', 'HCM', 'B', 123123123, 10000, 'MA');
commit;
--+ Thêm 1 b?n ghi m?i vào b?ng ‘HOCVIEN_CUSTOMER’ sau ?ó s? d?ng ROLLBACK
insert into hocvien_customer values(545, 'Quan 10', 'HCM', 'C', 45454545, 10000, 'MA');
rollback;
--Select d? li?u và ??a ra nh?n xét
select * from hocvien_customer;
--Nh?n xét: Sau khi s? d?ng l?nh commit thì d? li?u ???c l?u vào server và sau khi select thì s? th?y d? li?u. Còn sau khi s? d?ng rollback
-- thì s? không th?y d? li?u.
--Bài 2: 
--+ Thêm 1 b?n ghi m?i vào b?ng ‘HOCVIEN_CUSTOMER’ sau ?ó s? d?ng SAVEPOINT + Tên_saveponint
insert into hocvien_customer values(545, 'Quan 10', 'HCM', 'C', 8487544, 10000, 'CA');
savepoint hv_sp;

--+ Xóa b?n ghi tr??c ?ó (b?n ghi có ID sau b?n ghi v?a thêm)
DELETE FROM hocvien_customer WHERE cust_id = 545;
--+ S? d?ng l?nh ROLLBACK TO Tên_saveponint
rollback to hv_sp;
--+ Ti?p t?c s? d?ng COMMIT
commit;
--Select d? li?u và ??a ra nh?n xét
select * from hocvien_customer;
--sau khi th?c hi?n rollback l?i savepoint thì d? li?u không ???c xóa n?a mà ?ã Tr? v? lúc t?o savepoint
--
--Bài 3:
--+  Thêm 1 b?n ghi m?i vào b?ng ‘HOCVIEN_CUSTOMER’
insert into hocvien_customer values(475, 'Quan Binh Thanh', 'HCM', 'A', 1245, 10000, 'CA');
--+ Thêm 1 b?n ghi m?i vào b?ng ‘HOCVIEN_CUSTOMER’ (C? tính ghi sai c?u trúc)
insert into hocvien_customer values(AAA, 'Quan asd Thanh', 'HCM', 1245,'A', 10000, 'CA');
--+ S? d?ng COMMIT
commit;
--Select d? li?u và ??a ra nh?n xét
--D? li?u s? không ???c l?u















