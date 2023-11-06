create table #TEMP(sno int identity(1,1),DBName nvarchar(100),fileno int,PageCount bigint,backupdate datetime)

insert into #TEMP

select database_name,file_number,backed_up_page_count,backup_finish_date from msdb.dbo.backupfile a join msdb.dbo.backupset B on

a.backup_set_id=B.backup_set_id

where type='D' and a.physical_drive like '%g%'

order by database_name,file_number,backup_finish_date desc

 

--select *--drop table #TEMP

 

select A.DBName,A.fileno,((SUM(A.PageCount-B.PageCount)*8)/1024.0)/count(1) as [average growth per day]

from #TEMP A join #TEMP B on A.sno=B.sno-1 and A.DBName=B.DBName and A.fileno=B.fileno

where a.fileno = 1

group by A.DBName,A.fileno order by 1
