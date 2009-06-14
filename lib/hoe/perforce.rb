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
  def define_perforce_tasks
    warn :define_perforce_tasks if $DEBUG

    desc "branch the project from dev to version dir"
    task :branch do
      Dir.chdir ".."

      target_dir = File.directory?(version) ? version : "dev"
      branching  = target_dir == "dev"

      begin
        p4_integrate "dev", version if branching
        validate_manifest_file version
        p4_submit "Branching #{pkg} to version #{version}" if branching
      rescue => e
        p4_revert version
        raise e
      end

      Dir.chdir version
    end

    task :prerelease => :branch

    # TODO: ensure clean will run no matter what

    task :postrelease => [:announce, :email, :clean]

    task :email do
      sh "mv email.txt ..; open -e ../email.txt"
    end
  end

  def validate_manifest_file manifest_dir
    manifest_file = "#{manifest_dir}/Manifest.txt"
    raise "#{manifest_file} does not exist" unless test ?f, manifest_file
    manifest = File.new(manifest_file).readlines.map { |x| x.strip }

    local_manifest = []

    Dir.chdir manifest_dir do
      Find.find '.' do |f|
        local_manifest << f.sub(/^\.\//, '') if File.file? f
      end
    end

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

  def p4_revert dir
    puts "reverting #{dir}"
    sh "p4 revert #{dir}/..."
  end

  def p4_integrate from, to
    puts "branching #{from} to #{to}"
    opened = `p4 opened ... 2>&1`
    raise "You have files open" unless opened =~ /file\(s\) not opened/
    sh "p4 integrate #{from}/... #{to}/..."
  end

  def p4_submit description
    sh "p4 submit -d #{description.inspect} ..."
  end
end
