Hoe.plugin :minitest, :perforce, :email

module Hoe::Seattlerb
  VERSION = "1.2.9"

  def define_seattlerb_tasks
    if Hoe.plugins.include? :publish then
      base = "/data/www/docs.seattlerb.org"
      rdoc_locations << "docs.seattlerb.org:#{base}/#{remote_rdoc_dir}"
    end
  end
end
