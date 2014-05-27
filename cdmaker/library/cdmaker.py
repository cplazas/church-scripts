import logging
import pyodbc
from job import Job

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
			jobarray = grab_new_jobs(conn)
			for job in jobarray:
				logging.debug(" Submitting Job: %s for Service: %s" % (job.id, job.label.get_label_key()))
				job.submit_job_to_ptburn(audio_files_dir, label_file_dir, ptburn_job_dir)

		logging.debug(" Checking for existing Jobs...")
		if check_for_running_jobs():
			currentjobs = get_running_jobs(conn)
			for job in currentjobs:
				job.get_status_from_ptburn(ptburn_job_dir, label_file_dir)
				job.set_status_in_db(conn)

	def check_for_new_jobs(self, connection):
		sSQL = "SELECT COUNT(*) FROM JOBS WHERE STATUS = 1"

		cursor = connection.cursor()
		cursor.execute(sSQL)

		row = cursor.fetchone()
		if row:
			if row[0] > 0:
				return True

		return False

	def grab_new_jobs (self, connection):
		jobs = []		
		sSQL = "SELECT ID FROM JOBS WHERE STATUS = 1"
		cursor = connection.cursor()
		cursor.execute(sSQL)

		row = cursor.fetchone()
		while row:
			new_job = Job(row.ID, connection)
			new_job.status = 2
			new_job.set_status_in_db(connection)
			jobs.append(new_job)
			row = cursor.fetchone()

		return jobs

	def check_for_running_jobs(self):
		sSQL = "SELECT COUNT(*) FROM JOBS WHERE STATUS > 1 AND STATUS < 4"
		cursor = connection.cursor()
		cursor.execute(sSQL)

		row = cursor.fetchone()
		if row:
			if row[0] > 0:
				return True

		return False

	def get_running_jobs (self, connection):
		jobs = []
		sSQL = "SELECT ID FROM JOBS WHERE STATUS > 1 AND STATUS < 4"
		cursor = connection.cursor()
		cursor.execute(sSQL)

		row = cursor.fetchone()
		while row:
			new_job = Job(row.ID, connection)
			jobs.append(new_job)
			row = cursor.fetchone()

		return jobs
