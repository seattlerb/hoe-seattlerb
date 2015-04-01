= hoe-seattlerb

home :: https://github.com/seattlerb/hoe-seattlerb
rdoc :: http://seattlerb.rubyforge.org/hoe-seattlerb

== DESCRIPTION:

Hoe plugins providing tasks used by seattle.rb including minitest,
perforce, and email providing full front-to-back release/announce
automation.

== FEATURES/PROBLEMS:

* hoe/perforce  - automating how we release with perforce.
* hoe/email     - automates sending release email.
* hoe/seattlerb - activates all the seattlerb plugins.

== SYNOPSIS:

  require 'rubygems'
  require 'hoe'
  
  Hoe.plugin :seattlerb
  
  Hoe.spec 'blah' do
    developer 'Ryan Davis', 'ryand-ruby@zenspider.com'
  
    email_to << 'blah@mailing_list.com'
  end

== USING EMAIL PLUGIN:

Once you activate the email plugin you should run:

  % rake config_hoe

A new section called email will be created at the bottom of the file.
Fill this out as appropriate for your email host. An example gmail
config is below:

  email:
    user: user.name
    pass: xxxx
    auth: plain
    port: submission
    to:
    - ruby-talk@ruby-lang.org
    host: smtp.gmail.com

== USING PERFORCE PLUGIN:

The perforce plugin adds a branch task attached to the prerelease
task. As well as branching, it checks the manifest against the actual
files and aborts if there is a mismatch.

The file structure it expects is:

* project_name
  * x.y.z - versioned branch directories
  * dev - the mainline of the project

Since you're running from rake and rake always backs up to the work
directory (presumed to be "dev" in this case) everything is done
relative to that location.

== REQUIREMENTS:

* hoe

== INSTALL:

* sudo gem install hoe-seattlerb

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
