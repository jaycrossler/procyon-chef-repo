default['procyon']['debug'] = true
default['procyon']['logging']['location'] = '/var/log/procyon'
default['procyon']['virtualenv']['location'] = '/var/lib/procyon'
default['procyon']['location'] = '/usr/src/procyon'
default['procyon']['git_repo']['location'] = 'https://github.com/jaycrossler/procyon.git'
default['procyon']['git_repo']['branch'] = 'master'
default['postgresql']['password']['postgres'] = 'procyon'

default['procyon']['database']['address'] = '127.0.0.1'
default['procyon']['database']['hostname'] = 'procyon-database'
default['procyon']['database']['name'] = 'procyon'
default['procyon']['database']['user'] = 'procyon'
default['procyon']['database']['password'] = 'procyon'
default['procyon']['database']['port'] = '5432'

default[:postgis][:version] = '2.0.4'
default['postgis']['template_name'] = 'template_postgis'
default['postgis']['locale'] = 'en_US.utf8'

default['procyon']['settings']['DATABASES'] = {
    :default=>{
        :name => node['procyon']['database']['name'],
        :user => node['procyon']['database']['user'],
        :password => node['procyon']['database']['password'],
        :host => node['procyon']['database']['hostname'],
        :port => node['procyon']['database']['port']
        },
    }

