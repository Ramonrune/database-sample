/* ===========================================
LBDm - Aula de 08 de novembro de 2017
-------------------------------------------------
03. Salve o texto (.sql) do link 13 da WebPage de hoje como LBDm171108b_RA.sql e abra-o
============================================= */
/* TRIGGERs (gatilhos)
------------------------------------------------
Triggers, assim como Stored Procedures, cont�m sequ�ncias de instru��es armazenadas diretamente no Banco de Dados. A diferen�a, � que Stored Procedures precisam ser chamadas, sempre que necess�rio, e Triggers s�o programados para serem automaticamente invocados assim que houver alguma altera��o na tabela, para a qual o trigger foi programado.
------------------------------------------------
Sintaxe b�sica de Trigger:
------------------------------------------------
CREATE or ALTER TRIGGER <nome>
FOR <Rela��o>      			-- Quando ocorrer algo com esta Rela��o
Active/Inactive         			-- o trigger est� ativo ou inativo
After/Before Insert [or Update] [or Delete]   	-- ap�s/antes de IUD (InclUptDel) na <Rela��o>
Position #				-- 0� trigger, caso haja mais (para esta Rela��o)
AS					-- podem-se declarar vari�veis ap�s o "AS"...
Begin
  <instru��es...>
  insert into <Rela��o> (<atributo_1>, ..., <atributo_n>)
  values (new.<atributo_1>,		  -- mesmo conte�do do <atributo_1>
  ..., 
  new.<atributo_n>);		    -- mesmo conte�do do <atributo_n>

  update <Rela��o> (<atributo_1>, ..., <atributo_n>)
  set <atributo_1> = old.<atributo_1>, ...,
  set <atributo_n> = old.<atributo_n> ;
end
------------------------------------------------
////////////////////////////////////////////////////
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
////////////////////////////////////////////////////
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
////////////////////////////////////////////////////
------------------------------------------------ */
-- Fun��es �teis para trilha de auditoria e Vari�veis de contexto:
------------------------------------------------
select date 'now' from rdb$database;
select date 'today' from rdb$database;
select date 'tomorrow' from rdb$database;
select date 'yesterday' from rdb$database;
------------------------------------------------
select time 'now' from rdb$database;
select timestamp 'now' from rdb$database;
------------------------------------------------
select current_connection from rdb$database;
select current_role from rdb$database;
select current_user from rdb$database;
select current_transaction from rdb$database;
select current_date from rdb$database;
select current_time from rdb$database;
select current_timestamp from rdb$database;
------------------------------------------------
select rdb$get_context('SYSTEM', 'DB_NAME') from rdb$database;
select rdb$get_context('SYSTEM', 'NETWORK_PROTOCOL') from rdb$database;
select rdb$get_context('SYSTEM', 'CURRENT_USER') from rdb$database;
select rdb$get_context('SYSTEM', 'CLIENT_ADDRESS') from rdb$database;
select rdb$get_context('SYSTEM', 'SESSION_ID') from rdb$database;

Create table Auditoria_Autor (
    matricula   smallint,
    usuario      varchar (30), 
    transacao   integer, 
    data          date, 
    hora          time);
commit;


SET TERM^;
CREATE OR ALTER TRIGGER Ocorrencias_Autor
FOR AUTOR
ACTIVE
BEFORE INSERT
AS
BEGIN  
    INSERT INTO Auditoria_Autor (matricula, usuario, transacao, data, hora)
    VALUES(new.matricula, current_user, current_transaction, current_date, current_time);
END^
SET TERM;^
COMMIT;

select * from Autor;
select * from Auditoria_Autor;   -- Ainda vazio!

Insert into Autor 
    values (
	(select MAX (matricula) + 1 from Autor),
	'Margarida Noriana Kremoza','10987654321','Rua Nova, 1000',
	'01/06/1996','BR');
commit;


select * from Autor;
select * from Auditoria_Autor;


SET TERM^;
CREATE OR ALTER TRIGGER Ocorrencias_Autor
FOR AUTOR
ACTIVE
BEFORE INSERT OR DELETE
AS BEGIN
INSERT INTO Auditoria_Autor (matricula, usuario, transacao, data, hora)
VALUES(new.matricula, current_user, current_transaction, current_date, current_time);
END^
SET TERM;^
COMMIT;


SELECT * FROM Autor;
select * from Auditoria_Autor;

Delete from Autor where matricula = 534;
commit;

SELECT * FROM Autor;
select * from Auditoria_Autor;


SET TERM^;
CREATE OR ALTER TRIGGER Ocorrencias_Autor
FOR AUTOR
ACTIVE
BEFORE INSERT OR UPDATE OR DELETE
AS 
BEGIN
    INSERT INTO Auditoria_Autor (matricula, usuario, transacao, data, hora)
    VALUES(COALESCE(new.matricula, old.matricula),
            current_user, current_transaction, current_date, current_time);
END^
SET TERM;^
COMMIT;


select * from Autor;
select * from Auditoria_Autor; 

Insert into Autor 
    values (1000,'Margarida Noriana Kremoza','10987654321','Rua Nova, 1000',
        '01/06/1996','BR');
commit;


select * from Autor;
select * from Auditoria_Autor;
update Autor
set nascim = '01/26/1996'
where matricula = 1000;
commit;

select * from Autor;
select * from Auditoria_Autor;


delete from Autor where matricula = 1000;
commit;  

  
select * from Autor;
select * from Auditoria_Autor;

/* --------------------------------    
01. Crie a tabela "Log_livro" com os mesmos atributos e tipos da tabela Livro (sem definir PKs e FKs), al�m dos atributos usuario (varchar (30)), transacao (integer), data (date) e hora (time)
-------------------------------- */
CREATE TABLE Log_Livro
(
  codlivro  Smallint NOT NULL,
  titulo    Varchar(80) NOT NULL,
  preco     Numeric(10,2),
  lancamento    Date,
  sigla     Char NOT NULL,
  codedit   Smallint,
  tiptrans  char,
  usuario   varchar (30),
  transacao integer,
  data   date, 
  hora  time
);
commit;


insert into Livro (codlivro, titulo, preco, sigla, codedit)
values  ((select max (codlivro) + 1 from Livro),
         'Cozinhando com Jamie Oliver',238.47,'A',13)
         
--------------------------------    
-- 02. Crie o Trigger "TG03_Log_Livro" para que, ao inserir, alterar ou excluir uma tupla da tabela Livro, uma nova tupla "log" seja inserida na tabela "Log_Livro", com os valores correspondentes.
--------------------------------    
-- Pesquise sobre a possibilidade de se ter um atributo que relate qual o tipo de transa��o que ocorreu (insert, update ou delete) e experimente realizar isto.
-- Pesquise sobre "inserting", "updating" e "deleting" no Firebird.
--------------------------------         

SET TERM^;
CREATE OR ALTER TRIGGER TG03_Log_Livro
FOR Livro
ACTIVE
BEFORE INSERT OR UPDATE OR DELETE
POSITION 1
AS BEGIN
   Insert into Log_Livro
    (codlivro, titulo, preco, lancamento, sigla, codedit, 
     tiptrans, 
     usuario, transacao, data, hora)
  Values (coalesce(new.codlivro,old.codlivro), 
        coalesce(new.titulo,old.titulo),
        coalesce(new.preco,old.preco),
        coalesce(new.lancamento,old.lancamento),
        coalesce(new.sigla,old.sigla),
        coalesce(new.codedit,old.codedit),
        case when INSERTING then 'I'
             when UPDATING then 'U'
             when DELETING then 'D'
        end,
        current_user, current_transaction,
          current_date, current_time);
END^
set term;^
commit;


--------------------------------    

--------------------------------    
select * from livro;
select * from log_livro;
--------------------------------    
insert into Livro (codlivro, titulo, preco, sigla, codedit)
values  ((select max (codlivro) + 1 from Livro),
         'Cozinhando com Jamie Oliver',238.47,'A',13)

insert into Livro (codlivro, titulo, preco, sigla, codedit)
values  ((select max (codlivro) + 1 from Livro),
         'Fotografia Digital',125.47,'E',13)
--------------------------------    
select * from livro;
select * from log_livro;
--------------------------------    
update  Livro 
set     sigla = 'E' 
where   titulo = 'Cozinhando com Jamie Oliver';
--------------------------------    
select * from livro;
select * from log_livro;
--------------------------------    
delete from Livro 
where   codlivro = (select max (codlivro) from Livro);
--------------------------------    
select * from livro;
select * from log_livro;
--------------------------------    

