module Hoe::History
  def define_history_tasks
    # do nothing
  end

  def flog_flay
    flog = `flog -s -c $(cat Manifest.txt | grep -v txt$) 2>/dev/null`
    flay = `flay -s    $(cat Manifest.txt | grep -v txt$) 2>/dev/null`

    flog_total = flog[/([\d\.]+): flog total/, 1].to_f
    flog_avg   = flog[/([\d\.]+): flog\/method average/, 1].to_f
    flay_total = flay[/Total score .lower is better. = (\d+)/, 1].to_i

    return flog_total, flog_avg, flay_total
  end

  def load_history
    require "yaml"
    YAML.load_file(".history.yaml") rescue {}
  end

  def save_history data
    require "yaml"
    File.open ".history.yaml", "w" do |f|
      YAML.dump data, f
    end
  end

  def history versions
    history = load_history
    history.delete "dev" # FIX: this is p4 specific - make a variable?

    flog_total = flog_avg = flay_total = nil

    puts "version\tflog\tavg\tflay"
    versions.each do |version|
      history[version] = yield(version) unless history[version]

      flog_total, flog_avg, flay_total = history[version]
      puts "%s\t%.1f\t%.1f\t%d" % [version, flog_total, flog_avg, flay_total]
    end
  ensure
    save_history history
  end
end
