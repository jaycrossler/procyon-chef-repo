node.set['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']} postgresql-server-dev-#{node['postgresql']['version']}"]

include_recipe 'postgresql::server'