# THIS MONCKEY PATCH IS NECESSARY FROM CORRECTLY CONTROLLING THE THREADS RELATED WITH
# THE DATABASES CREATION.

module ActiveRecord
  module ConnectionAdapters
    class ConnectionHandler
      def establish_connection(config, opts = {})
        resolver = ConnectionSpecification::Resolver.new(Base.configurations)
        spec = resolver.spec(config)

        remove_connection(spec.name)

        message_bus = ActiveSupport::Notifications.instrumenter
        payload = {
          connection_id: object_id
        }
        if spec
          payload[:spec_name] = spec.name
          payload[:config] = spec.config
        end

        message_bus.instrument("!connection.active_record", payload) do
          owner_to_pool[spec.name] = ConnectionAdapters::ConnectionPool.new(spec, opts)
        end

        owner_to_pool[spec.name]
      end
    end

    class ConnectionPool
      def initialize(spec, opts = {})
        super()

        @spec = spec

        @checkout_timeout = (spec.config[:checkout_timeout] && spec.config[:checkout_timeout].to_f) || 5
        if @idle_timeout = spec.config.fetch(:idle_timeout, 300)
          @idle_timeout = @idle_timeout.to_f
          @idle_timeout = nil if @idle_timeout <= 0
        end

        # default max pool size to 5
        @size = (spec.config[:pool] && spec.config[:pool].to_i) || 5

        # This variable tracks the cache of threads mapped to reserved connections, with the
        # sole purpose of speeding up the +connection+ method. It is not the authoritative
        # registry of which thread owns which connection. Connection ownership is tracked by
        # the +connection.owner+ attr on each +connection+ instance.
        # The invariant works like this: if there is mapping of <tt>thread => conn</tt>,
        # then that +thread+ does indeed own that +conn+. However, an absence of a such
        # mapping does not mean that the +thread+ doesn't own the said connection. In
        # that case +conn.owner+ attr should be consulted.
        # Access and modification of <tt>@thread_cached_conns</tt> does not require
        # synchronization.
        @thread_cached_conns = Concurrent::Map.new(initial_capacity: @size)

        @connections         = []
        @automatic_reconnect = true

        # Connection pool allows for concurrent (outside the main +synchronize+ section)
        # establishment of new connections. This variable tracks the number of threads
        # currently in the process of independently establishing connections to the DB.
        @now_connecting = 0

        @threads_blocking_new_connections = 0

        @available = ConnectionLeasingQueue.new self

        @lock_thread = false

        unless opts[:no_reaper] == true
          # +reaping_frequency+ is configurable mostly for historical reasons, but it could
          # also be useful if someone wants a very low +idle_timeout+.
          reaping_frequency = spec.config.fetch(:reaping_frequency, 60)
          @reaper = Reaper.new(self, reaping_frequency && reaping_frequency.to_f)
          t = @reaper.run
          if opts[:thread_name].present?
            t["thread_name"] = opts[:thread_name]
          end
        end
      end
    end
  end
end