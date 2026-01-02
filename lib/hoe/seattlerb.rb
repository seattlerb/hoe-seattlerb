Hoe.plugin :minitest, :history, :perforce, :email

class Hoe; end # :nodoc: stfu rdoc... *sigh*

##
# Top level Seattlerb plugin for Hoe. Doesn't really do anything but
# pull in other default plugins.

module Hoe::Seattlerb
  VERSION = "1.3.6" # :nodoc:

  ##
  # Define seattlerb's rdoc location.

  def define_seattlerb_tasks
    if Hoe.plugins.include? :publish then
      base = "/data/www/docs.seattlerb.org"
      rdoc_locations << "docs-push.seattlerb.org:#{base}/#{remote_rdoc_dir}"
    end
  end
end
