# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

set :stage, :production
set :branch, 'master'

role :app, %w{deployer@wandoujob.cn}
role :web, %w{deployer@wandoujob.cn}
role :db,  %w{deployer@wandoujob.cn}

set :server_name, "b.testing.wandoujob.cn"
# set :port, "80" # 默认都是80端口

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
# set :server_name, "www.shuiguoshe.com shuiguoshe.com"

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'wandoujob.cn', user: "deployer", roles: %w{web app db}, primary: true

set :deploy_to, "/data/www/apps/#{fetch(:full_app_name)}"
#"/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"

set :rails_env, :production

# set :unicorn_worker_count, 4

set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,   "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix:///tmp/#{fetch(:full_app_name)}.puma.sock"      #根据nginx配置链接的sock进行设置，需要唯一
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [4, 5]
set :puma_workers, 2
set :puma_init_active_record, false
set :puma_preload_app, true


set :enable_ssl, false


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }