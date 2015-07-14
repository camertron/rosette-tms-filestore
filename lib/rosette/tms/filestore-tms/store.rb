# encoding: UTF-8

module Rosette
  module Tms
    module FilestoreTms

      class Store
        protected

        def filesystem_sanitize(name)
          name.gsub(/[^0-9A-Za-z.\-]/, '_')
        end
      end

    end
  end
end
