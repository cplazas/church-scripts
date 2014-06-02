import unittest
from mock import Mock, patch
from label import Label

import datetime

class LabelTest(unittest.TestCase):

    def setUp(self):
        mock_row = Mock(ID=1, Year=2014, Month=01, Date=01, Day="SUN, AM",
                        Minister="H.L. Sheppard")
        mock_row.__setattr__("Service#", 1)
        mock_row.__setattr__("Sermon Title", "Test Title")
        mock_row
        cursor = Mock()
        cursor.fetchone.return_value = mock_row
        connection = Mock()
        connection.cursor.return_value = cursor
        
        self.connection = connection

    def test_load_from_db(self):
        label = Label()
        label.load_from_db(1, self.connection)

        self.assertEquals(label.id, 1)
        self.assertEquals(label.day, "SUN, AM")
        self.assertEquals(label.sermon_title, "Test Title")
        self.assertEquals(label.minister, "H.L. Sheppard")
        self.assertEquals(label.date, datetime.date(2014, 1, 1))

    def test_get_label_key(self):
        label = Label()
        label.load_from_db(1, self.connection)

        self.assertEquals(label.get_label_key(), "010114AM")

