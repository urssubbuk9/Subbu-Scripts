USE [master]
GO

/****** Object:  Table [dbo].[Monitor_Blocking]    Script Date: 24-05-2023 18:32:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Monitor_Blocking](
	[CollectionDate] [datetime] NOT NULL,
	[Blocker] [varchar](16) NOT NULL,
	[Query] [nvarchar](max) NULL,
	[spid] [smallint] NOT NULL,
	[blocked] [smallint] NOT NULL,
	[Waittype] [nchar](32) NULL,
	[waittime] [bigint] NOT NULL,
	[waitresource] [nchar](256) NOT NULL,
	[dbid] [smallint] NOT NULL,
	[cpu] [int] NOT NULL,
	[physical_io] [bigint] NOT NULL,
	[login_time] [datetime] NOT NULL,
	[last_batch] [datetime] NOT NULL,
	[open_tran] [smallint] NOT NULL,
	[status] [nchar](30) NOT NULL,
	[hostname] [nchar](128) NOT NULL,
	[program_name] [nchar](128) NOT NULL,
	[hostprocess] [nchar](10) NOT NULL,
	[loginame] [nchar](128) NOT NULL,
	[Procedure] [nvarchar](max) NULL,
	[LastWaittype] [nchar](32) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [msdb]
GO

/****** Object:  Job [Blocking_mon]    Script Date: 24-05-2023 18:31:26 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 24-05-2023 18:31:26 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Blocking_mon', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DESKTOP-N609VJG\Lishitha', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [step1]    Script Date: 24-05-2023 18:31:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON
use [tempdb]
GO
if (ISNULL(object_id(''tempdb..#temp''),0)>0)
BEGIN
drop table #TEMP
END
use [master]
GO
select A.*,B.objectid,B.text into #TEMP from sys.sysprocesses A cross apply sys.dm_exec_sql_text(sql_handle) B where spid<>@@spid and spid>50
insert into [dbo].[Monitor_Blocking]
select distinct getdate(),case A.blocked when 0 then ''Lead Blocker''
else ''Non Lead Blocker'' end as ''Blocker'',case A.stmt_end-A.stmt_start
when 0 then A.text
else
substring(A.text,(A.stmt_start/2)+1,case A.stmt_end
when -1 then len(A.text)+1
else ((A.stmt_end-A.stmt_start)/2)+1
end)
end as ''Query'',A.spid,A.blocked,case A.waittype
when 0x0000 then NULL
else A.lastwaittype end as ''Waittype'',A.waittime,A.waitresource,A.dbid,A.cpu,A.physical_io,A.login_time,A.last_batch,A.open_tran,A.status,A.hostname,A.program_name,A.hostprocess,A.loginame,A.text as ''Procedure'',A.lastwaittype
from #TEMP A join #TEMP B on (a.spid=b.blocked) or (a.spid=b.spid and a.blocked!=0) order by A.blocked,A.waittime desc
drop table #TEMP', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sched1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230523, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ed0c34fb-e60a-4fdd-b296-8159425b465f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
