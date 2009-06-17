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
      @email_to = config["email"]["to"]
    end
  end

  def define_email_tasks
    require 'net/smtp'
    require 'time'
    require 'yaml'
    require 'socket'

    desc "Send an announcement email."
    task "email:send" do
      from_name, from_email = author.first, email.first
      # TODO: sanity check that config is set up
      # REFACTOR:
      subject, title, body, urls = announcement
      body = [title, urls, body, urls].join("\n\n")

      msgstr = [
                "From: #{from_name} <#{from_email}>",
                "To: #{email_to.join(", ")}",
                "Subject: [ANN] #{subject}",
                "Date: #{Time.now.rfc2822}",
                "",
                "#{body}",
                ].join("\n")

      with_config do |conf, _|
        pass = conf["email"]["pass"]
        user = conf["email"]["user"]
        host = conf["email"]["host"]
        auth = conf["email"]["auth"]
        port = conf["email"]["port"]

        start_args = [Socket.gethostname, user, pass, auth].compact

        smtp = Net::SMTP.new(host, port)
        smtp.set_debug_output $stderr if $DEBUG
        smtp.start(*start_args) do |smtp|
          smtp.send_message msgstr, from_email, *email_to
        end
      end
    end
  end
end

