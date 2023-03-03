require "yast/rake"

Yast::Tasks.submit_to :sle15sp5

Yast::Tasks.configuration do |conf|
  conf.skip_license_check << /.*/
end

desc "Run unit tests with coverage."
task "coverage" do
  files = Dir["**/test/**/*_{spec,test}.rb"]
  sh "export COVERAGE=1; rspec --color --format doc '#{files.join("' '")}'" unless files.empty?
  # sh "xdg-open coverage/index.html"
end
