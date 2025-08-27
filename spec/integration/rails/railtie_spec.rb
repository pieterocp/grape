# frozen_string_literal: true

if defined?(Rails) && ActiveSupport.gem_version >= Gem::Version.new("7.1")
  describe Grape::Railtie do
    describe ".railtie" do
      subject { test_app.deprecators[:grape] }

      let(:test_app) do
        # https://github.com/rails/rails/issues/51784
        # same error as described if not redefining the following
        ActiveSupport::Dependencies.autoload_paths = []
        ActiveSupport::Dependencies.autoload_once_paths = []

        Class.new(Rails::Application) do
          config.eager_load = false
          config.load_defaults "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
        end
      end

      before { test_app.initialize! }

      it { is_expected.to be(Grape.deprecator) }
    end
  end
end
