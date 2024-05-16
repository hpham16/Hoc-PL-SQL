------------------ SEQUENCE-----------------------------
--Y�u c?u: 
--B?n h�y m? l?i slide b�i h?c v? Sequence v� th?c th�nh theo c�c v� d? ?� ???c ?? c?p trong ?�.
--
--B�i 1: 
--+ T?o ra m?t Sequence l� my_seq, b?t ??u t? 1, t?ng 1, gi� tr? t?i thi?u 1, gi� tr? t?i ?a 10, s? d?ng t�y ch?n Cycle
--+ L?y ra 10 gi� tr? ti?p theo c?a Sequence
--+ L?y ra gi� tr? hi?n t?i c?a Sequence
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
--B�i 2: 
--+ T?o 1 b?ng theo m?u sau:
--CREATE TABLE My_Table(
--    id NUMBER PRIMARY KEY,
--    title VARCHAR2(255) NOT NULL
--);
--+  INSERT 2 b?n ghi m?i v�o b?ng My_Table v?i ID: t? t?ng b?ng c�ch s? d?ng Sequence b�i 1, Tittle: T�y ch?n
--+ Th?c hi?n truy v?n Select ?? ki?m tra
--
INSERT INTO My_Table(id, title)
VALUES (my_seq.NEXTVAL, 'Title 1');
select * from My_table;
INSERT INTO My_Table(id, title)
VALUES (my_seq.NEXTVAL, 'Title 2');

--B�i 3: 
--+ Drop b?ng My_Table v?a t?o
drop table  my_table;
--+ T?o l?i b?ng theo code m?u sau:
--CREATE TABLE tasks(
--    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--    title VARCHAR2(255) NOT NULL
--);
--+ INSERT 2 b?n ghi m?i v�o b?ng My_Table v?i Tittle: T�y ch?n (L?u �: Kh�ng c?n khai b�o id)
--+ Th?c hi?n truy v?n ?? ki?m tra

INSERT INTO tasks(title)
VALUES ('Title ne');
select * from tasks;


-------- TRANSACTION ---------


--B�i 1: 
--+ Th�m 1 b?n ghi m?i v�o b?ng �HOCVIEN_CUSTOMER� sau ?� s? d?ng COMMIT
insert into hocvien_customer values(312, 'Quan 9', 'HCM', 'B', 123123123, 10000, 'MA');
commit;
--+ Th�m 1 b?n ghi m?i v�o b?ng �HOCVIEN_CUSTOMER� sau ?� s? d?ng ROLLBACK
insert into hocvien_customer values(545, 'Quan 10', 'HCM', 'C', 45454545, 10000, 'MA');
rollback;
--Select d? li?u v� ??a ra nh?n x�t
select * from hocvien_customer;
--Nh?n x�t: Sau khi s? d?ng l?nh commit th� d? li?u ???c l?u v�o server v� sau khi select th� s? th?y d? li?u. C�n sau khi s? d?ng rollback
-- th� s? kh�ng th?y d? li?u.
--B�i 2: 
--+ Th�m 1 b?n ghi m?i v�o b?ng �HOCVIEN_CUSTOMER� sau ?� s? d?ng SAVEPOINT + T�n_saveponint
insert into hocvien_customer values(545, 'Quan 10', 'HCM', 'C', 8487544, 10000, 'CA');
savepoint hv_sp;

--+ X�a b?n ghi tr??c ?� (b?n ghi c� ID sau b?n ghi v?a th�m)
DELETE FROM hocvien_customer WHERE cust_id = 545;
--+ S? d?ng l?nh ROLLBACK TO T�n_saveponint
rollback to hv_sp;
--+ Ti?p t?c s? d?ng COMMIT
commit;
--Select d? li?u v� ??a ra nh?n x�t
select * from hocvien_customer;
--sau khi th?c hi?n rollback l?i savepoint th� d? li?u kh�ng ???c x�a n?a m� ?� Tr? v? l�c t?o savepoint
--
--B�i 3:
--+  Th�m 1 b?n ghi m?i v�o b?ng �HOCVIEN_CUSTOMER�
insert into hocvien_customer values(475, 'Quan Binh Thanh', 'HCM', 'A', 1245, 10000, 'CA');
--+ Th�m 1 b?n ghi m?i v�o b?ng �HOCVIEN_CUSTOMER� (C? t�nh ghi sai c?u tr�c)
insert into hocvien_customer values(AAA, 'Quan asd Thanh', 'HCM', 1245,'A', 10000, 'CA');
--+ S? d?ng COMMIT
commit;
--Select d? li?u v� ??a ra nh?n x�t
--D? li?u s? kh�ng ???c l?u















