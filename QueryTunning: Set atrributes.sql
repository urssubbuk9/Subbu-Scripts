SELECT
	ExecutionPlan						= QueryPlans.query_plan ,
	CachedDateTime						= ProcedureStats.cached_time ,
	LastExecutionDateTime				= ProcedureStats.last_execution_time ,
	ExecutionCount						= ProcedureStats.execution_count ,
	AverageElapsedTime_Microseconds		= CAST ((CAST (ProcedureStats.total_elapsed_time AS DECIMAL(19,2)) / CAST (ProcedureStats.execution_count AS DECIMAL(19,2))) AS DECIMAL(19,2)) ,
	ANSI_NULLS_Value					= IIF (CAST (PlanAttributes.value AS INT) & 32 = 32 , N'True' , N'False') ,
	ANSI_PADDING_Value					= IIF (CAST (PlanAttributes.value AS INT) & 1 = 1 , N'True' , N'False') ,
	ANSI_WARNINGS_Value					= IIF (CAST (PlanAttributes.value AS INT) & 16 = 16 , N'True' , N'False') ,
	ARITHABORT_Value					= IIF (CAST (PlanAttributes.value AS INT) & 4096 = 4096 , N'True' , N'False') ,
	CONCAT_NULL_YIELDS_NULL_Value		= IIF (CAST (PlanAttributes.value AS INT) & 8 = 8 , N'True' , N'False') ,
	NUMERIC_ROUNDABORT_Value			= IIF (CAST (PlanAttributes.value AS INT) & 8192 = 8192 , N'True' , N'False') ,
	QUOTED_IDENTIFIER_Value				= IIF (CAST (PlanAttributes.value AS INT) & 64 = 64 , N'True' , N'False')
FROM
	sys.dm_exec_procedure_stats AS ProcedureStats
CROSS APPLY
	sys.dm_exec_query_plan (ProcedureStats.plan_handle) AS QueryPlans
CROSS APPLY
	sys.dm_exec_plan_attributes (ProcedureStats.plan_handle) AS PlanAttributes
WHERE
	database_id = DB_ID (N'XXX')
AND
	object_id =object_id('XXXXX')
AND
	PlanAttributes.attribute = 'set_options';
GO
