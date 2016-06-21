class Pr < ActiveRecord::Base

  class NullPr
    def nil?
      true
    end

    def method_missing(*args, &block)
      self
    end
  end

  def self.null_pr
    NullPr.new
  end

  def self.find_or_create(dict)
    pr = Pr.find_by(pr_id: dict[:pr_id])
    if pr
      pr.update(dict)
    else
      pr = Pr.new(dict)
    end
    pr.save
    pr
  end

  def pending
    GHClient.create_status(self, 'pending')
  end

  def pass
    GHClient.create_status(self, 'success')
  end

  def fail
    GHClient.create_status(self, 'error')
  end

  def set_status(exitstatus)
    case exitstatus
    when 0
      self.pass
    else
      self.fail
    end
    self.save
  end

end
