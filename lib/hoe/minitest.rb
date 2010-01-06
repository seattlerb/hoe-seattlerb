module Hoe::Minitest
  def initialize_minitest
    require 'minitest/unit'
    version = MiniTest::Unit::VERSION

    extra_dev_deps << ['minitest', ">= #{version}"]
  end

  def define_minitest_tasks
    self.testlib = :minitest
  end
end
