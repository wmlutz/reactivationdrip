source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem "ruby-pardot"
gem 'restforce', '~> 2.5.3'
gem 'facets'
gem 'whenever', :require => false