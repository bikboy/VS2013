<#Script for getting Collection daily reports
Created by tbikbaiev 03-03-2015#>

#defining variables
$dataSource = "imb-mssqlst"
$user = "mcc"
$pwd = "mcc"
$database = "Server"
$connectionString = "Server=$dataSource;uid=$user; pwd=$pwd;Database=$database;Integrated Security=False;"
$path = "\\imb-fs\Y\#Exchange.bnk\!Common\Collection\Supervisor\АНАЛИТИКА\Mediatel History\Call history\"
#$path = "c:\111\"
$timestamp = (Get-Date).ToString('dd-MM-yyyy_hh_mm')
$filename = $path+"PredictiveBuffer_"+$timestamp+".csv"
$archive = $path+"PredictiveBuffer_"+$timestamp+".7z"
$archive2 = $path+"SC_DataForPushkar_MCC_"+$timestamp+".7z"
$archive3 = $path+"SC_DataForPushkar_MCC_NEW_"+$timestamp+".7z"
$yesterday_start = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
$yesterday_end = (Get-Date).ToString('yyyy-MM-dd')
Set-Alias sz "$env:ProgramFiles\7-zip\7z.exe"
$encoding = [System.Text.Encoding]::UTF8

#DB connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

#first query : getting all imports at PredictiveBuffer for yesterday, report name:PredictiveBuffer
$query = "select * from PredictiveBuffer 
			where 
			Date_Imported between '$yesterday_start' and '$yesterday_end'"
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()

#putting data to in-memory table
$table = new-object "System.Data.DataTable"
$table.Load($result)

#data export to predefined file
$table | Export-Csv $filename -Delimiter ";"

sz a -mx=9 $archive $filename
del $filename


#second query , report name: SC_DataForPushkar_MCC_arhive_out_and_time
$filename = $path+"SC_DataForPushkar_MCC_"+$timestamp+".csv"
$query = "select distinct
                  PN_NAME as 'Phone_Type',
                  ANI,
                  DNIS,
                  Queuedescription,
                  calltypename as 'Calltype',
                  calltrace.CLOSEDBYAG,
                  calltrace.CalltraceID,
                  Incomingcalltime,
                  CRM_PARAM1.PARAM_VALUE as 'CRM_PARAM1',
                  CRM_PARAM2.PARAM_VALUE as 'CRM_PARAM2',
                  CRM_PARAM3.PARAM_VALUE as 'CRM_PARAM3',
                  Cause as 'Call_Reason',
                  convert(varchar(8),cast(isnull(IVRTime,0)/24/60/60 as datetime),14) as 'IVR_Time',
                  convert(varchar(8),cast(isnull(WaitTime,0)/24/60/60 as datetime),14) as 'Wait_Time',
                  convert(varchar(8),cast(isnull(RingTime,0)/24/60/60 as datetime),14) as 'Client_Ring_Time',
                  AgentName,
                  convert(varchar(8),cast(isnull(queuecalltrace.ClientTalkTime,0)/24/60/60 as datetime),14) as 'TalkTime',
                  convert(varchar(8),cast(isnull(queuecalltrace.ClientHoldTime,0)/24/60/60 as datetime),14) as 'Hold_Time',
                  convert(varchar(8),cast(isnull(queuecalltrace.ClericalTime,0)/24/60/60 as datetime),14) as 'Clerical_time',
                  CallCodeDetails as 'Call_Code'
                  from calltrace with(nolock)
                  left join agentcalltrace on calltrace.calltraceid = agentcalltrace.calltraceid
                  left join QueueCallTrace on AgentCallTrace.CALLTRACEID=queuecalltrace.CallTraceID and AgentCallTrace.QUEUEID = QueueCallTrace.QUEUEID and AgentCallTrace.AgentID = QueueCallTrace.SentToAgent
                  left join agents on agentcalltrace.AGENTID=agents.agentid 
                  left join queues on calltrace.QUEUEID=queues.QUEUEID
                  --left join queues queues2 on calltrace.QUEUEID=queues2.QUEUEID
                  left join calltypes on calltrace.CALLTYPE=calltypes.CALLTYPE
                  left join callcodes on calltrace.callcode=callcodes.callcode
                  left join enumCallExitPoints on QueueCallTrace.ExitPoint=enumCallExitPoints.id
                  left join dialercodes on calltrace.dialerresult=dialercodes.callcode
                  left join leads_crm CRM_PARAM1 on calltrace.LEADID=CRM_PARAM1.CLIENT_ID and CRM_PARAM1.PARAM_NAME='CRM_PARAM1'
                  left join leads_crm CRM_PARAM2 on calltrace.LEADID=CRM_PARAM2.CLIENT_ID and CRM_PARAM2.PARAM_NAME='CRM_PARAM2'
                  left join leads_crm CRM_PARAM3 on calltrace.LEADID=CRM_PARAM3.CLIENT_ID and CRM_PARAM3.PARAM_NAME='CRM_PARAM3'
                  left join leads_numbers on calltrace.DNIS=leads_numbers.phone_no and calltrace.LEADID=leads_numbers.CLIENT_ID
                  left join tblphonenames on leads_numbers.phonetypeid=tblphonenames.PN_ID
                  where
				  INCOMINGCALLTIME  between '$yesterday_start' and '$yesterday_end'"
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.CommandTimeout = 600
$result = $command.ExecuteReader()
$table1 = new-object "System.Data.DataTable" 
$table1.Load($result) 


#data export to predefined file
$table1 | Export-Csv $filename -Encoding "unicode" -Delimiter ";"

sz a -mx=9 $archive2 $filename
del $filename
<#
#third query , report name: SC_DataForPushkar_MCC_arhive_out_and_time with agentcalltrace join
$filename = $path+"SC_DataForPushkar_MCC_NEW_"+$timestamp+".csv"
$query = "select 
			PN_NAME as 'Phone_Type',
			ANI,
			DNIS,
			Queuedescription,
			calltypename as 'Calltype',
			calltrace.CLOSEDBYAG,
			calltrace.CalltraceID,
			Incomingcalltime,
			CRM_PARAM1.PARAM_VALUE as 'CRM_PARAM1',
			CRM_PARAM2.PARAM_VALUE as 'CRM_PARAM2',
			CRM_PARAM3.PARAM_VALUE as 'CRM_PARAM3',
			Cause as 'Call_Reason',
			convert(varchar(8),cast(isnull(IVRTime,0)/24/60/60 as datetime),14) as 'IVR_Time',
			convert(varchar(8),cast(isnull(WaitTime,0)/24/60/60 as datetime),14) as 'Wait_Time',
			convert(varchar(8),cast(isnull(RingTime,0)/24/60/60 as datetime),14) as 'Client_Ring_Time',
			AgentName,
			convert(varchar(8),cast(isnull(queuecalltrace.ClientTalkTime,0)/24/60/60 as datetime),14) as 'TalkTime',
			convert(varchar(8),cast(isnull(queuecalltrace.ClientHoldTime,0)/24/60/60 as datetime),14) as 'Hold_Time',
			convert(varchar(8),cast(isnull(queuecalltrace.ClericalTime,0)/24/60/60 as datetime),14) as 'Clerical_time',
			CallCodeDetails as 'Call_Code'
			from calltrace with(nolock)
			left join agentcalltrace on calltrace.calltraceid = agentcalltrace.calltraceid
			inner join QueueCallTrace on calltrace.CALLTRACEID=queuecalltrace.CallTraceID and AgentCallTrace.QUEUEID = QueueCallTrace.QUEUEID
			left join agents on agentcalltrace.AGENTID=agents.agentid 
			inner join queues on calltrace.QUEUEID=queues.QUEUEID
			inner join calltypes on calltrace.CALLTYPE=calltypes.CALLTYPE
			left join callcodes on calltrace.callcode=callcodes.callcode
			inner join enumCallExitPoints on QueueCallTrace.ExitPoint=enumCallExitPoints.id
			left join dialercodes on calltrace.dialerresult=dialercodes.callcode
			left join leads_crm CRM_PARAM1 on calltrace.LEADID=CRM_PARAM1.CLIENT_ID and CRM_PARAM1.PARAM_NAME='CRM_PARAM1'
			left join leads_crm CRM_PARAM2 on calltrace.LEADID=CRM_PARAM2.CLIENT_ID and CRM_PARAM2.PARAM_NAME='CRM_PARAM2'
			left join leads_crm CRM_PARAM3 on calltrace.LEADID=CRM_PARAM3.CLIENT_ID and CRM_PARAM3.PARAM_NAME='CRM_PARAM3'
			left join leads_numbers on calltrace.DNIS=leads_numbers.phone_no and calltrace.LEADID=leads_numbers.CLIENT_ID
			left join tblphonenames on leads_numbers.phonetypeid=tblphonenames.PN_ID
			where 
			INCOMINGCALLTIME  between '$yesterday_start' and '$yesterday_end'"
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.CommandTimeout = 600
$result = $command.ExecuteReader()
$table2 = new-object "System.Data.DataTable" 
$table2.Load($result) 


#data export to predefined file
$table2 | Export-Csv $filename -Encoding "unicode" -Delimiter ";"

sz a -mx=9 $archive3 $filename
del $filename
#>


#send confirm message
$pass = ConvertTo-SecureString "k2Ve=8asWa7UDrA" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential("IMB\IMBMediatelMail" ,$pass)
$message = "Новые отчеты:"+$path
Send-MailMessage -To opsanalysts@platinumbank.com.ua -Subject $timestamp -Body $message -SmtpServer mail.imb.local -from IMBMediatelMail@platinumbank.com.ua -Credential $Cred -Encoding $encoding

$connection.Close()
