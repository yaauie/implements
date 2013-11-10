# encoding: utf-8
require_relative 'spec_helper'

describe Implements do
  context 'On a Widget interface' do
    let!(:interface) do
      interface = Module.new do
        extend Implements::Interface

        def initialize(number)
          @number = number
        end

        def wobble() :interface end
      end

      stub_const('::Widget', interface)
      def Widget.inspect() 'Widget' end

      interface
    end

    context 'with two conditional & one default implementations' do
      # order and registry matters, so define the implementations
      # with let! to ensure they are run and memoized before the
      # example is run.
      let!(:default_implementation) do
        Class.new do
          extend(Implements::Implementation)
          implements ::Widget
        end
      end
      let!(:small_implementation) do
        Class.new do
          extend(Implements::Implementation)
          implements ::Widget, as: :small do |number|
            number < 10
          end
          def wobble() :small end
        end
      end
      let!(:large_implementation) do
        Class.new do
          extend(Implements::Implementation)
          implements ::Widget, as: :large do |number|
            number >= 1_000_000
          end
          def wobble() :large end
        end
      end
      let!(:odd_implementation) do
        Class.new do
          extend(Implements::Implementation)
          implements ::Widget, as: :odd do |number|
            number.odd?
          end
          def wobble() :odd end
        end
      end

      context 'Interface#new' do
        let(:result) { interface.new(input) }
        subject { result }

        context 'matching the large implementation' do
          let(:input) { 10_000_000 }
          it 'should return the large implementation' do
            expect(result).to be_an_instance_of large_implementation
          end
          it { should be_a Widget }
          its(:wobble) { should be :large } # ensure proper inheritance
        end

        context 'matching the small implementation' do
          let(:input) { 2 }
          it 'should return the small implementation' do
            expect(result).to be_an_instance_of small_implementation
          end
          it { should be_a Widget }
          its(:wobble) { should be :small } # ensure proper inheritance
        end

        context 'matching neither small nor large' do
          let(:input) { 1_000 }
          it 'should return the default implementation' do
            expect(result).to be_an_instance_of default_implementation
          end
          it { should be_a Widget }
          its(:wobble) { should be :interface } # ensure proper inheritance
        end

        context '#implementation.new' do
          let(:result) { interface.implementation(*selectors).new(input) }
          subject { result }
          context 'specifying the large implementation' do
            let(:selectors) { [:large] }
            context 'not matching the large implementation' do
              let(:input) { 2 }
              it 'should raise an appropriate exception' do
                expect do
                  result
                end.to raise_error Implements::Implementation::NotFound
              end
            end
            context 'matching the large implementation' do
              let(:input) { 10_000_000 }
              it 'should return the large implementation' do
                expect(result).to be_an_instance_of large_implementation
              end
            end
          end
          context 'specifying the small implementation' do
            let(:selectors) { [:small] }
            context 'not matching the small implementation' do
              let(:input) { 1_000_000 }
              it 'should raise an appropriate exception' do
                expect do
                  result
                end.to raise_error Implements::Implementation::NotFound
              end
            end
            context 'matching the small implementation' do
              let(:input) { 2 }
              it 'should return the small implementation' do
                expect(result).to be_an_instance_of small_implementation
              end
            end
          end
          context 'when multiple implementations match' do
            let(:input) { 7 }
            context 'specifying the small or odd implementation' do
              let(:selectors) { [:small, :odd] }
              it 'should favor small' do
                expect(result).to be_an_instance_of small_implementation
              end
            end
            context 'specifying the odd or small implementation' do
              let(:selectors) { [:odd, :small] }
              it 'should favor odd' do
                expect(result).to be_an_instance_of odd_implementation
              end
            end
          end
        end
      end
    end

    context 'with no implementations' do
      context 'Interface#new' do
        let(:result) { interface.new(input) }
        subject { result }

        let(:input) { 1_000 }
        it 'should raise an appropriate exception' do
          expect { result }.to raise_error Implements::Implementation::NotFound
        end
      end
    end
  end
end
