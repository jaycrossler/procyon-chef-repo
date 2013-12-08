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
  notifies :run, "bash[sync_db]"
  notifies :run, "execute[collect_static]"
end

execute "install_procyon_dependencies" do
  command "#{node['procyon']['virtualenv']['location']}/bin/pip install -r requirements.txt"
  cwd node['procyon']['location']
  action :nothing
  user 'root'
end

template "procyon_local_settings" do
  source "local_settings.py.erb"
  path "#{node['procyon']['virtualenv']['location']}/local_settings.py"
  variables ({:database => node['procyon']['settings']['DATABASES']['default']})
end

link "local_settings_symlink" do
  link_type :symbolic
  to "#{node['procyon']['virtualenv']['location']}/local_settings.py"
  target_file "#{node['procyon']['location']}/procyon/local_settings.py"
  not_if do File.exists?("#{node['procyon']['location']}/procyon/local_settings.py") end
end

hostsfile_entry node['procyon']['database']['address'] do
  hostname node['procyon']['database']['hostname']
  only_if do node['procyon']['database']['hostname'] && node['procyon']['database']['address'] end
  action :append
end

include_recipe 'procyon::postgis'
include_recipe 'procyon::database'

directory node['procyon']['logging']['location'] do
  action :create
end

directory node['procyon']['settings']['static_root'] do
  owner "root"
  mode 00755
  action :create
  recursive true
end

bash "sync_db" do
  code "source #{node['procyon']['virtualenv']['location']}/bin/activate && paver sync"
  cwd "#{node['procyon']['location']}"
  action :nothing
end

execute "collect_static" do
  command "#{node['procyon']['virtualenv']['location']}/bin/python manage.py collectstatic --noinput"
  cwd "#{node['procyon']['location']}"
  action :nothing
end

bash "install_fixtures" do
  code "source #{node['procyon']['virtualenv']['location']}/bin/activate && paver install_dev_fixtures"
  cwd "#{node['procyon']['location']}"
  user 'postgres'
  action :nothing
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

