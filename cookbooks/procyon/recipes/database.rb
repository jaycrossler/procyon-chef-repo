gem_package "pg" do
  action :install
end

postgresql_connection_info = {
  :host     => node['procyon']['database']['hostname'],
  :port     => node['procyon']['database']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

procyon_db = node['procyon']['settings']['DATABASES']['default']

# Create the procyon user
postgresql_database_user procyon_db[:user] do
    connection postgresql_connection_info
    password procyon_db[:password]
    action :create
end

# Create the procyon database
postgresql_database procyon_db[:name] do
  connection postgresql_connection_info
  template node['postgis']['template_name']
  owner procyon_db[:user]
  action :create
  notifies :run, "execute[sync_db]"
end

postgresql_database 'set user' do
  connection   postgresql_connection_info
  database_name procyon_db[:name]
  sql 'grant select on geometry_columns, spatial_ref_sys to ' + procyon_db[:user] + ';'
  action :query
end
