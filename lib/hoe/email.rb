##
# Email plugin for Hoe.

module Hoe::Email

  Hoe::DEFAULT_CONFIG["email"] = {
    "to"   => [],
    "user" => nil,
    "pass" => nil,
    "host" => nil,
    "port" => "smtp",
    "auth" => nil,
    "tls"  => nil,
  }

  ##
  # Who to send email to.

  attr_reader :email_to

  ##
  # Initialize the email plugin. Get the email/to from hoe's config.

  def initialize_email
    with_config do |config, _|
      @email_to = config["email"]["to"] rescue nil
    end
  end

  ##
  # Define email tasks.

  def define_email_tasks
    require 'net/smtp'
    begin
      require 'smtp_tls'
    rescue LoadError
    end

    # attach to announcements
    task :announce => :send_email
    task :post_blog => :send_email # force email to the front

    desc "Send an announcement email."
    task :send_email do
      warn "sending email"
      message = generate_email :full

      with_config do |conf, _|
        host = conf["email"]["host"]
        port = conf["email"]["port"]
        user = conf["email"]["user"]
        pass = conf["email"]["pass"]
        auth = conf["email"]["auth"]
        tls  = conf["email"]["tls"]

        port = Socket.getservbyname port unless Integer === port

        tls = port != 25 if tls.nil?

        start_args = [Socket.gethostname, user, pass, auth].compact

        raise 'gem install smtp_tls' if tls and
          not Net::SMTP.method_defined? :starttls

        smtp = Net::SMTP.new(host, port)
        smtp.set_debug_output $stderr if $DEBUG
        smtp.enable_starttls if tls
        begin
          smtp.start(*start_args) do |server|
            server.send_message message, Array(email).first, *email_to
          end
        rescue Errno::ETIMEDOUT => e
          warn "sending email timed out: #{e.message}"
        end
      end
      warn "...done"
    end
  end
end
