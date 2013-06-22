require 'find'

# TODO: release requirements have been met
# TODO: passes tests? (with warning or a flag to skip)

##
# seattle.rb perforce projects are structured as:
#
# project_name/
#   dev/
#     History.txt
#     Manifest.txt
#     README.txt
#     Rakefile
#     bin/
#     lib/
#     test/
#     ...
#   1.0.0/...
#   1.0.1/...
#   ...
#
# Each release is a branch from project_name/dev to
# project_name/version. In perforce, branches can be explicit (created
# via a branch spec) or implicit (created by command-line). This
# structure can accommodate either but the code below is implicit.

module Hoe::Perforce

  ##
  # Files fore perforce to ignore. Probably not needed now that they
  # support a dot-ignore file. I have yet to use that so... yeah.

  attr_accessor :perforce_ignore

  ##
  # Initializes the perforce plugin.

  def initialize_perforce
    self.perforce_ignore = []
  end

  ##
  # Defines tasks for the perforce plugin.

  def define_perforce_tasks
    warn :define_perforce_tasks if $DEBUG

    desc "branch the project from dev to version dir"
    task :branch do
      original_dir = File.basename(Dir.pwd)

      Dir.chdir ".."

      target_dir = File.directory?(version) ? version : original_dir
      branching  = target_dir == original_dir && target_dir != version
      pkg = File.basename(Dir.pwd)

      begin
        p4_integrate original_dir, version if branching
        validate_manifest_file version
        p4_submit "Branching #{pkg} to version #{version}" if branching
      rescue => e
        warn e
        p4_revert version
        raise e
      end

      Dir.chdir version
    end

    task :prerelease => :branch

    task :postrelease => :announce do
      system 'rake clean'
    end

    desc "Generate historical flog/flay data for all releases"
    task :history do
      p4_history
    end
  end

  ##
  # perforce has an annoying "feature" that reads PWD and chdir's to
  # it. Without either mucking in ENV or forcing a different kind of
  # system call, it'll be in the original rake directory. I don't want
  # that for these recipes, so we tack on ";" in order to force the
  # right type of exec.

  def p4sh cmd
    sh "#{cmd};"
  end

  ##
  # Audit the manifest file against files on the file system.

  def validate_manifest_file manifest_dir
    manifest_file = "#{manifest_dir}/Manifest.txt"
    raise "#{manifest_file} does not exist" unless test ?f, manifest_file
    manifest = File.new(manifest_file).readlines.map { |x| x.strip }
    manifest -= perforce_ignore

    exclusions = with_config do |config, _|
      config["exclude"]
    end

    local_manifest = []

    Dir.chdir manifest_dir do
      system 'rake clean'
      Find.find '.' do |f|
        next if f =~ exclusions
        local_manifest << f.sub(/^\.\//, '') if File.file? f
      end
    end

    local_manifest -= perforce_ignore

    extra_files   = local_manifest - manifest
    missing_files = manifest - local_manifest

    msg = []

    unless extra_files.empty? then
      msg << "You have files that are not in your manifest"
      msg << "  #{extra_files.inspect}"
    end

    unless missing_files.empty? then
      msg << "You have files that are missing from your manifest"
      msg << "  #{missing_files.inspect}"
    end

    raise msg.join("\n") unless msg.empty?
  end

  ##
  # Revert the pending (release) directory.

  def p4_revert dir
    puts "reverting #{dir}"
    p4sh "p4 revert #{dir}/..."
  end

  ##
  # Branch a release from +from+ to +to+.

  def p4_integrate from, to
    opened = `p4 opened #{from}/... #{to}/... 2>&1`
    raise "You have files open" if opened =~ /\/\/[^#]+#\d+/
    p4sh "p4 integrate #{from}/... #{to}/..."
  end

  ##
  # Submit the current directory with a description message.

  def p4_submit description
    p4sh "p4 submit -d #{description.inspect} ..."
  end

  ##
  # Return all version directories (and dev).

  def p4_versions
    dirs = Dir["../[0-9]*"].sort_by { |s| Gem::Version.new(File.basename(s)) }
    dirs << "../dev"
    dirs.map { |d| File.basename d }
  end

  ##
  # Return the flog & flay history of all releases.

  def p4_history
    history p4_versions do |version|
      Dir.chdir "../#{version}" do
        flog_flay
      end
    end
  end
end
