import logging
import os
import glob
from label import Label

class Job:
    
    def __init__(id, connection):

        logging.debug (" Initializing Job: %s" % id)

        strSQL = "select * from jobs where id = ?"
        cursor = connection.cursor()
        cursor.execute(strSQL, id)
        row = cursor.fetchone()

        if row:
            self.id = row.id
            self.label_id = row.tapeid
            self.copies = row.copies
            self.status = row.status
            self.printonly = (row.printonly == "y")
            self.dvd = (row.dvd == "y")
            self.master = (row.master == "y")
            self.pulpit = (row.pulpit == "y")
            self.label = Label()
            self.label.load_from_db(self.id, connection)

        logging.debug(" Finished initializing Job: %s" % id)

    def get_status_from_db(self, connection):
    
        strSQL = "select status from jobs where id = ?" 
        cursor = connection.cursor()
        cursor.execute(strSQL, self.id)
        row = cursor.fetchone()

        if row:
            self.status = row.status

    def get_status_from_ptburn(self, ptburn_jobs_dir, label_file_dir): 
        # valid statuses: 
        # 0 - on hold 
        # 1 - submitted 
        # 2 - received 
        # 3 - processing 
        # 4 - completed 
        # 5 - failed (error) 
        
        logging.debug(" Getting job status for Job: %s for Service: %s" % (self.id, self.label.get_label_key()))

        job_file_base = "%s%s%s" % (ptburn_jobs_dir, "JOB_", self.id)

        if os.path.exists(job_file_base + ".jrq"):
            self.status = 2
        elif os.path.exists(job_file_base + ".inp"):
            self.status = 3
        elif os.path.exists(job_file_base + ".qrj"):
            self.status = 3
        elif os.path.exists(job_file_base + ".don"):
            # this clean up was being done by the old vbs script -- no longer needed
            #At this point the job is ether successful or failed
            #we should clean up any .prn files associated with this job
            #now that .prn files are being created on a per-job basis
            # Set regex = new RegExp
            # regex.Global = True 
            # regex.IgnoreCase = True 
            # regex.Pattern = ".+\-" & CStr(nID) & "\.prn"
            # Set folder = FSO.GetFolder(strLabelFileDir)
            # Set fc = folder.Files 
            # For Each fl In fc
            #   If  regex.Test(fl.name)  Then
            #       fl.Delete 'delete the file if it exists
            #   End If
            # Next
            self.status = 4
        elif os.path.existss(job_file_base + ".err"):
            #either of these conditions result in an error, the first means there was an acutal error from ptburn 
            self.status = 5
        else:
            #the second means that we couldn't even find the job file for this running job so we flag it as an error 
            self.status = 5
        
        logging.debug("     Job Status: %s" % nStatus)

    def set_status_in_db(self, connection):
        strSQL = "update jobs set status = ?, lastupdate = now() where id = ?"
        cursor = connection.cursor()
        cursor.execute(strSQL, self.status, self.id)

    
    def submit_job_to_ptburn(self, audio_files_dir, label_file_dir, ptburn_jobs_dir):
        logging.debug(" Submitting Job: %s for Service: %s To PTBurn." % (self.id, self.label.get_label_key))

        if self.printonly or required_files_exist(audio_files_dir):         
            # do some work
            # first we make the label so it can be referenced in the job
            if self.dvd:
                label_file = "dvd-label.std"
            else:
                if self.master:
                    label_file = "cd-label-master.std"
                else:
                    if self.pulpit:
                        label_file = "cd-label-pulpit.std"
                    else:
                        label_file = "cd-label.std"

            # now we write the data into the job file 
            job_file_name = "%sJOB_%s.jrq" % (ptburn_jobs_dir, nID)

            with open(job_file_name, 'w') as f:
                
                f.write("JobID = %s\n" % self.id)

                if not self.printonly:
                    filespec = audio_files_dir + self.label.get_label_key() + "*.mp3"
                    file_list = glob.glob(filespec)
                    f.write("VolumeName = %s\n" % self.label.get_label_key())
                    for audio_file in file_list:
                        f.write("AudioFile = %s\n" % audio_file)
                    f.write("CloseDisc = YES")
                    
                f.write("Copies = %s\n" % self.copies)
                f.write("PrintLabel = %s\\%s\n" % (audio_files_dir, label_file))
                f.write("MergeField =  %s\n" % self.label.sermon_title)
                f.write("MergeField =  %s\n" % self.label.date)
                f.write("MergeField =  %s\n" % self.label.day)
                f.write("MergeField =  %s\n" % self.label.minister)

            logging.debug(" Job was submitted.")

    
    def required_files_exist(self, audio_files_dir):
        logging.debug("     Checking if required files exist for current job.")

        filespec = audio_files_dir + self.label.get_label_key() + "*.mp3"
        file_list = glob.glob(filespec)

        if len(file_list) > 0:
            return True

        logging.debug("    Unable to find required files.")
        return False

