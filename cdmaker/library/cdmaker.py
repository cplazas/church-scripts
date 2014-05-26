import logging
import pyodbc

class CDMaker:

	def __init__(audio_files_dir, ptburn_job_dir, label_file_dir, connection_string):
		self.audio_files_dir = audio_files_dir
		self.ptburn_job_dir = ptburn_job_dir
		self.label_file_dir = label_file_dir
		self.connection_string = connection_string

	def go(self):
		logging.debug(" Initializing...")
		#Dim oConn, ProcessSet, WshShell

		if not self.connection_string or not self.audio_files_dir or not self.ptburn_job_dir or not self.label_file_dir:
			#some necessary stuff was not set
			logging.error("CDMaker was not initialized properly.")
			
			if not self.connection_string:
				logging.error("     Connection property was not set.")
			
			if not self.audio_files_dir:
				logging.error("     AudioFilesDir property was not set.")

			if not self.ptburn_job_dir:
				logging.error("     PTBurnJobsDir property was not set.")

			if not self.label_file_dir:
				logging.error("     LabelFileDir property was not set.")
						
			return
        
        logging.debug(" Initialized sucessfully...") 
		
		conn = pyodbc.connect(self.connection_string)
		cursor = conn.cursor()

		logging.debug(" Checking for new Jobs...")
		if check_for_new_jobs():
			# Dim jobarray
			# jobarray = GrabNewJobs(oConn)
			
			# For i = lbound(jobarray) To ubound(jobarray)
			# 	oLog.WriteLine Now & " Submitting Job: " & jobarray(i).ID & " for Service: " & jobarray(i).Label.GetLabelKey()
			# 	jobarray(i).SubmitJobToPTBurn strAudioFilesDir, strLabelFileDir, strPTBurnJobDir
			# 	'wscript.stdout.writeline jobarray(i).Label.ServiceTitle
			# Next
			
		

		logging.debug(" Checking for existing Jobs...")
		if check_for_running_jobs():
			# Dim currentjobs
			# currentjobs = GetRunningJobs(oConn)
			# 	'wscript.stdout.writeline "one"
			# 	'wscript.stdout.writeline ubound(currentjobs)
			# For i = lbound(currentjobs) To ubound(currentjobs)
			# 	currentjobs(i).GetStatusFromPTBurn strPTBurnJobDir, strLabelFileDir
			# 	currentjobs(i).SetStatusInDB oConn
			# 	'wscript.stdout.writeline "whateva"
			# 	'wscript.stdout.writeline currentjobs(i).Status
			# Next

		conn.close()

	def check_for_new_jobs(self):
		pass

	def grab_new_jobs (self):
		pass

	def check_for_running_jobs(self):
		pass

	def get_running_jobs (self):
		pass



