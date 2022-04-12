-- 查看数据库中有哪些序列
-- r=普通表， i=索引，S=序列，v=视图，m=物化视图， c=复合类型，t= TOAST表，f=外部表
select * from pg_class where relkind='S';

-- 创建序列
CREATE SEQUENCE acnumber
 INCREMENT BY 1 -- 每次递增1
 START WITH 1 -- 从1开始
 MINVALUE 1 -- 最小值=1
 MAXVALUE 999999999 --最大值
 CYCLE -- 达到最大值后循环到最小值 
 ; 
-- 序列重置到1
alter sequence sequence_name restart with 1
-- 获取下个序列号
SELECT nextval('sequence_name');
-- 获取最近一次使用nextval获取的序列号
SELECT currval('sequence_name');

-- 查询所有表名
SELECT tablename FROM pg_tables   
WHERE tableowner='IPTP_AC'
AND tablename NOT LIKE 'pg%'   
AND tablename NOT LIKE 'sql_%' 
ORDER BY tablename;

-- 查询表结构信息
SELECT a.attnum,
	a.attname AS field,
	t.typname AS type,
	a.attlen AS length,
	a.atttypmod AS lengthvar,
	a.attnotnull AS notnull,
	b.description AS comment
FROM pg_class c,
	pg_attribute a
	LEFT OUTER JOIN pg_description b ON a.attrelid=b.objoid AND a.attnum = b.objsubid,
	pg_type t
WHERE c.relname = 'ac_transaction_t'
and a.attnum > 0
and a.attrelid = c.oid
and a.atttypid = t.oid
ORDER BY a.attnum;


-- 查询PG设置项，超时时间等
-- idle_in_transaction_session_timeout：会话超时时间，默认5分钟
-- lock_timeout：悲观锁等待超时时间，时间到则会报错，默认10秒
select * from pg_settings ps
where 1=1
and ps.name like '%idle_in_transaction_session_timeout%'


-- PG悲观锁
BEGIN;
SELECT * FROM ac_line_t WHERE ac_line_id in(560925331773046788, 560925331773046789,333) for UPDATE NOWAIT;
COMMIT;

-- 查询锁表信息
select
	c.datname,c.usename,c.client_addr,c.client_port,
	c.state, c.query, c.query_start,
	a.locktype,a.database,a.pid,a.mode,
	b.relname
from pg_locks a
join pg_class b on a.relation = b.oid
join pg_stat_activity c on a.pid=c.pid
where c.client_addr is not null
and b.relname in ('ac_line_t', 'ac_transaction_t');

SELECT DISTINCT a.attnum,
	a.attname AS field,
	t.typname AS type,
	a.attlen AS length,
	a.atttypmod AS lengthvar,
	a.attnotnull AS notnull,
	b.description AS comment,
	split_part(b.description, '||', 1) as comment2,
	case when t.typname='varchar' then a.attname||'    '||t.typname||'('||a.atttypmod-4||')'
	else a.attname||'    '||t.typname
	end as allType
FROM pg_class c,
	pg_attribute a
	LEFT OUTER JOIN pg_description b ON a.attrelid=b.objoid AND a.attnum = b.objsubid,
	pg_type t
WHERE c.relname = 'ac_line_t'
and a.attnum > 0
and a.attrelid = c.oid
and a.atttypid = t.oid
and a.attname != 'tenant_id'
ORDER BY a.attnum;



-- 杀死连接进程
-- 查询进程ID
select 
	a.query_start,
	a.backend_start,
	a.state,
	a.query,
	a.* 
from pg_stat_activity a 
where application_name<>'Navicat' and usename='IPTP_AC' 
and client_addr='10.105.185.97'
ORDER BY a.pid desc;
-- 杀死进程ID
SELECT pg_terminate_backend(pid)
