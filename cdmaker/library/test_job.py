import unittest
from mock import Mock, patch, mock_open
import os
import datetime
from job import Job

class JobTest(unittest.TestCase):

    def setUp(self):
        self.mock_row = Mock(id=1, tapeid=1, copies=1, status=1, printonly="n",
                        dvd="n", master="n", pulpit="n")
        self.cursor = Mock()
        self.cursor.fetchone.return_value = self.mock_row
        self.connection = Mock()
        self.connection.cursor.return_value = self.cursor

        self.outfile = mock_open()

    @patch('job.Label')
    def test_get_status_from_db(self, label_patch):


        new_job = Job(1, self.connection)
        self.mock_row.status = 2
        new_job.get_status_from_db(self.connection)

        self.assertEquals(new_job.status, 2)

    @patch('os.path.exists')
    @patch('job.Label')
    def test_get_status_from_ptburn(self, label_patch, exists):
        ext = ".jrq"
        def side_effect(path):
            return path.endswith(ext)

        exists.side_effect = side_effect

        new_job = Job(1, self.connection)

        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 2)
        exists.called_once_with("test/JOB_1.jrq")

        exists.reset_mock()
        ext = ".inp"
        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 3)
        self.assertEquals(exists.call_count, 2)
        exists.called_with("test/JOB_1.inp")

        exists.reset_mock()
        ext = ".qrj"
        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 3)
        self.assertEquals(exists.call_count, 3)
        exists.called_with("test/JOB_1.qrj")

        exists.reset_mock()
        ext = ".don"
        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 4)
        self.assertEquals(exists.call_count, 4)
        exists.called_with("test/JOB_1.don")

        exists.reset_mock()
        ext = ".err"
        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 5)
        self.assertEquals(exists.call_count, 5)
        exists.called_with("test/JOB_1.err")

        exists.reset_mock()
        ext = ".xxx"
        new_job.get_status_from_ptburn("test/", "test/")

        self.assertEquals(new_job.status, 5)
        self.assertEquals(exists.call_count, 5)
    
    @patch('job.Job.required_files_exist')
    @patch('job.Label')
    def test_submit_job_to_ptburn_no_files(self, label_patch, required_files):

        outfile = mock_open()
        patch('__main__.open', outfile)

        required_files.return_value = False
        new_job = Job(1, self.connection)
        new_job.submit_job_to_ptburn("/audio/", "/labels/","/ptburn/")

        self.assertFalse(outfile.called)

    @patch('job.Job.required_files_exist')
    @patch('job.Label')
    def test_submit_job_to_ptburn_print_only(self, label_patch, required_files):

        required_files.return_value = False
        label = Mock(sermon_title="title", date=datetime.date(2014,1,1),
           day="SUN, AM", minister="H.L. Sheppard")
        
        new_job = Job(1, self.connection)
        new_job.printonly = True
        new_job.label = label
        new_job.submit_job_to_ptburn("/audio/", "/labels/","/tmp/")

        self.assertTrue(os.path.exists("/tmp/JOB_1.jrq"))
        job_file = open("/tmp/JOB_1.jrq").readlines()
        self.assertEquals(len(job_file), 7)
        self.assertTrue("JobID = 1\n" in job_file)
        self.assertTrue("Copies = 1\n" in job_file)
        self.assertTrue("PrintLabel = /labels/cd-label.std\n" in job_file)
        self.assertTrue("MergeField = title\n" in job_file)
        self.assertTrue("MergeField = 01/01/2014\n" in job_file)
        self.assertTrue("MergeField = SUN, AM\n" in job_file)
        self.assertTrue("MergeField = H.L. Sheppard\n" in job_file)

    @patch('job.glob.glob')
    @patch('job.Job.required_files_exist')
    @patch('job.Label')
    def test_submit_job_to_ptburn_with_audio(self, label_patch, required_files,
                                             glob_patch):

        required_files.return_value = True
        label = Mock(sermon_title="title", date=datetime.date(2014,1,1),
           day="SUN, AM", minister="H.L. Sheppard")
        label.get_label_key.return_value = "010114PM"
        glob_patch.return_value = ["one.mp3", "two.mp3"]
        
        new_job = Job(1, self.connection)
        new_job.printonly = False
        new_job.label = label
        new_job.submit_job_to_ptburn("/audio/", "/labels/","/tmp/")

        self.assertTrue(os.path.exists("/tmp/JOB_1.jrq"))
        job_file = open("/tmp/JOB_1.jrq").readlines()
        self.assertEquals(len(job_file), 11)
        self.assertTrue("JobID = 1\n" in job_file)
        self.assertTrue("VolumeName = 010114PM\n" in job_file)
        self.assertTrue("AudioFile = one.mp3\n" in job_file)
        self.assertTrue("AudioFile = two.mp3\n" in job_file)
        self.assertTrue("CloseDisc = YES\n" in job_file)
        self.assertTrue("Copies = 1\n" in job_file)
        self.assertTrue("PrintLabel = /labels/cd-label.std\n" in job_file)
        self.assertTrue("MergeField = title\n" in job_file)
        self.assertTrue("MergeField = 01/01/2014\n" in job_file)
        self.assertTrue("MergeField = SUN, AM\n" in job_file)
        self.assertTrue("MergeField = H.L. Sheppard\n" in job_file)

    @patch('job.glob.glob')
    @patch('job.Label')
    def test_required_files_exist_no_files(self, label_patch, glob_patch):

        label_patch.get_label_key.return_value = "010114PM"
        glob_patch.return_value = []

        new_job = Job(1, self.connection)
        self.assertFalse(new_job.required_files_exist("/audio/"))
        label_patch.get_label_key.called_once()
        glob_patch.called_once_with("/audio/010114PM*.mp3")

    @patch('job.glob.glob')
    @patch('job.Label')
    def test_required_files_exist_with_files(self, label_patch, glob_patch):

        label_patch.get_label_key.return_value = "010114PM"
        glob_patch.return_value = ["one.mp3", "two.mp3"]

        new_job = Job(1, self.connection)
        self.assertTrue(new_job.required_files_exist("/audio/"))
        label_patch.get_label_key.called_once()
        glob_patch.called_once_with("/audio/010114PM*.mp3")
