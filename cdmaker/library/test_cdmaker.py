
import unittest
from mock import Mock, patch
import sys

sys.modules['pyodbc'] = Mock()
from cdmaker import CDMaker

import datetime

class CDMakerTest(unittest.TestCase):

    def test_check_for_new_jobs_no_jobs(self):
        mock_row = [0]
        cursor = Mock()
        cursor.fetchone.return_value = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.check_for_new_jobs(connection)

        self.assertFalse(return_value)
        cursor.execute.called_once_with(CDMaker.COUNT_NEW_JOBS_SQL)

    def test_check_for_new_jobs_found_jobs(self):
        mock_row = [1]
        cursor = Mock()
        cursor.fetchone.return_value = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.check_for_new_jobs(connection)

        self.assertTrue(return_value)
        cursor.execute.called_once_with(CDMaker.COUNT_NEW_JOBS_SQL)

    def test_grab_new_jobs_no_jobs(self):
        cursor = Mock()
        cursor.fetchone.return_value = None
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.grab_new_jobs(connection)

        self.assertEquals(return_value, [])
        cursor.execute.called_once_with(CDMaker.GRAB_NEW_JOBS_SQL)

    @patch('cdmaker.Job')
    def test_grab_new_jobs_with_jobs(self, job_patch):
        mock_row = [Mock(ID=1), Mock(ID=2), None]
        cursor = Mock()
        cursor.fetchone.side_effect = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor
        job_1 = Mock(id=1, status=1)
        job_1.set_status_in_db.return_value = None
        job_2 = Mock(id=2, status=1)
        job_2.set_status_in_db.return_value = None
        job_patch.side_effect = [job_1, job_2]

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.grab_new_jobs(connection)

        self.assertEquals(len(return_value), 2)
        self.assertEquals(return_value[0].id, 1)
        self.assertEquals(job_1.status, 2)
        job_1.set_status_in_db.called_once_with(connection)
        self.assertEquals(return_value[1].id, 2)
        self.assertEquals(job_2.status, 2)
        job_2.set_status_in_db.called_once_with(connection)
        cursor.execute.called_once_with(CDMaker.GRAB_NEW_JOBS_SQL)

    def test_check_for_running_jobs_no_jobs(self):
        mock_row = [0]
        cursor = Mock()
        cursor.fetchone.return_value = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.check_for_running_jobs(connection)

        self.assertFalse(return_value)
        cursor.execute.called_once_with(CDMaker.COUNT_RUNNING_JOBS_SQL)

    def test_check_for_running_jobs_found_jobs(self):
        mock_row = [1]
        cursor = Mock()
        cursor.fetchone.return_value = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.check_for_running_jobs(connection)

        self.assertTrue(return_value)
        cursor.execute.called_once_with(CDMaker.COUNT_RUNNING_JOBS_SQL)

    def test_get_running_jobs_no_jobs(self):
        cursor = Mock()
        cursor.fetchone.return_value = None
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.get_running_jobs(connection)

        self.assertEquals(return_value, [])
        cursor.execute.called_once_with(CDMaker.GRAB_RUNNING_JOBS_SQL)

    @patch('cdmaker.Job')
    def test_get_running_jobs_with_jobs(self, job_patch):
        mock_row = [Mock(ID=1), Mock(ID=2), Mock(ID=3), None]
        cursor = Mock()
        cursor.fetchone.side_effect = mock_row
        cursor.execute = Mock()
        connection = Mock()
        connection.cursor.return_value = cursor
        job_patch.side_effect = [Mock(id=1), Mock(id=2), Mock(id=3)]

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        
        return_value = maker.get_running_jobs(connection)

        self.assertEquals(len(return_value), 3)
        self.assertEquals(return_value[0].id, 1)
        self.assertEquals(return_value[1].id, 2)
        self.assertEquals(return_value[2].id, 3)
        cursor.execute.called_once_with(CDMaker.GRAB_RUNNING_JOBS_SQL)

    @patch('cdmaker.pyodbc.connect')
    def test_go_with_invalid_initialization(self, connect):

        connect.return_value = Mock()
        maker = CDMaker("", "/ptburn/", "/label/", "conn_string")
        maker.go()

        self.assertFalse(connect.called)

        maker = CDMaker("/audio/", "", "/label/", "conn_string")
        maker.go()

        self.assertFalse(connect.called)

        maker = CDMaker("/audio/", "/ptburn/", "", "conn_string")
        maker.go()

        self.assertFalse(connect.called)

        maker = CDMaker("/audio/", "/ptburn/", "/label/", "")
        maker.go()

        self.assertFalse(connect.called)

    @patch('cdmaker.CDMaker.get_running_jobs')
    @patch('cdmaker.CDMaker.check_for_running_jobs')
    @patch('cdmaker.CDMaker.grab_new_jobs')
    @patch('cdmaker.CDMaker.check_for_new_jobs')
    @patch('cdmaker.pyodbc.connect')
    def test_go_with_new_jobs(self, connect, check_new, grab_new, check_running,
                              get_running):

        mock_connection = Mock()
        connect.return_value = mock_connection
        check_new.return_value = True
        job1 = Mock()
        job2 = Mock()
        grab_new.return_value = [job1, job2]
        check_running.return_value = False


        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        maker.go()

        connect.assert_called_once_with("conn_string")
        check_new.assert_called_once_with(mock_connection)
        job1.submit_job_to_ptburn.called_once_with("/audio/", "/label/")
        job2.submit_job_to_ptburn.called_once_with("/audio/", "/label/")
        check_running.assert_called_once_with(mock_connection)
        self.assertFalse(get_running.called)


    @patch('cdmaker.CDMaker.get_running_jobs')
    @patch('cdmaker.CDMaker.check_for_running_jobs')
    @patch('cdmaker.CDMaker.grab_new_jobs')
    @patch('cdmaker.CDMaker.check_for_new_jobs')
    @patch('cdmaker.pyodbc.connect')
    def test_go_with_running_jobs(self, connect, check_new, grab_new,
                                  check_running, get_running):

        mock_connection = Mock()
        connect.return_value = mock_connection
        check_new.return_value = False
        job1 = Mock()
        job2 = Mock()
        get_running.return_value = [job1, job2]
        check_running.return_value = True


        maker = CDMaker("/audio/", "/ptburn/", "/label/", "conn_string")
        maker.go()

        connect.assert_called_once_with("conn_string")
        check_new.assert_called_once_with(mock_connection)
        self.assertFalse(grab_new.called)
        check_running.assert_called_once_with(mock_connection)
        job1.get_status_from_ptburn.called_once_with("/audio/", "/label/")
        job1.set_status_in_db.called_once_with(mock_connection)
        job2.get_status_from_ptburn.called_once_with("/audio/", "/label/")
        job2.set_status_in_db.called_once_with(mock_connection)
