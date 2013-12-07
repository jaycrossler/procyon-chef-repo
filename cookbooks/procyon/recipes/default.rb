procyon_pkgs = "build-essential python-dev libpq-dev libpng-dev libfreetype6 libfreetype6-dev".split

procyon_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

python_virtualenv node['procyon']['virtualenv']['location'] do
  interpreter "python2.7"
  action :create
end

python_pip "uwsgi" do
  virtualenv node['procyon']['virtualenv']['location']
end

git node['procyon']['location'] do
  repository node['procyon']['git_repo']['location']
  revision node['procyon']['git_repo']['branch']
  action :sync
  notifies :run, "execute[install_procyon_dependencies]", :immediately
end

execute "install_procyon_dependencies" do
  command "#{node['procyon']['virtualenv']['location']}/bin/pip install -r requirements.txt"
  cwd node['procyon']['location']
  action :run
  user 'root'
end

directory node['procyon']['logging']['location'] do
  action :create
end

template "procyon_uwsgi_ini" do
  path "#{node['procyon']['virtualenv']['location']}/procyon.ini"
  source "procyon.ini.erb"
  action :create_if_missing
  notifies :run, "execute[start_django_server]"
end

include_recipe 'procyon::nginx'

execute "start_django_server" do
  command "#{node['procyon']['virtualenv']['location']}/bin/uwsgi --ini #{node['procyon']['virtualenv']['location']}/procyon.ini &"
end

