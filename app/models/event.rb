class Event < ActiveRecord::Base
  before_validation do
    logger.info self.inspect
  end
  def getJSONData
    _data = {
      "user" => self.user,
      "type" => self.action,
      "date" => self.date.strftime("%Y/%m/%d %H:%M:%SZ")
    }
    if(self.action == "highfive")
      _data[:otheruser] = self.otheruser
    end
    if(self.action == "comment")
      _data[:message] = self.message
    end
    return _data
  end

end
