#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright 2013, Balanced, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Resource::JenkinsConfig < Resource::LWRPBase
    include Poise
    include Poise::Resource::SubResource
    self.resource_name = :jenkins_config
    default_action(:enable)
    actions(:disable)
    parent_type(Jenkins)

    attribute(:source, kind_of: String, required: true)
    attribute(:cookbook, kind_of: [String, Symbol], default: lazy { cookbook_name })

    def path
      ::File.join(parent.config_path, "#{name}.xml")
    end

    def after_created
      notifies(:rebuild_config, self.parent)
    end
  end

  class Provider::JenkinsConfig < Provider::LWRPBase
    include Poise

    def action_enable
      notifying_block do
        write_config
      end
    end

    def action_disable
      notifying_block do
        delete_config
      end
    end

    private
    def write_config
      template new_resource.path do
        source new_resource.source
        cookbook new_resource.cookbook
        owner new_resource.parent.user
        group new_resource.parent.group
        mode '600'
      end
    end

    def delete_config
      file new_resource.path do
        action :delete
      end
    end
  end
end