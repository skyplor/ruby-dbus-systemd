#
# Copyright (C) 2016 Nathan Williams <nath.e.will@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# See docs for full API description:
# https://www.freedesktop.org/wiki/Software/systemd/dbus/
#
require_relative 'helpers'
require_relative 'mixin'
require_relative 'unit'
require_relative 'job'

module DBus
  module Systemd
    INTERFACE = 'org.freedesktop.systemd1'

    class Manager
      NODE = '/org/freedesktop/systemd1'
      INTERFACE = 'org.freedesktop.systemd1.Manager'

      UNIT_INDICES = {
        name: 0,
        description: 1,
        load_state: 2,
        active_state: 3,
        sub_state: 4,
        following: 5,
        object_path: 6,
        job_id: 7,
        job_type: 8,
        job_object_path: 9
      }

      JOB_INDICES = {
        id: 0,
        unit: 1,
        type: 2,
        state: 3,
        object_path: 4,
        unit_object_path: 5
      }

      include Mixin::MethodMissing
      include Mixin::Properties

      attr_reader :service

      def initialize(bus = Systemd::Helpers.system_bus)
        @service = bus.service(Systemd::INTERFACE)
        @object = @service.object(NODE)
                          .tap(&:introspect)
      end

      def units
        self.ListUnits.first.map { |u| map_unit(u) }
      end

      def unit(name)
        Unit.new(name, self)
      end

      def get_unit_by_object_path(path)
        obj = @service.object(path)
                      .tap(&:introspect)
        Unit.new(obj.Get(Unit::INTERFACE, 'Id').first, self)
      end

      def map_unit(unit_array)
        Helpers.map_array(unit_array, UNIT_INDICES)
      end

      def jobs
        self.ListJobs.first.map { |j| map_job(j) }
      end

      def job(id)
        Job.new(id, self)
      end

      def get_job_by_object_path(path)
        obj = @service.object(path)
                      .tap(&:introspect)
        Job.new(obj.Get(Job::INTERFACE, 'Id').first, self)
      end

      def map_job(job_array)
        Helpers.map_array(job_array, JOB_INDICES)
      end
    end
  end
end