module Hoe::Minitest
  VERSION = "1.1.0"

  def initialize_minitest
    self.testlib = :minitest
  end

  def define_minitest_tasks
    # nothing to do
  end
end
