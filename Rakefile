task default: %w[test]

task :update do
  ruby "src/main.rb"
  `git add .`
  `git commit -m"Activity update"`
  `git push`
end
