module Hoe::Minitest
  VERSION = "1.1.0"

  def define_minitest_tasks
    self.testlib = :minitest
  end
end
