import datetime

class Label:
	# def __init__(id, date, day, service, minister, sermon_title):
	# 	self.id = id
	# 	self.date = date
	# 	self.day = day
	# 	self.service = service
	# 	self.minister = minister
	# 	self.sermon_title = sermon_title
	
	
	def load_from_db (self, id,  connection ):
		cursor = connection.cursor()
		cursor.execute("SELECT * FROM \"Tapes\" WHERE \"ID\" = ?", id)

		row = cursor.fetchone()
		if row:
		    print row
		    self.id = row.ID
		    self.date = datetime.date(row.Year, row.Month, row.Date)
		    self.day = row.Day
		    self.service = row.__getattribute__("Service#")
		    self.minister = row.Minister
		    self.sermon_title = row.__getattribute__("Sermon Title")
	
	def get_label_key(self)
		return self.date.strftime("%m%d%Y") + self.day[-2:]

	