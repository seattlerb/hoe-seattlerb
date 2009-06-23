module Hoe::Email

  Hoe::DEFAULT_CONFIG["email"] = {
    "to"   => [],
    "user" => nil,
    "pass" => nil,
    "host" => nil,
    "port" => 25,
    "auth" => nil,
  }

  attr_reader :email_to

  def initialize_email
    with_config do |config, _|
      @email_to = config["email"]["to"] rescue nil
    end
  end

  def define_email_tasks
    require 'net/smtp'
    require 'time'

    # attach to announcements
    task :announce => :send_email

    desc "Send an announcement email."
    task :send_email do
      message = generate_email :full

      with_config do |conf, _|
        host = conf["email"]["host"]
        port = conf["email"]["port"]
        user = conf["email"]["user"]
        pass = conf["email"]["pass"]
        auth = conf["email"]["auth"]

        start_args = [Socket.gethostname, user, pass, auth].compact

        smtp = Net::SMTP.new(host, port)
        smtp.set_debug_output $stderr if $DEBUG
        smtp.start(*start_args) do |server|
          server.send_message message, Array(email).first, *email_to
        end
      end
    end
  end
end
