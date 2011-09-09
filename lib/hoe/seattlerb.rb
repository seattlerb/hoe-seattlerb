Hoe.plugin :minitest, :perforce, :email

module Hoe::Seattlerb
  VERSION = "1.2.7"

  def initialize_seattlerb
    dependency "rdoc", "~> 3.9", :developer
  end

  def define_seattlerb_tasks
    if Hoe.plugins.include? :publish then
      base = "/data/www/docs.seattlerb.org"
      rdoc_locations << "docs.seattlerb.org:#{base}/#{remote_rdoc_dir}"
    end
  end
end
