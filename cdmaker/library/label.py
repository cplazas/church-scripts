import datetime

class Label:
    
    def load_from_db (self, id, connection ):
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM \"Tapes\" WHERE \"ID\" = ?", id)
        row = cursor.fetchone()
        if row:
            self.id = row.ID
            self.date = datetime.date(int(row.Year), int(row.Month), int(row.Date))
            self.day = row.Day
            self.service = row.__getattribute__("Service#")
            self.minister = row.Minister
            self.sermon_title = row.__getattribute__("Sermon Title")
    
    def get_label_key(self):
        return self.date.strftime("%m%d%y") + self.day[-2:]

    