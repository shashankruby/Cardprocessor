# frozen_string_literal: true

require "spec_helper"
require "credit_card_processor"

RSpec.describe CreditCardProcessor do
  subject { described_class.new('input-file.txt').process }

  describe "process" do
    context 'returns name and balance' do
      let(:response_array) do
        [{:balance=>-93, :cc_num=>"5454545454545454", :limit=>3000, :name=>"Lisa"},
         {:balance=>"error", :cc_num => '1234567890123456', :limit=>2000, :name=>"Quincy"},
         {:balance=>500, :cc_num=>"4111111111111111", :limit=>1000, :name=>"Tom"}]
      end

      let(:printed_response) do
        "Lisa: $-93\nQuincy: error\nTom: $500\n"
      end

      it { is_expected.to eq(response_array) }

      it 'should print the output' do
        expect { subject }.to output(printed_response).to_stdout
      end

      it 'should show balance error for Quincy' do
        subject
        expect(response_array.detect {|f| f[:name] == 'Quincy'}[:balance]).to eq 'error'
      end

      it 'should show negative balance for Lisa' do
        subject
        expect(response_array.detect {|f| f[:name] == 'Lisa'}[:balance]).to eq -93
      end
    end
  end
end
