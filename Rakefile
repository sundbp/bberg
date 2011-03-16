require 'rubygems'
require 'fileutils'

# for rcov threshold testing
rcov_coverage_threshold = 90
require_exact_rcov_threshold = false

begin
  require 'rawr'
rescue LoadError
  # just silently ignore it, for development we don't have rawr available
  nil
end

begin
  require 'bundler'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install bundler` to install Bundler."
  STDERR.puts "But we'll continue ahead in case you're trying to bundle a .exe file.."
end

begin
  Bundler.setup(:development) if defined?(Bundler)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
  desc "Run specs with rcov"
  RSpec::Core::RakeTask.new("spec:rcov") do |t|
    t.rcov = true
    t.rcov_opts = %w{--exclude "spec\/,jsignal_internal"}
  end
  
  require 'yard'
  YARD::Rake::YardocTask.new

  require 'yardstick/rake/measurement'
  Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
    measurement.output = 'measurement/report.txt'
  end

  require 'yardstick/rake/verify'
  Yardstick::Rake::Verify.new do |verify|
    verify.threshold = 80
  end
  
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "But we'll continue ahead in case you're trying to create a .exe file.."
end

task :default => :spec
namespace :bberg do
  desc "create a .exe file for the bberg drb server"
  task :create_exe => [:clean_for_exe, :download_jruby_jar, "rawr:bundle:exe"]
  
  desc "clean up files in order to create a clean .exe"
  task :clean_for_exe do
    FileUtils.rm_rf('pkg')
  end
  
  desc "download jruby-complete.jar"
  task :download_jruby_jar do
    jar_file = File.join('vendor', 'java', 'jruby-complete-1.5.6.jar')
    if File.exists? jar_file
      puts "Already have a copy of jruby-complete.jar."
    else
      require 'net/http'
      require 'uri'
      http_proxy = ENV['http_proxy']
      http_proxy ||= ENV['HTTP_PROXY']
      http_object = if http_proxy
        uri = URI.parse(http_proxy)
        proxy_user, proxy_pass = uri.userinfo.split(/:/) if uri.userinfo
        Net::HTTP::Proxy(uri.host, uri.port, proxy_user, proxy_pass)
      else
        Net::HTTP
      end
      http_object.start('jruby.org.s3.amazonaws.com') do |http|
        puts "Downloading jruby-complete.jar.."
        #response = http.get('/downloads/1.6.0.RC3/jruby-complete-1.6.0.RC3.jar')
        response = http.get('/downloads/1.5.6/jruby-complete-1.5.6.jar')
        FileUtils.mkdir_p(File.join('vendor', 'java'))
        open(jar_file, "wb") do |file|
          file.write(response.body)
        end
      end    end
  end
  
  desc "Verify that rcov coverage is at least #{rcov_coverage_threshold}%"
  task :verify_rcov => "spec:rcov" do
    total_coverage = 0
    File.open("coverage/index.html").each_line do |line|
      if line =~ /<tt class='coverage_total'>\s*(\d+\.\d+)%\s*<\/tt>/
        total_coverage = $1.to_f
        break
      end
    end
    puts "Coverage: #{total_coverage}% (threshold: #{rcov_coverage_threshold}%)"
    raise "Coverage must be at least #{rcov_coverage_threshold}% but was #{total_coverage}%" if total_coverage < rcov_coverage_threshold
    raise "Coverage has increased above the threshold of #{rcov_coverage_threshold}% to #{total_coverage}%. You should update your threshold value." if (total_coverage > threshold) and require_exact_rcov_threshold
  end
  
end
