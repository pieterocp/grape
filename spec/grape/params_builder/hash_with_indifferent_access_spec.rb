# frozen_string_literal: true

describe Grape::ParamsBuilder::HashWithIndifferentAccess do
  subject { app }

  let(:app) do
    Class.new(Grape::API)
  end

  describe "in an endpoint" do
    describe "#params" do
      before do
        subject.params do
          build_with :hash_with_indifferent_access
        end

        subject.get do
          params.class
        end
      end

      it "is of type Hash" do
        get "/"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("ActiveSupport::HashWithIndifferentAccess")
      end
    end
  end

  describe "in an api" do
    before do
      subject.build_with :hash_with_indifferent_access
    end

    describe "#params" do
      before do
        subject.get do
          params.class
        end
      end

      it "is a Hash" do
        get "/"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("ActiveSupport::HashWithIndifferentAccess")
      end

      it "parses sub hash params" do
        subject.params do
          build_with :hash_with_indifferent_access

          optional :a, type: Hash do
            optional :b, type: Hash do
              optional :c, type: String
            end
            optional :d, type: Array
          end
        end

        subject.get "/foo" do
          [params[:a]["b"][:c], params["a"][:d]]
        end

        get "/foo", a: {b: {c: "bar"}, d: ["foo"]}
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('["bar", ["foo"]]')
      end

      it "params are indifferent to symbol or string keys" do
        subject.params do
          build_with :hash_with_indifferent_access
          optional :a, type: Hash do
            optional :b, type: Hash do
              optional :c, type: String
            end
            optional :d, type: Array
          end
        end

        subject.get "/foo" do
          [params[:a]["b"][:c], params["a"][:d]]
        end

        get "/foo", "a" => {:b => {c: "bar"}, "d" => ["foo"]}
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('["bar", ["foo"]]')
      end

      it "responds to string keys" do
        subject.params do
          build_with :hash_with_indifferent_access
          requires :a, type: String
        end

        subject.get "/foo" do
          [params[:a], params["a"]]
        end

        get "/foo", a: "bar"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('["bar", "bar"]')
      end
    end

    it "does not overwrite route_param with a regular param if they have same name" do
      subject.namespace :route_param do
        route_param :foo do
          get { params.to_json }
        end
      end

      get "/route_param/bar", foo: "baz"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"foo":"bar"}')
    end

    it "does not overwrite route_param with a defined regular param if they have same name" do
      subject.namespace :route_param do
        params do
          requires :foo, type: String
        end
        route_param :foo do
          get do
            [params[:foo], params["foo"]]
          end
        end
      end

      get "/route_param/bar", foo: "baz"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('["bar", "bar"]')
    end
  end
end
