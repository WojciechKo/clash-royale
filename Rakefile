task default: %w[test]

task :update do
  ruby "src/main.rb"
end

task :publish do
  `git add .`
  `git commit -m"Activity update"`
  `git push`
end
