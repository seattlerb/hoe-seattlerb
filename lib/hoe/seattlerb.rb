if Hoe.plugins.include? :seattlerb
  Hoe.plugin :minitest
  Hoe.plugin :perforce
  Hoe.plugin :email
end

module Hoe::Seattlerb
  def define_seattlerb_tasks
    # nothing to do
  end
end
