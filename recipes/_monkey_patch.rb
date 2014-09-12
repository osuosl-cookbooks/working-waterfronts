ruby_block "whats_fresh_monkey_patch" do
  block do
    ::Chef::Provider::ApplicationPythonDjango.class_eval do
      def action_before_compile
        include_recipe 'python'
        new_resource.migration_command "#{::File.join(new_resource.virtualenv, "bin", "python")} whats_fresh\
/manage.py syncdb --noinput" if !new_resource.migration_command
        new_resource.symlink_before_migrate.update({
new_resource.local_settings_base => new_resource.local_settings_file,})
      end
      def action_before_symlink
        if new_resource.collectstatic
          cmd = new_resource.collectstatic.is_a?(String) ? new_resource.collectstatic : "collectstatic --noi\
nput"
          execute "#{::File.join(new_resource.virtualenv, "bin", "python")} whats_fresh/manage.py #{cmd}" do
            user new_resource.owner
            group new_resource.group
            cwd new_resource.release_path
          end
        end
        ruby_block "remove_run_migrations" do
          block do
            if node.role?("#{new_resource.application.name}_run_migrations")
              Chef::Log.info("Migrations were run, removing role[#{new_resource.name}_run_migrations]")
              node.run_list.remove("role[#{new_resource.name}_run_migrations]")
            end
          end
        end
      end
    end
  end
end
