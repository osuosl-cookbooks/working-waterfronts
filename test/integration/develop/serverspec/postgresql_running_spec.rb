require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe 'install and start the Postgres database' do
  describe service('postgresql-9.3') do
    it { should be_running }
  end
  describe port(5432) do
    it { should be_listening }
  end
end

describe 'create Postgis extension to database and create table' do
  describe command("runuser -l postgres -c 'psql whats_fresh -c \"\\dx\"'") do
    it { should return_stdout /(.*?)postgis(.*)/ }
  end
end
