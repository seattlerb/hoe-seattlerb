Hoe.plugin :minitest, :perforce, :email

module Hoe::Seattlerb
  VERSION = "1.2.6"

  def define_seattlerb_tasks
    if Hoe.plugins.include? :publish then
      path   = File.expand_path("~/.rubyforge/user-config.yml")
      config = YAML.load(File.read(path)) rescue nil
      if config then
        base = "/var/www/gforge-projects"
        dir  = "#{base}/#{rubyforge_name}/#{remote_rdoc_dir}"

        rdoc_locations << "#{config["username"]}@rubyforge.org:#{dir}"

        base = "/data/www/docs.seattlerb.org"
        rdoc_locations << "docs.seattlerb.org:#{base}/#{remote_rdoc_dir}"
      else
        warn "Couldn't read #{path}. Run `rubyforge setup`."
      end
    end
  end
end
