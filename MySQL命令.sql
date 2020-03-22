--【mysql7创建用户并授权(步骤分开)】
grant all privileges on yidao_court_prelitigation.* to 'sync'@'%' identified by 'sync@123';
FLUSH PRIVILEGES;

-- 【mysql8创建用户并授权(步骤分开)】
-- 创建用户并设置密码(使用caching_sha2_password编码)
create user 'sync'@'%' identified by 'sync@123';
-- 授权
grant all privileges on yidao_court_prelitigation.* to 'sync'@'%';
flush privileges;
-- 更改密码和编码方式
alter user 'sync'@'%' identified with mysql_native_password by 'sync@123';
flush privileges;
-- 查看授权信息
show grants for 'sync'@'%';
-- 撤销授权
revoke all privileges on yidao_court_prelitigation.* from 'sync'@'%';
-- 删除用户
drop user 'sync'@'%';


--查询所有表
select CONCAT("drop ","table ",table_name,";") from information_schema.tables where table_schema='yidao_court_prelitigation'