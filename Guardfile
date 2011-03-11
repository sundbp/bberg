# rspec
guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| p "spec/#{m[1]}_spec.rb"; "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end
