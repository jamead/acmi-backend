#!//home/mead/epics/pscdrv/bin/linux-x86_64/pscdemo 
epicsEnvSet("TOP","/home/mead/epics/pscdrv")
epicsEnvSet("BPMDIR","$(TOP)")
epicsEnvSet("ACMI_DBDIR","/home/mead/acmi/fwk/acmi-backend/ioc")


epicsEnvSet("IOCNAME", "LN-BI")






###
epicsEnvSet("EPICS_CA_AUTO_ADDR_LIST", "YES")
#epicsEnvSet("EPICS_CA_ADDR_LIST", "10.0.142.20")
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "16000000")


## You may have to change psc to something else
## everywhere it appears in this file

## Register all support components
dbLoadDatabase("$(BPMDIR)/dbd/pscdemo.dbd",0,0)
pscdemo_registerRecordDeviceDriver(pdbbase) 

# BPM IP address
epicsEnvSet("ACMI_IP", "10.0.142.232");  #4009



########## use template

### PVs for first LINAC ZBPM:
dbLoadRecords("$(ACMI_DBDIR)/zudfe.db", "P=$(IOCNAME), NO=BE")
dbLoadRecords("$(ACMI_DBDIR)/acmi_chaina.db", "P=$(IOCNAME), NO=A")


#####################################################
var(PSCDebug, 5)	#5 full debug

#bpm1 Create the PSC
createPSC("Tx", $(ACMI_IP), 7, 0)
createPSC("Wfm", $(ACMI_IP), 20, 1)
createPSC("Rx", $(ACMI_IP), 600, 1)

###########
iocInit
###########

#epicsThreadSleep 1

#dbpf $(IOCNAME){BPM:1}Gain:RfAtte-SP, 0 






