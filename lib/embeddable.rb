require 'active_support/all'
require 'embeddable/version'
require 'embeddable/railtie' if defined?(Rails)
require 'embeddable/default_services'

module Embeddable
  extend ActiveSupport::Concern

  included do
    @embeddables = []
  end

  module ClassMethods
    attr_reader :embeddables

    def embeddable(name, options = {})
      source = options.fetch :from

      define_method name do
        url = send(source)
        return if url.blank?
        Service.find(url)
      end

      define_method "#{name}_type" do
        service = send(name)
        return unless service
        service.class.type.intern
      end

      define_method "#{name}_id" do
        send(name).try(:id)
      end

      define_method "#{name}?" do
        send("#{name}_id") ? true : false
      end

      Embeddable::Service.all.each do |service|

        define_method "#{name}_on_#{service.type}?" do
          send("#{name}_type") == service.type.intern
        end

      end

      define_method "#{name}_source" do
        source
      end

      @embeddables << name
    end
  end
end
