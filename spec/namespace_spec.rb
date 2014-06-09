require 'spec_helper'

describe NYNY::App do
  describe 'namespace' do
    let (:app) do
      mock_app do
        helpers do
          def le_helper
            :lulwut
          end
        end

        namespace '/foo' do
          get '/' do
            le_helper.should == :lulwut
            'bar'
          end
        end

        namespace '/nested' do
          namespace '/space' do
            get '/' do
              le_helper.should == :lulwut
              'caramba'
            end
          end
        end

        get '/' do
          'no namespace here'
        end
      end
    end

    it 'allows to use middlewares inside namespace' do
      kls = Class.new(NYNY::Base) do
        get '/' do
          'foo'
        end
      end

      app = mock_app do
        namespace '/foo' do
          use kls
        end
      end

      app.get('/foo')
    end

    it 'allows to specify stuff in namespaces' do
      app.get('/foo').body.should == 'bar'
    end

    it 'does not break the main app' do
      app.get('/').body.should == 'no namespace here'
    end

    it 'can be nested as well' do
      app.get('/nested/space/').body.should == 'caramba'
    end
  end
end
