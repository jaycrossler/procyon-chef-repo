procyon_pkgs =  "build-essential python-dev".split

procyon_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

python_virtualenv node['procyon']['virtualenv']['location'] do
  interpreter "python2.7"
  action :create
end

git node['procyon']['location'] do
  repository node['procyon']['git_repo']['location']
  revision node['procyon']['git_repo']['branch']
  action :sync
end

include_recipe 'procyon::nginx'


