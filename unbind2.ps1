Invoke-WebRequest -Uri "http://10.155.126.58/MdtRemoteSupervisorWS/RemoteSupervisorWS.asmx/Connect"
Invoke-WebRequest -Uri "http://10.155.126.58/MdtRemoteSupervisorWS/RemoteSupervisorWS.asmx/DeleteBinding3?EntityID=28&QueueID=95&OldQueueID=&Skill=5&OutgoingQueue=false&IsGroup=true"
Invoke-WebRequest -Uri "http://10.155.126.58/MdtRemoteSupervisorWS/RemoteSupervisorWS.asmx/Logoff"