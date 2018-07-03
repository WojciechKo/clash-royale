task default: %w[test]

task :update do
  ruby "script.rb"
  `git add .`
  `git commit -m"Table update"`
  `git push`
end
