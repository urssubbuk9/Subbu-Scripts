insert INTO dba_admin.dbo.tempdb_monitor_freespace
SELECT getdate() "datetime" , SUM(unallocated_extent_page_count) AS [free pages],
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;
--select * from dba_admin.dbo.tempdb_monitor_freespace
insert INTO dba_admin.dbo.tempdb_monitor_version_store
SELECT getdate() "datetime" , SUM(version_store_reserved_page_count) AS [version store pages used],
(SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;
--select * from dba_admin.dbo.tempdb_monitor_version_store
insert INTO dba_admin.dbo.tempdb_monitor_version_store_transactions
SELECT getdate() "datetime" , transaction_id
FROM sys.dm_tran_active_snapshot_database_transactions
ORDER BY elapsed_time_seconds DESC;
insert INTO dba_admin.dbo.tempdb_monitor_internal_objects
SELECT getdate() "datetime" , SUM(internal_object_reserved_page_count) AS [internal object pages used],
(SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;
insert INTO dba_admin.dbo.tempdb_monitor_user_objects
SELECT getdate() "datetime" , SUM(user_object_reserved_page_count) AS [user object pages used],
(SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;
--SELECT getdate() "datetime" , SUM(size)*1.0/128 AS [size in MB]
--FROM tempdb.sys.database_files
insert  INTO dba_admin.dbo.tempdb_monitor_active_session
SELECT getdate() "datetime" , R1.sql_handle, R1.transaction_id, R1.session_id, R1.request_id, db_name(R1.database_id) as database_name,
es.login_name, es.host_name, R1.request_internal_objects_alloc_page_count, R1.request_internal_objects_dealloc_page_count,
R1.user_objects_alloc_page_count , R1.user_objects_dealloc_page_count,
SUBSTRING(R2.[text],R1.statement_start_offset/2,
    (CASE
        WHEN R1.statement_end_offset = -1
     THEN LEN(CONVERT(nvarchar(max), R2.[text])) * 2
        ELSE R1.statement_end_offset
     END - R1.statement_start_offset)/2) AS [QueryText] , R1.plan_handle
FROM
( SELECT R1.session_id, R1.request_id, R2.transaction_id,
      R1.request_internal_objects_alloc_page_count, R1.request_internal_objects_dealloc_page_count,
      R1.user_objects_alloc_page_count , R1.user_objects_dealloc_page_count,
      R2.sql_handle, R2.statement_start_offset, R2.statement_end_offset, R2.plan_handle, R2.database_id
  FROM
   (SELECT session_id, request_id,
    SUM(internal_objects_alloc_page_count) AS request_internal_objects_alloc_page_count,
    SUM(internal_objects_dealloc_page_count)AS request_internal_objects_dealloc_page_count ,
    SUM(user_objects_alloc_page_count) AS user_objects_alloc_page_count,
    SUM(user_objects_dealloc_page_count) AS user_objects_dealloc_page_count
   FROM sys.dm_db_task_space_usage
   GROUP BY session_id, request_id )R1
   INNER JOIN
   sys.dm_exec_requests R2
   ON R1.session_id = R2.session_id
   and R1.request_id = R2.request_id
)AS R1
  OUTER APPLY sys.dm_exec_sql_text(R1.sql_handle) AS R2
  INNER JOIN sys.dm_exec_sessions AS es
  ON R1.session_id = es.session_id
  and es.session_id <> @@spid
  and R1.sql_handle is not null
