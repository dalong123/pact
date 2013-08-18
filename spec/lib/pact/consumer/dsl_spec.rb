require 'spec_helper'
require 'pact/consumer/dsl'
require 'pact/consumer/configuration_dsl'

module Pact::Consumer::DSL
   describe Service do
      before do
         Pact.clear_configuration
         Pact::Consumer::AppManager.instance.stub(:register_mock_service_for)
      end
      describe "configure_mock_producer" do
         subject { 
            Service.new :mock_service do
               port 1234
               standalone true
               verify true
            end
         }

         let(:mock_producer_name) { 'Mock Producer' }
         let(:mock_producer) { double('Pact::Consumer::MockProducer').as_null_object}
         let(:url) { "http://localhost:1234"}

         it "adds a verification to the Pact configuration" do
            Pact::Consumer::MockProducer.stub(:new).and_return(mock_producer)
            subject.configure_mock_producer({})
            mock_producer.should_receive(:verify)
            Pact.configuration.producer_verifications.first.call
         end

         context "when standalone" do
            it "does not register the app with the AppManager" do
               Pact::Consumer::AppManager.instance.should_not_receive(:register_mock_service_for)
               subject.configure_mock_producer({})
            end
         end
         context "when not standalone" do
            subject { 
               Service.new :mock_service do
                  port 1234
                  standalone false
                  verify true
               end
            }            
            it "registers the app with the AppManager" do
               Pact::Consumer::AppManager.instance.should_receive(:register_mock_service_for).with(mock_producer_name, url)
               subject.configure_mock_producer({:producer_name => mock_producer_name })
            end
         end         
      end
   end
end